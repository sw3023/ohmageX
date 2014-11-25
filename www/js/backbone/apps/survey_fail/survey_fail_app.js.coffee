@Ohmage.module "SurveyFailApp", (SurveyFailApp, App, Backbone, Marionette, $, _) ->

  # All survey upload failure handlers are consolidated in this module.

  API =
    uploadFailureCampaign: (responseData, errorText, surveyId) ->
      # show notice to let them retry.
      console.log 'survey:upload:failure:campaign'
      App.execute "notice:show",
        data:
          title: "Survey Upload Error"
          description: "Problem with Survey Campaign: #{errorText}"
          showCancel: true
          cancelLabel: "Cancel"
          okLabel: "Retry"
        cancelListener: =>
          # After Queue implemented: Put the survey item in the upload queue.
          console.log 'responseData in cancelListener', responseData
          App.execute "uploadqueue:item:add", responseData
          # After Notice Center: Notify the user that the item was put into their upload queue.
          # Exit the survey.
          App.vent.trigger "survey:exit", surveyId
        okListener: =>
          App.execute "survey:upload", surveyId

  App.vent.on "survey:upload:failure:campaign", (responseData, errorText, surveyId) ->
    console.log responseData
    API.uploadFailureCampaign responseData, errorText, surveyId

  App.vent.on "survey:upload:failure:response", (responseData, errorText, surveyId) ->
    # placeholder for response errors handler.

  App.vent.on "survey:upload:failure:server", (responseData, errorText, surveyId) ->
    # placeholder for server errors handler.

  App.vent.on "survey:upload:failure:auth", (responseData, errorText, surveyId) ->
    # placeholder for auth errors handler.

  App.vent.on "survey:upload:failure:network", (responseData, errorText, surveyId) ->
    # placeholder for network errors handler.