import Array "mo:base/Array";
import Broadcast "./interface/Broadcast";
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
  public let defaultOptions: Types.Options = {
    mainId = null;
    publishersIndexId = null;
    subscribersIndexId = null;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public class Droute(options: ?Types.Options) {
    let settings = coalesce(options, defaultOptions);

    let mainId = coalesce(settings.mainId, Principal.fromText("aaaaa-aa"));
    let publishersIndexId = coalesce(settings.publishersIndexId, Principal.fromText("aaaaa-aa"));
    let subscribersIndexId = coalesce(settings.subscribersIndexId, Principal.fromText("aaaaa-aa"));

    let mainActor = actor(Principal.toText(mainId)):Main.Main;
    let publishersIndexActor = actor(Principal.toText(publishersIndexId)):PublishersIndex.PublishersIndex;
    let subscribersIndexActor = actor(Principal.toText(subscribersIndexId)):SubscribersIndex.SubscribersIndex;

    var broadcastVersion = 0:Nat64;
    var broadcastIds = Set.new(phash);
    var broadcastActors = []:[Broadcast.Broadcast];
    var blacklistedCallers = Set.new(phash);
    var randomSeed = 0:Nat32;
    var initialized = false;

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    func updateBroadcastIds(): async* () {
      let response = await mainActor.getBroadcastIds();

      broadcastVersion := response.broadcastVersion;

      broadcastIds := Set.fromIter(response.broadcastIds.vals(), phash);

      broadcastActors := Array.map<Principal, Broadcast.Broadcast>(response.activeBroadcastIds, func(id) = actor(Principal.toText(id)));
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func init(): async* () {
      await* updateBroadcastIds();

      randomSeed := intToNat32Wrap(hashNat64(time()));

      initialized := true;
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func handleEventGuard(caller: Principal): async* () {
      if (not initialized) await* init();

      if (Set.has(blacklistedCallers, phash, caller)) {
        throw Error.reject("Principal " # debug_show(caller) # " is not a broadcast canister");
      };

      if (not Set.has(broadcastIds, phash, caller)) {
        await* updateBroadcastIds();

        if (not Set.has(broadcastIds, phash, caller)) {
          Set.add(blacklistedCallers, phash, caller);

          throw Error.reject("Principal " # debug_show(caller) # " is not a broadcast canister");
        };
      };
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func confirmEventReceipt(broadcastId: Principal, eventId: Nat): async* Broadcast.ConfirmEventResponse {
      let broadcastActor = actor(Principal.toText(broadcastId)):Broadcast.Broadcast;

      return await broadcastActor.confirmEventReceipt(eventId);
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func publish(params: Broadcast.PublishParams): async* Broadcast.PublishResponse {
      if (not initialized) await* init();

      try {
        randomSeed +%= 1;

        if (broadcastActors.size() == 0) throw Error.reject("No broadcast canisters found");

        let broadcastActor = broadcastActors[hashNat32(randomSeed) % broadcastActors.size()];

        let response = await broadcastActor.publish(params);

        if (response.broadcastVersion != broadcastVersion) await* updateBroadcastIds();

        return response;
      } catch (err) {
        if (Error.message(err) == "E60010: Canister is inactive") {
          await* updateBroadcastIds();

          randomSeed +%= 1;

          if (broadcastActors.size() == 0) throw Error.reject("No broadcast canisters found");

          let broadcastActor = broadcastActors[hashNat32(randomSeed) % broadcastActors.size()];

          return await broadcastActor.publish(params);
        };

        throw err;
      };
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func getPublisherInfo(params: PublishersIndex.PublisherInfoParams): async* PublishersIndex.PublisherInfoResponse {
      return await publishersIndexActor.getPublisherInfo(params);
    };

    public func getPublicationInfo(params: PublishersIndex.PublicationInfoParams): async* PublishersIndex.PublicationInfoResponse {
      return await publishersIndexActor.getPublicationInfo(params);
    };

    public func getPublicationStats(params: PublishersIndex.PublicationStatsParams): async* PublishersIndex.PublicationStatsResponse {
      return await publishersIndexActor.getPublicationStats(params);
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func getSubscriberInfo(params: SubscribersIndex.SubscriberInfoParams): async* SubscribersIndex.SubscriberInfoResponse {
      return await subscribersIndexActor.getSubscriberInfo(params);
    };

    public func getSubscriptionInfo(params: SubscribersIndex.SubscriptionInfoParams): async* SubscribersIndex.SubscriptionInfoResponse {
      return await subscribersIndexActor.getSubscriptionInfo(params);
    };

    public func getSubscriptionStats(params: SubscribersIndex.SubscriptionStatsParams): async* SubscribersIndex.SubscriptionStatsResponse {
      return await subscribersIndexActor.getSubscriptionStats(params);
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func registerPublisher(params: PublishersIndex.PublisherParams): async* PublishersIndex.PublisherResponse {
      return await publishersIndexActor.registerPublisher(params);
    };

    public func registerPublication(params: PublishersIndex.PublicationParams): async* PublishersIndex.PublicationResponse {
      return await publishersIndexActor.registerPublication(params);
    };

    public func removePublication(params: PublishersIndex.RemovePublicationParams): async* PublishersIndex.RemovePublicationResponse {
      return await publishersIndexActor.removePublication(params);
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func registerSubscriber(params: SubscribersIndex.SubscriberParams): async* SubscribersIndex.SubscriberResponse {
      return await subscribersIndexActor.registerSubscriber(params);
    };

    public func subscribe(params: SubscribersIndex.SubscriptionParams): async* SubscribersIndex.SubscriptionResponse {
      return await subscribersIndexActor.subscribe(params);
    };

    public func unsubscribe(params: SubscribersIndex.UnsubscribeParams): async* SubscribersIndex.UnsubscribeResponse {
      return await subscribersIndexActor.unsubscribe(params);
    };
  };
};
