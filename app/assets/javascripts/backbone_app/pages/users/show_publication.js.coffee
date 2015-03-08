class Pages.Users.ShowPublication extends Backbone.Marionette.ItemView

  getTemplate: ->
    "pages/users/show_publication"

  events:
    'click .my-news-pub'           : 'goToMyNewsPub'
    'click .my-comparisons'        : 'goToMyComparisons'
    'click .my-comments'          : 'goToMyComments'
    

  initialize: ->
    @currentUser = Store.get('currentUser')
    unless @currentUser?
      @bindTo MyApp.vent, 'user:created', =>
        @currentUser = Store.get('currentUser')
        @render()

  goToMyComparisons: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showMyComparisonsHerePath(), true
    false

  goToMyComments:->
    Backbone.history.navigate Routers.Main.myCommentPath(), true
    false

  goToMyNewsPub: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/pub/news", true
    false