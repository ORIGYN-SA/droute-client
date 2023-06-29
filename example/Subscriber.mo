import Debug "mo:base/Debug";
import Droute "../src/Droute";
import Principal "mo:base/Principal";
import Types "../src/common/types";
import { setTimer } "mo:prim";

shared (deployer) actor class Subscriber() {
  stable let droute = Droute.new(?{
    mainId = ?Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai");
    publishersIndexId = ?Principal.fromText("r7inp-6aaaa-aaaaa-aaabq-cai");
    subscribersIndexId = ?Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
  });

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ignore setTimer(0, false, func(): async () {
    await* Droute.updateBroadcastIds(droute);

    ignore await* Droute.subscribe(droute, "test_event_1", null);
    ignore await* Droute.subscribe(droute, "test_event_2", null);
  });

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public shared (context) func handleEvent(event: Types.SharedEvent): async () {
    await* Droute.handleEventGuard(droute, context.caller);

    Debug.print("Handling event " # debug_show(event.id) # " with the name " # debug_show(event.eventName));

    ignore await* Droute.confirmEventReceipt(droute, context.caller, event.id);
  };
};
