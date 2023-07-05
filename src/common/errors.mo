module {
  public let INACTIVE_CANISTER = "E60010: Canister is inactive";

  public let NO_BROADCAST_CANISTERS = "E70010: No broadcast canisters found";

  public let PAYLOAD_SIZE = "E70020: Event payload size limit reached";

  public let UNKNOWN_BROADCAST_CANISTER = func(principalId: Principal): Text {
    return "E70030: Principal " # debug_show(principalId) # " is not a broadcast canister";
  };
};
