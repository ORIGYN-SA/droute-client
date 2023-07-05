import Broadcast "../interface/Broadcast";
import Buffer "mo:buffer/StableBuffer";
import Candy "mo:candy/types";
import Const "../common/const";
import Error "mo:base/Error";
import Errors "../common/errors";
import Init "./Init";
import Iter "mo:base/Iter";
import Map "mo:map8/Map";
import Principal "mo:base/Principal";
import Set "mo:map8/Set";
import State "../common/state";
import Timer "mo:base/Timer";
import Types "../common/types";
import { hashNat32; getEventSize; bahash } "../common/utils";

module {
  public type PublishSyncResult = Broadcast.PublishResponse;

  public type PublishSyncParams = (state: State.Droute, eventName: Text, payload: Candy.CandyValue);

  public func publishSync((state, eventName, payload): PublishSyncParams): async* PublishSyncResult {
    if (state.broadcastActors.size() == 0) await* Init.updateBroadcastIds(state);

    try {
      state.randomSeed +%= 1;

      let broadcastActor = state.broadcastActors[hashNat32(state.randomSeed) % state.broadcastActors.size()];

      let response = await broadcastActor.publish(eventName, payload);

      if (response.broadcastVersion > state.broadcastVersion) try await* Init.updateBroadcastIds(state) catch (err) {};

      return response;
    } catch (err) {
      if (Error.message(err) == Errors.INACTIVE_CANISTER) {
        await* Init.updateBroadcastIds(state);

        state.randomSeed +%= 1;

        let broadcastActor = state.broadcastActors[hashNat32(state.randomSeed) % state.broadcastActors.size()];

        return await broadcastActor.publish(eventName, payload);
      };

      throw err;
    };
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  func publishBatch(state: State.Droute, options: Types.CallbackOptions): async* () {
    let eventsIter = Buffer.vals(state.events);

    if (state.broadcastActors.size() == 0) {
      try {
        await* Init.updateBroadcastIds(state);
      } catch (err) {
        for ((eventName, payload) in eventsIter) options.onError(eventName, payload, Errors.NO_BROADCAST_CANISTERS);
      };
    };

    var eventBatches = Map.new<Broadcast.Broadcast, Types.EventBatchGroup>(bahash);
    var nextEventBatches = Map.new<Broadcast.Broadcast, Types.EventBatchGroup>(bahash);
    var syncCallsCount = 0;
    var iterActive = true;

    while (iterActive) {
      label eventsLoop {
        syncCallsCount := if (Map.empty(eventBatches)) 0 else 1;

        for (eventEntry in eventsIter) label eventIteration {
          let size = getEventSize(eventEntry);

          if (size > Const.PAYLOAD_SIZE_LIMIT) {
            let (eventName, payload) = eventEntry;

            options.onError(eventName, payload, Errors.PAYLOAD_SIZE);

            break eventIteration;
          };

          state.randomSeed +%= 1;

          let broadcastActor = state.broadcastActors[hashNat32(state.randomSeed) % state.broadcastActors.size()];

          let ?batchGroup = Map.update<Broadcast.Broadcast, Types.EventBatchGroup>(eventBatches, bahash, broadcastActor, func(key, value) {
            return switch (value) { case (?batchGroup) null; case (_) ?Buffer.init() };
          });

          for (batch in Buffer.vals(batchGroup)) {
            if (batch.size + size <= Const.PAYLOAD_SIZE_LIMIT) {
              Buffer.add(batch.events, eventEntry);

              batch.size += size;

              break eventIteration;
            };
          };

          if (syncCallsCount < Const.SYNC_CALLS_LIMIT) {
            Buffer.add<Types.EventBatch>(batchGroup, { events = Buffer.fromArray([eventEntry]); var size });

            syncCallsCount += 1;
          } else {
            let nextBatchGroup = Buffer.fromArray<Types.EventBatch>([{ events = Buffer.fromArray([eventEntry]); var size }]);

            Map.set(nextEventBatches, bahash, broadcastActor, nextBatchGroup);

            break eventsLoop;
          };
        };

        iterActive := not Map.empty(eventBatches);
      };

      let responseFutures = Buffer.initPresized<([Types.EventEntry], async Broadcast.PublishBatchResponse)>(syncCallsCount);

      for ((broadcastActor, batchGroup) in Map.entries(eventBatches)) {
        for (batch in Buffer.vals(batchGroup)) {
          let events = Buffer.toArray(batch.events);

          Buffer.add(responseFutures, (events, broadcastActor.publishBatch(events)));
        };
      };

      let resendEvents = Buffer.init<[Types.EventEntry]>();
      var needBroadcastIdsUpdate = false;

      eventBatches := nextEventBatches;
      nextEventBatches := Map.new(bahash);

      for ((events, responseFuture) in Buffer.vals(responseFutures)) try {
        let response = await responseFuture;

        for (eventInfo in response.eventsInfo.vals()) options.onRespose(eventInfo);

        if (response.broadcastVersion > state.broadcastVersion) needBroadcastIdsUpdate := true;
      } catch (err) {
        if (Error.message(err) == Errors.INACTIVE_CANISTER) {
          needBroadcastIdsUpdate := true;

          Buffer.add(resendEvents, events);
        } else {
          for ((eventName, payload) in events.vals()) options.onError(eventName, payload, Error.message(err));
        };
      };

      if (needBroadcastIdsUpdate) {
        try {
          await* Init.updateBroadcastIds(state);
        } catch (err) {
          for (events in Buffer.vals(resendEvents)) {
            for ((eventName, payload) in events.vals()) options.onError(eventName, payload, Error.message(err));
          };
        };
      };

      let resendFutures = Buffer.initPresized<([Types.EventEntry], async Broadcast.PublishBatchResponse)>(Buffer.size(resendEvents));

      for (events in Buffer.vals(resendEvents)) {
        state.randomSeed +%= 1;

        let broadcastActor = state.broadcastActors[hashNat32(state.randomSeed) % state.broadcastActors.size()];

        Buffer.add(resendFutures, (events, broadcastActor.publishBatch(events)));
      };

      for ((events, responseFuture) in Buffer.vals(resendFutures)) try {
        let response = await responseFuture;

        for (eventInfo in response.eventsInfo.vals()) options.onRespose(eventInfo);
      } catch (err) {
        for ((eventName, payload) in events.vals()) options.onError(eventName, payload, Error.message(err));
      };
    };

    Buffer.clear(state.events);

    state.publishTimerId := 0;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type PublishResult = ();

  public type PublishParams = (state: State.Droute, eventName: Text, payload: Candy.CandyValue, options: Types.CallbackOptions);

  public func publish((state, eventName, payload, options): PublishParams): PublishResult {
    Buffer.add(state.events, (eventName, payload));

    if (state.publishTimerId == 0) {
      state.publishTimerId := Timer.setTimer(#seconds(0), func(): async () { await* publishBatch(state, options) });
    };
  };
};
