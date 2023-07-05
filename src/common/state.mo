import Broadcast "../interface/Broadcast";
import Buffer "mo:buffer/StableBuffer";
import Main "../interface/Main";
import PublishersIndex "../interface/PublishersIndex";
import Set "mo:map8/Set";
import SubscribersIndex "../interface/SubscribersIndex";
import Types "./types";

module {
  public type Droute = {
    mainActor: Main.Main;
    publishersIndexActor: PublishersIndex.PublishersIndex;
    subscribersIndexActor: SubscribersIndex.SubscribersIndex;
    events: Buffer.StableBuffer<Types.EventEntry>;
    var publishTimerId: Nat;
    var broadcastVersion: Nat64;
    var broadcastIds: Set.Set<Principal>;
    var broadcastActors: [Broadcast.Broadcast];
    var blacklistedCallers: Set.Set<Principal>;
    var randomSeed: Nat32;
  };
};
