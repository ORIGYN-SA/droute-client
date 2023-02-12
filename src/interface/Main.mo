module {
  public type BroadcastIdsResponse = {
    broadcastIds: [Principal];
    broadcastVersion: Nat64;
  };

  public type BroadcastIdsParams = ();

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type Main = actor {
    getBroadcastIds: query (params: BroadcastIdsParams) -> async BroadcastIdsResponse;
  };
};
