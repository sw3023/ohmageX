@Ohmage.module "SurveyApp", (SurveyApp, App, Backbone, Marionette, $, _) ->

  class SurveyApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "survey/:id": "show"

  API =
    show: (id) ->
      App.vent.trigger "nav:choose", "survey"
      console.log 'surveyApp show'

      $mySurveyXML = App.request "survey:saved:xml", id # gets the jQuery Survey XML by ID
      # initialize both the flow and response objects with jQuery Survey XML

      try
        App.execute "flow:init", $mySurveyXML
        App.execute "responses:init", $mySurveyXML
      catch Error
        # flow was already initialized. This happens if
        # someone navigates backwards via hitting the Back Button.
        # this cleans up and exits the survey properly.
        console.log Error
        App.execute "dialog:confirm", "Do you want to exit the #{App.dictionary('page','survey')}?", (=>
          App.vent.trigger "survey:exit", id
        ),(=>
          App.historyPrevious()
        )
        return false

      App.vent.trigger "survey:start", id

      firstId = App.request "flow:id:first"

      App.navigate "survey/#{id}/step/#{firstId}", trigger: true

  App.addInitializer ->
    new SurveyApp.Router
      controller: API

  App.vent.on "survey:exit", (surveyId) ->
    campaign_urn = App.request "survey:saved:urn", surveyId
    App.navigate "surveys/#{campaign_urn}", { trigger: true }
