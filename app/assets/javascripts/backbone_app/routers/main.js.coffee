class Routers.Main extends Backbone.Marionette.AppRouter
  controller: Controllers.Main

  appRoutes:
    ''                   : 'home'

  @rootPath: ->
    '/'