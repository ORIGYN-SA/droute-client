import Candy "mo:candy/types";

module {
  public type Options = {
    mainId: ?Principal;
    publishersIndexId: ?Principal;
    subscribersIndexId: ?Principal;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type SharedStats = {
    numberOfEvents: Nat64;
    numberOfNotifications: Nat64;
    numberOfResendNotifications: Nat64;
    numberOfRequestedNotifications: Nat64;
    numberOfConfirmations: Nat64;
  };

  public type SharedPublisher = {
    id: Principal;
    createdAt: Nat64;
    activePublications: Nat8;
    publications: [Text];
  };

  public type SharedPublication = {
    eventName: Text;
    publisherId: Principal;
    createdAt: Nat64;
    stats: SharedStats;
    active: Bool;
    whitelist: [Principal];
  };

  public type SharedSubscriber = {
    id: Principal;
    createdAt: Nat64;
    activeSubscriptions: Nat8;
    listeners: [Principal];
    confirmedListeners: [Principal];
    subscriptions: [Text];
  };

  public type SharedSubscription = {
    eventName: Text;
    subscriberId: Principal;
    createdAt: Nat64;
    stats: SharedStats;
    rate: Nat32;
    active: Bool;
    stopped: Bool;
    filter: ?Text;
  };

  public type SharedEvent = {
    id: Nat;
    eventName: Text;
    publisherId: Principal;
    payload: Candy.CandyValue;
    createdAt: Nat64;
    nextBroadcastTime: Nat64;
    numberOfAttempts: Nat8;
  };
};
