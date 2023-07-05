import Init "./modules/Init";
import Publish "./modules/Publish";
import PublishersIndex "./interface/PublishersIndex";
import Receive "./modules/Receive";
import State "./common/state";
import SubscribersIndex "./interface/SubscribersIndex";
import Types "./common/types";

module {
  public type Droute = State.Droute;

  public let { defaultOptions } = Init;

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func new(params: Init.NewParams): Init.NewResult {
    return Init.new(params);
  };

  public func updateBroadcastIds(params: Init.UpdateBroadcastIdsParams): async* Init.UpdateBroadcastIdsResult {
    return await* Init.updateBroadcastIds(params);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func handleEventGuard(params: Receive.HandleEventGuardParams): async* Receive.HandleEventGuardResult {
    return await* Receive.handleEventGuard(params);
  };

  public func confirmEventReceipt(params: Receive.ConfirmEventReceiptParams): async* Receive.ConfirmEventReceiptResult {
    return await* Receive.confirmEventReceipt(params);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func publishSync(params: Publish.PublishSyncParams): async* Publish.PublishSyncResult {
    return await* Publish.publishSync(params);
  };

  public func publish(params: Publish.PublishParams): Publish.PublishResult {
    return Publish.publish(params);
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
