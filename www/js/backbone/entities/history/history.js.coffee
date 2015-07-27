@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The History Entity generates the user's saved response history.

  currentHistory = false

  class Entities.UserHistoryResponse extends Entities.Model

  class Entities.UserHistoryResponsesByCampaign extends Entities.Collection
    model: Entities.UserHistoryResponse
    url: ->
      "#{App.request("serverpath:current")}/app/survey_response/read"

  class Entities.UserHistoryResponses extends Entities.Collection
    model: Entities.UserHistoryResponse

  API =
    init: ->
      currentHistory = new Entities.UserHistoryResponses
    fetchHistory: (campaign_urns) ->
      App.vent.trigger 'loading:show', "Fetching Responses..."
      campaignCollections = []
      responseFetchSuccess = []

      myData =
        # add start date - 3 months ago
        # if start date, end date is also required
        client: App.client_string
        column_list: "urn:ohmage:special:all"
        prompt_id_list: "urn:ohmage:special:all"
        output_format: "json-rows"
        user_list: App.request "credentials:username"
      myData = _.extend(myData, App.request("credentials:upload:params"))

      _.each campaign_urns, (campaign_urn) ->
        myData.campaign_urn = campaign_urn
        myCampaign = new Entities.UserHistoryResponsesByCampaign
        campaignCollections.push myCampaign

        myCampaign.fetch
          reset: true
          type: "POST"
          data: myData
          campaign_urn: campaign_urn
          success: (collection, response, options) =>
            if response.result isnt "failure"
              responseFetchSuccess.push true
            else
              responseFetchSuccess.push false

          error: (collection, response, options) =>
            responseFetchSuccess.push false
            App.execute "dialog:alert", "Network error fetching history."

      currentHistory._fetch = new $.Deferred()

      App.execute "when:fetched", campaignCollections, =>
        if _.contains(responseFetchSuccess, false)
          # there was an error while fetching one of the campaign's responses
          App.vent.trigger "history:responses:fetch:error"
        # resolve the fetch handler.
        currentHistory._fetch.resolve()

    getHistory: ->
      if currentHistory.length < 1
        # fetch all history from the server,
        # because our current version is empty
        campaign_urns = App.request 'surveys:saved:campaign_urns'
        if campaign_urns.length is 0 then return false

      else
        # just return the collection
        currentHistory

  App.reqres.on "history:responses", ->
    API.getHistory()

  App.on "before:start", ->
    API.init()
