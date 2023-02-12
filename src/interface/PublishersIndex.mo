import Types "../common/types";

module {
  public type PublisherInfoOptions = {
    includePublications: ?Bool;
  };

  public type PublisherInfoResponse = ?Types.SharedPublisher;

  public type PublisherInfoParams = (publisherId: Principal, options: ?PublisherInfoOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type PublicationInfoOptions = {
    includeWhitelist: ?Bool;
  };

  public type PublicationInfoResponse = ?Types.SharedPublication;

  public type PublicationInfoParams = (publisherId: Principal, eventName: Text, options: ?PublicationInfoOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type PublicationStatsOptions = {
    active: ?Bool;
    eventNames: ?[Text];
  };

  public type PublicationStatsResponse = Types.SharedStats;

  public type PublicationStatsParams = (publisherId: Principal, options: ?PublicationStatsOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type PublisherOptions = {
    includePublications: ?Bool;
  };

  public type PublisherResponse = {
    publisherInfo: Types.SharedPublisher;
    prevPublisherInfo: ?Types.SharedPublisher;
  };

  public type PublisherParams = (publisherId: Principal, options: ?PublisherOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type PublicationOptions = {
    whitelist: ?[Principal];
    whitelistAdd: ?[Principal];
    whitelistRemove: ?[Principal];
    includeWhitelist: ?Bool;
  };

  public type PublicationResponse = {
    publicationInfo: Types.SharedPublication;
    prevPublicationInfo: ?Types.SharedPublication;
  };

  public type PublicationParams = (publisherId: Principal, eventName: Text, options: ?PublicationOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type RemovePublicationOptions = {
    purge: ?Bool;
    includeWhitelist: ?Bool;
  };

  public type RemovePublicationResponse = {
    publicationInfo: ?Types.SharedPublication;
    prevPublicationInfo: ?Types.SharedPublication;
  };

  public type RemovePublicationParams = (publisherId: Principal, eventName: Text, options: ?RemovePublicationOptions);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public type PublishersIndex = actor {
    getPublisherInfo: shared (params: PublisherInfoParams) -> async PublisherInfoResponse;
    getPublicationInfo: shared (params: PublicationInfoParams) -> async PublicationInfoResponse;
    getPublicationStats: shared (params: PublicationStatsParams) -> async PublicationStatsResponse;
    registerPublisher: shared (params: PublisherParams) -> async PublisherResponse;
    registerPublication: shared (params: PublicationParams) -> async PublicationResponse;
    removePublication: shared (params: RemovePublicationParams) -> async RemovePublicationResponse;
  };
};
