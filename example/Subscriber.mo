import Debug "mo:base/Debug";
import DrouteClient "../src/Droute";
import Principal "mo:base/Principal";
import Types "../src/common/types";
import { setTimer } "mo:prim";

shared (deployer) actor class Subscriber() {
  let Droute = DrouteClient.Droute(?{
    mainId = ?Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai");
    publishersIndexId = ?Principal.fromText("r7inp-6aaaa-aaaaa-aaabq-cai");
    subscribersIndexId = ?Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
  });

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ignore setTimer(0, false, func(): async () {
    await* Droute.init();

    ignore await* Droute.subscribe("test_event_1", null);
    ignore await* Droute.subscribe("test_event_2", null);
  });

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public shared (context) func handleEvent(event: Types.SharedEvent): async () {
    await* Droute.handleEventGuard(context.caller);

    Debug.print("Handling event " # debug_show(event.id) # " with the name " # debug_show(event.eventName));

    ignore await* Droute.confirmEventReceipt(context.caller, event.id);
  };
};
