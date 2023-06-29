import Candy "mo:candy/types";
import Types "../common/types";

module {
  public type ConfirmEventResponse = {
    confirmed: Bool;
  };

  public type ConfirmEventParams = (eventId: Nat);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type PublishResponse = {
    eventInfo: Types.SharedEvent;
    broadcastVersion: Nat64;
  };

  public type PublishParams = (eventName: Text, payload: Candy.CandyValue);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type PublishBatchResponse = {
    eventsInfo: [Types.SharedEvent];
    broadcastVersion: Nat64;
  };

  public type PublishBatchParams = (events: [Types.EventEntry]);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type Broadcast = actor {
    confirmEventReceipt: shared (params: ConfirmEventParams) -> async ConfirmEventResponse;
    publish: shared (params: PublishParams) -> async PublishResponse;
    publishBatch: shared (params: PublishBatchParams) -> async PublishBatchResponse;
  };
};
