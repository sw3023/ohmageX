@Ohmage.module "HeaderApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Nav extends App.Views.ItemView
    tagName: "li"

    modelEvents:
      "change:chosen": "changeChosen"

    getTemplate: -> 
      if @model.isDivider() then false else "header/list/_nav"

    onRender: ->
      @$el.addClass "divider" if @model.isDivider()

    changeChosen: (model, value, options) ->
      @$el.toggleClass "active", value

  class List.Header extends App.Views.CollectionView
    tagName: "ul"
    attributes:
      class: "right"
    childView: List.Nav

  class List.Layout extends App.Views.Layout
    initialize: ->
      @listenTo @collection, "change:chosen", (model) ->
        if model.isChosen() then @menu.close();
    template: "header/list/layout"
    regions:
      listRegion: "#app-menu .list-container"
      buttonRegion: "#button-region"
    onRender: ->
      @menu = new SlideOutComponent('#app-menu', @$el)
      @menu.toggleOn('click', '.app-menu-trigger', @$el)
