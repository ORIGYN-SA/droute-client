import Types "../common/types";

module {
  public type State = {
    subscribersIndexActor: SubscribersIndex;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type SubscriberInfoOptions = {
    includeListeners: ?Bool;
    includeSubscriptions: ?Bool;
  };

  public type SubscriberInfoResponse = ?Types.SharedSubscriber;

  public type SubscriberInfoParams = (options: ?SubscriberInfoOptions);

  public type SubscriberInfoFullParams = (state: State, options: ?SubscriberInfoOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type SubscriptionInfoResponse = ?Types.SharedSubscription;

  public type SubscriptionInfoParams = (eventName: Text);

  public type SubscriptionInfoFullParams = (state: State, eventName: Text);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type SubscriptionStatsOptions = {
    active: ?Bool;
    eventNames: ?[Text];
  };

  public type SubscriptionStatsResponse = Types.SharedStats;

  public type SubscriptionStatsParams = (options: ?SubscriptionStatsOptions);

  public type SubscriptionStatsFullParams = (state: State, options: ?SubscriptionStatsOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type SubscriberOptions = {
    listeners: ?[Principal];
    listenersAdd: ?[Principal];
    listenersRemove: ?[Principal];
    includeListeners: ?Bool;
    includeSubscriptions: ?Bool;
  };

  public type SubscriberResponse = {
    subscriberInfo: Types.SharedSubscriber;
    prevSubscriberInfo: ?Types.SharedSubscriber;
  };

  public type SubscriberParams = (options: ?SubscriberOptions);

  public type SubscriberFullParams = (state: State, options: ?SubscriberOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type SubscriptionOptions = {
    stopped: ?Bool;
    rate: ?Nat32;
    filter: ??Text;
  };

  public type SubscriptionResponse = {
    subscriptionInfo: Types.SharedSubscription;
    prevSubscriptionInfo: ?Types.SharedSubscription;
  };

  public type SubscriptionParams = (eventName: Text, options: ?SubscriptionOptions);

  public type SubscriptionFullParams = (state: State, eventName: Text, options: ?SubscriptionOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type UnsubscribeOptions = {
    purge: ?Bool;
  };

  public type UnsubscribeResponse = {
    subscriptionInfo: ?Types.SharedSubscription;
    prevSubscriptionInfo: ?Types.SharedSubscription;
  };

  public type UnsubscribeParams = (eventName: Text, options: ?UnsubscribeOptions);

  public type UnsubscribeFullParams = (state: State, eventName: Text, options: ?UnsubscribeOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type SubscribersIndex = actor {
    getSubscriberInfo: shared (params: SubscriberInfoParams) -> async SubscriberInfoResponse;
    getSubscriptionInfo: shared (params: SubscriptionInfoParams) -> async SubscriptionInfoResponse;
    getSubscriptionStats: shared (params: SubscriptionStatsParams) -> async SubscriptionStatsResponse;
    registerSubscriber: shared (params: SubscriberParams) -> async SubscriberResponse;
    subscribe: shared (params: SubscriptionParams) -> async SubscriptionResponse;
    unsubscribe: shared (params: UnsubscribeParams) -> async UnsubscribeResponse;
  };
};
