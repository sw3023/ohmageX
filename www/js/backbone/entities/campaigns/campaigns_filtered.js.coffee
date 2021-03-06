@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The CampaignsFiltered entity is a decorator for Campaigns,
  # allowing campaigns to be filtered into different parts based on their
  # attributes, such as name.

  class Entities.CampaignsFiltered extends Entities.CampaignsUser
    initialize: (options) ->
      @campaigns = options
      @_meta = {}

      @listenTo @campaigns, "reset", ->
        @where @_currentCriteria

      @listenTo @campaigns, "sync:stop", ->
        console.log 'sync stop'
        @trigger "filter:search:clear"
        @trigger "filter:saved:clear"
        @where()

      @listenTo @campaigns, "remove", (model) ->
        # ensure the filtered list also updates when
        # user campaigns are removed.
        @remove model
    meta: (prop, value) ->
      if value is undefined
        return @_meta[prop]
      else
        @_meta[prop] = value

    where: (criteria) ->
      if criteria and criteria.name?
        # name search with fuzzy matching
        nameSearch = new RegExp criteria.name.split('').join('\\w*').replace(/\W/,""), "i"
        items = @campaigns.filter((campaign) ->
          myName = campaign.get('name')
          myName.match(nameSearch)
        )
        # Initiating a search must clear out any saved campaign selection.
        # Broadcast this event so views may update
        @meta('filterType', 'search')
        @trigger "filter:saved:clear"
      else if criteria and criteria.saved?
        items = @campaigns.filter((campaign) ->
          myStatus = campaign.get('status')
          myStatus isnt 'available'
        )
        # Choosing a saved item must clear out any search terms when it gets
        # selected. Broadcast this event so views may update
        @meta('filterType', 'saved')
        @trigger "filter:search:clear"
      else
        @meta('filterType', 'none')
        items = @campaigns.models

      console.log 'criteria', criteria
      @_currentCriteria = criteria

      @reset items


  API =
    getFiltered: (campaigns) ->
      filtered = new Entities.CampaignsFiltered campaigns

      if campaigns.length > 0
        # repopulates the list if our campaigns list starts out not empty,
        # such as when navigating back to the campaigns list when
        # the list has already been fetched.
        campaigns.trigger 'reset'

      filtered

  App.reqres.setHandler "campaigns:filtered", (campaigns) ->
    console.log 'campaigns:filtered', campaigns
    API.getFiltered campaigns
