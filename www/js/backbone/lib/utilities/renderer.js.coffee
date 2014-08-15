@Ohmage.module "Utilities", (Utilities, App, Backbone, Marionette, $, _) ->

_.extend Marionette.Renderer,

  lookups: ["js/backbone/apps/", "js/backbone/lib/components/"]

  render: (template, data) ->
    return if template is false
    path = @getTemplate(template)
    throw "Template #{template} not found!" unless path
    path(data)

  getTemplate: (template) ->
    for lookup in @lookups
      ## inserts the template at the '-1' position of the template array
      ## this allows to omit the word 'templates' from the view but still
      ## store the templates in a directory outside of the view
      ## example: "users/list/layout" will become "users/list/templates/layout"

      # return JST[lookup + path + ".jst.html"] if JST[lookup + path + ".jst.html"]

      for path in [template, @withTemplate(template)]
        return JST[lookup + path + ".jst"] if JST[lookup + path + ".jst"]

  withTemplate: (string) ->
    array = string.split("/")
    array.splice(-1, 0, "templates")
    array.join("/")