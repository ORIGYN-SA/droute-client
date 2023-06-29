import Array "mo:base/Array";
import Broadcast "../interface/Broadcast";
import Buffer "mo:buffer/StableBuffer";
import Error "mo:base/Error";
import Errors "../common/errors";
import Principal "mo:base/Principal";
import Set "mo:map8/Set";
import State "../common/state";
import Types "../common/types";
import { phash } "mo:map8/Map";
import { get = coalesce } "mo:base/Option";
import { time; intToNat32Wrap } "mo:prim";
import { hashNat64 } "../common/utils";

module {
  public let defaultOptions: Types.Options = {
    mainId = null;
    publishersIndexId = null;
    subscribersIndexId = null;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type NewResult = State.Droute;

  public type NewParams = (options: ?Types.Options);

  public func new((options): NewParams): NewResult {
    let settings = coalesce(options, defaultOptions);

    let mainId = coalesce(settings.mainId, Principal.fromText("aaaaa-aa"));
    let publishersIndexId = coalesce(settings.publishersIndexId, Principal.fromText("aaaaa-aa"));
    let subscribersIndexId = coalesce(settings.subscribersIndexId, Principal.fromText("aaaaa-aa"));

    return {
      mainActor = actor(Principal.toText(mainId));
      publishersIndexActor = actor(Principal.toText(publishersIndexId));
      subscribersIndexActor = actor(Principal.toText(subscribersIndexId));
      events = Buffer.init();
      var publishTimerId = 0;
      var broadcastVersion = 0;
      var broadcastIds = Set.new(phash);
      var broadcastActors = [];
      var blacklistedCallers = Set.new(phash);
      var randomSeed = intToNat32Wrap(hashNat64(time()));
    };
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type UpdateBroadcastIdsResult = ();

  public type UpdateBroadcastIdsParams = (state: State.Droute);

  public func updateBroadcastIds((state): UpdateBroadcastIdsParams): async* UpdateBroadcastIdsResult {
    let response = await state.mainActor.getBroadcastIds();

    if (response.activeBroadcastIds.size() == 0) throw Error.reject(Errors.NO_BROADCAST_CANISTERS);

    state.broadcastVersion := response.broadcastVersion;

    state.broadcastIds := Set.fromIter(response.broadcastIds.vals(), phash);

    state.broadcastActors := Array.map<Principal, Broadcast.Broadcast>(response.activeBroadcastIds, func(id) = actor(Principal.toText(id)));
  };
};
