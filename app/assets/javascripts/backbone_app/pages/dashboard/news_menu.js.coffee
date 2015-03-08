class Pages.Dashboard.NewsShowMenu extends Backbone.Marionette.ItemView

  getTemplate: ->
    "pages/dashboard/news_menu"

  events:
    'click .all-news'              : 'goToAllNews'
    'click .albums'                : 'goToAlbums'
    'click .all-sales'             : 'goToAllSales'
    'click .filter'                : 'goToFilterVehicle'

  initialize: ->
    @currentUser = Store.get('currentUser')
    unless @currentUser?
      @bindTo MyApp.vent, 'user:created', =>
        @currentUser = Store.get('currentUser')
        @render()

  goToAllNews: ->
    Backbone.history.navigate 'news/veh', true
    false

  goToAlbums: ->
    Backbone.history.navigate Routers.Main.albumsPath(), true
    false

  goToAllSales:->
    Backbone.history.navigate Routers.Main.allSalesPath(), true
    false

  goToFilterVehicle: ->
    Backbone.history.navigate Routers.Main.showVehiclesPath(), true
    false