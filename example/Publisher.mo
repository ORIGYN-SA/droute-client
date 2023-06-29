import Candy "mo:candy/types";
import Droute "../src/Droute";
import Principal "mo:base/Principal";
import Types "../src/common/types";
import { setTimer } "mo:prim";

shared (deployer) actor class Publisher() {
  stable let droute = Droute.new(?{
    mainId = ?Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai");
    publishersIndexId = ?Principal.fromText("r7inp-6aaaa-aaaaa-aaabq-cai");
    subscribersIndexId = ?Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
  });

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ignore setTimer(0, false, func(): async () {
    await* Droute.updateBroadcastIds(droute);

    ignore await* Droute.registerPublication(droute, "test_event_1", null);
    ignore await* Droute.registerPublication(droute, "test_event_2", null);
  });

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public shared func publish(eventName: Text, payload: Candy.CandyValue): async Types.SharedEvent {
    let response = await* Droute.publishSync(droute, eventName, payload);

    return response.eventInfo;
  };
};
