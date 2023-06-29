import Broadcast "../interface/Broadcast";
import Error "mo:base/Error";
import Errors "../common/errors";
import Init "./Init";
import Principal "mo:base/Principal";
import Set "mo:map8/Set";
import State "../common/state";
import { phash } "mo:map8/Map";

module {
  public type HandleEventGuardResult = ();

  public type HandleEventGuardParams = (state: State.Droute, caller: Principal);

  public func handleEventGuard((state, caller): HandleEventGuardParams): async* HandleEventGuardResult {
    if (Set.has(state.blacklistedCallers, phash, caller)) throw Error.reject(Errors.UNKNOWN_BROADCAST_CANISTER(caller));

    if (not Set.has(state.broadcastIds, phash, caller)) {
      await* Init.updateBroadcastIds(state);

      if (not Set.has(state.broadcastIds, phash, caller)) {
        Set.add(state.blacklistedCallers, phash, caller);

        throw Error.reject(Errors.UNKNOWN_BROADCAST_CANISTER(caller));
      };
    };
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type ConfirmEventReceiptResult = Broadcast.ConfirmEventResponse;

  public type ConfirmEventReceiptParams = (state: State.Droute, broadcastId: Principal, eventId: Nat);

  public func confirmEventReceipt((state, broadcastId, eventId): ConfirmEventReceiptParams): async* ConfirmEventReceiptResult {
    let broadcastActor = actor(Principal.toText(broadcastId)):Broadcast.Broadcast;

    return await broadcastActor.confirmEventReceipt(eventId);
  };
};
