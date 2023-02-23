import Array "mo:base/Array";
import Broadcast "./interface/Broadcast";
import Candy "mo:candy/types";
import Error "mo:base/Error";
import Main "./interface/Main";
import Set "mo:map/Set";
import Principal "mo:base/Principal";
import PublishersIndex "./interface/PublishersIndex";
import SubscribersIndex "./interface/SubscribersIndex";
import Types "./common/types";
import { hashNat32; hashNat64 } "./common/utils";
import { phash } "mo:map/Map";
import { get = coalesce } "mo:base/Option";
import { time; intToNat32Wrap } "mo:prim";

module {
  public type Droute = {
    mainActor: Main.Main;
    publishersIndexActor: PublishersIndex.PublishersIndex;
    subscribersIndexActor: SubscribersIndex.SubscribersIndex;
    var broadcastVersion: Nat64;
    var broadcastIds: Set.Set<Principal>;
    var broadcastActors: [Broadcast.Broadcast];
    var blacklistedCallers: Set.Set<Principal>;
    var randomSeed: Nat32;
    var initialized: Bool;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public let defaultOptions: Types.Options = {
    mainId = null;
    publishersIndexId = null;
    subscribersIndexId = null;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func new(options: ?Types.Options): Droute {
    let settings = coalesce(options, defaultOptions);

    let mainId = coalesce(settings.mainId, Principal.fromText("aaaaa-aa"));
    let publishersIndexId = coalesce(settings.publishersIndexId, Principal.fromText("aaaaa-aa"));
    let subscribersIndexId = coalesce(settings.subscribersIndexId, Principal.fromText("aaaaa-aa"));

    return {
      mainActor = actor(Principal.toText(mainId));
      publishersIndexActor = actor(Principal.toText(publishersIndexId));
      subscribersIndexActor = actor(Principal.toText(subscribersIndexId));
      var broadcastVersion = 0;
      var broadcastIds = Set.new();
      var broadcastActors = [];
      var blacklistedCallers = Set.new();
      var randomSeed = 0;
      var initialized = false;
    };
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func updateBroadcastIds(state: Droute): async* () {
    let response = await state.mainActor.getBroadcastIds();

    state.broadcastVersion := response.broadcastVersion;

    state.broadcastIds := Set.fromIter(response.broadcastIds.vals(), phash);

    state.broadcastActors := Array.map<Principal, Broadcast.Broadcast>(response.activeBroadcastIds, func(id) = actor(Principal.toText(id)));
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func init(state: Droute): async* () {
    if (not state.initialized) {
      await* updateBroadcastIds(state);

      state.randomSeed := intToNat32Wrap(hashNat64(time()));

      state.initialized := true;
    };
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func handleEventGuard(state: Droute, caller: Principal): async* () {
    if (not state.initialized) await* init(state);

    if (Set.has(state.blacklistedCallers, phash, caller)) {
      throw Error.reject("Principal " # debug_show(caller) # " is not a broadcast canister");
    };

    if (not Set.has(state.broadcastIds, phash, caller)) {
      await* updateBroadcastIds(state);

      if (not Set.has(state.broadcastIds, phash, caller)) {
        Set.add(state.blacklistedCallers, phash, caller);

        throw Error.reject("Principal " # debug_show(caller) # " is not a broadcast canister");
      };
    };
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func confirmEventReceipt(state: Droute, broadcastId: Principal, eventId: Nat): async* Broadcast.ConfirmEventResponse {
    let broadcastActor = actor(Principal.toText(broadcastId)):Broadcast.Broadcast;

    return await broadcastActor.confirmEventReceipt(eventId);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func publish(state: Droute, eventName: Text, payload: Candy.CandyValue): async* Broadcast.PublishResponse {
    if (not state.initialized) await* init(state);

    try {
      state.randomSeed +%= 1;

      if (state.broadcastActors.size() == 0) throw Error.reject("No broadcast canisters found");

      let broadcastActor = state.broadcastActors[hashNat32(state.randomSeed) % state.broadcastActors.size()];

      let response = await broadcastActor.publish(eventName, payload);

      if (response.broadcastVersion != state.broadcastVersion) await* updateBroadcastIds(state);

      return response;
    } catch (err) {
      if (Error.message(err) == "E60010: Canister is inactive") {
        await* updateBroadcastIds(state);

        state.randomSeed +%= 1;

        if (state.broadcastActors.size() == 0) throw Error.reject("No broadcast canisters found");

        let broadcastActor = state.broadcastActors[hashNat32(state.randomSeed) % state.broadcastActors.size()];

        return await broadcastActor.publish(eventName, payload);
      };

      throw err;
    };
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func getPublisherInfo(params: PublishersIndex.PublisherInfoFullParams): async* PublishersIndex.PublisherInfoResponse {
    let (state, options) = params;

    return await state.publishersIndexActor.getPublisherInfo(options);
  };

  public func getPublicationInfo(params: PublishersIndex.PublicationInfoFullParams): async* PublishersIndex.PublicationInfoResponse {
    let (state, eventName, options) = params;

    return await state.publishersIndexActor.getPublicationInfo(eventName, options);
  };

  public func getPublicationStats(params: PublishersIndex.PublicationStatsFullParams): async* PublishersIndex.PublicationStatsResponse {
    let (state, options) = params;

    return await state.publishersIndexActor.getPublicationStats(options);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func getSubscriberInfo(params: SubscribersIndex.SubscriberInfoFullParams): async* SubscribersIndex.SubscriberInfoResponse {
    let (state, options) = params;

    return await state.subscribersIndexActor.getSubscriberInfo(options);
  };

  public func getSubscriptionInfo(params: SubscribersIndex.SubscriptionInfoFullParams): async* SubscribersIndex.SubscriptionInfoResponse {
    let (state, eventName) = params;

    return await state.subscribersIndexActor.getSubscriptionInfo(eventName);
  };

  public func getSubscriptionStats(params: SubscribersIndex.SubscriptionStatsFullParams): async* SubscribersIndex.SubscriptionStatsResponse {
    let (state, options) = params;

    return await state.subscribersIndexActor.getSubscriptionStats(options);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func registerPublisher(params: PublishersIndex.PublisherFullParams): async* PublishersIndex.PublisherResponse {
    let (state, options) = params;

    return await state.publishersIndexActor.registerPublisher(options);
  };

  public func registerPublication(params: PublishersIndex.PublicationFullParams): async* PublishersIndex.PublicationResponse {
    let (state, eventName, options) = params;

    return await state.publishersIndexActor.registerPublication(eventName, options);
  };

  public func removePublication(params: PublishersIndex.RemovePublicationFullParams): async* PublishersIndex.RemovePublicationResponse {
    let (state, eventName, options) = params;

    return await state.publishersIndexActor.removePublication(eventName, options);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func registerSubscriber(params: SubscribersIndex.SubscriberFullParams): async* SubscribersIndex.SubscriberResponse {
    let (state, options) = params;

    return await state.subscribersIndexActor.registerSubscriber(options);
  };

  public func subscribe(params: SubscribersIndex.SubscriptionFullParams): async* SubscribersIndex.SubscriptionResponse {
    let (state, eventName, options) = params;

    return await state.subscribersIndexActor.subscribe(eventName, options);
  };

  public func unsubscribe(params: SubscribersIndex.UnsubscribeFullParams): async* SubscribersIndex.UnsubscribeResponse {
    let (state, eventName, options) = params;

    return await state.subscribersIndexActor.unsubscribe(eventName, options);
  };
};
