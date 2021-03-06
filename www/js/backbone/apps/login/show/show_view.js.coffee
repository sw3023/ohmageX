@Ohmage.module "LoginApp.Show", (Show, App, Backbone, Marionette, $, _) ->


  class Show.Notice extends App.Views.ItemView
    template: "login/show/_notice"

  class Show.Server extends App.Views.ItemView
    tagName: "option"
    template: "login/show/_serveritem"
    attributes: ->
      options = {}
      options['value'] = @model.get 'name'
      if @model.isChosen() then options['selected'] = 'selected'
      options

  class Show.ServerList extends App.Views.CompositeView
    initialize: ->
      @listenTo @collection, 'change:chosen', @setSubmitValue
      @listenTo @, 'custom:submit', @customSubmit
      @listenTo @, "server:selected", (-> @collection.chooseByName @$el.find('select').val())
    customSubmit: ->
      if @$el.find('select').val() is 'custom'
        @trigger "serverpath:submit", @$el.find('.custom-server').val()
    setSubmitValue: (model) ->
      if model.isChosen()
        if model.get('name') is 'custom'
          # chose the custom field, update the server name.
          @$el.find('.custom-server').attr('data-visible', true)
        else
          @$el.find('.custom-server').attr('data-visible', false)
          @trigger "serverpath:submit", @$el.find('select').val()
    template: "login/show/serverlist"
    childView: Show.Server
    childViewContainer: "select"
    onRender: ->
      if @$el.find('select').val() is 'custom' and @collection.length is 1
        # this means custom is the only option. Hide the select and show the custom form.
        @$el.find('.custom-server').attr('data-visible', true)
        @$el.find('select').attr('data-visible', false)
    triggers:
      "blur .custom-server": "custom:submit"
      "change select": "server:selected"
      "focus .custom-server": "custom:focus"

  class Show.Form extends App.Views.Layout
    initialize: ->
      @listenTo @, "submit:clicked", =>
        @trigger "errors:reset"
        @trigger "form:submit", @formValues()

      @listenTo App.vent, "serverpath:set:success", =>
        @trigger "errors:reset"
        @trigger "path:updated"

    formValues: ->
      username: @$el.find('input.username').val()
      password: @$el.find('input.pass').val()
    template: "login/show/form"
    regions:
      serversRegion: ".server-selector"
    triggers:
      "click button[type=submit]": "submit:clicked"
      "blur input[name=username]": "errors:reset"
      "blur input[name=pass]": "errors:reset"
    onRender: ->
      if App.custom.build.debug is true
        # prepopulate a debug login for the login form when debugging
        @$el.find('input[name=username]').val(App.custom.build.debug_settings.username)
        @$el.find('input[name=pass]').val(App.custom.build.debug_settings.password)
      @$el.find('input.pass').hideShowPassword
        innerToggle: true
        toggle:
          verticalAlign: "top"
    serializeData: ->
      data = {}
      data.app_name = App.custom.build.app_name
      data.header_image = App.custom.build.login_header_image
      data

  class Show.Layout extends App.Views.Layout
    template: "login/show/show_layout"
    regions:
      noticeRegion: "#notice-region"
      formRegion: "#form-region"
