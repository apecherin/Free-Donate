class Pages.Users.ShowPeopleMenu extends Backbone.Marionette.ItemView

  getTemplate: ->
    "pages/users/show_people_menu"

  events:
    'click .followings'            : 'goToFollowings'
    'click .followers'             : 'goToFollowers'
    'click .blocked'               : 'goToBlocked'
    'click .messages'              : 'goToMessagesShow'
    

  initialize: ->
    @currentUser = Store.get('currentUser')
    unless @currentUser?
      @bindTo MyApp.vent, 'user:created', =>
        @currentUser = Store.get('currentUser')
        @render()

  goToFollowings: ->
    Backbone.history.navigate Routers.Main.showMyPeopleFollowingsPath(), true
    false

  goToFollowers: ->
    Backbone.history.navigate Routers.Main.showMyPeopLeFollowersPath(), true
    false

  goToBlocked: ->
    Backbone.history.navigate Routers.Main.showMyPeopleBlockedPath(), true
    false

  goToMessagesShow: ->
    Backbone.history.navigate Routers.Main.showMyPeopleMessagesPath(), true
    false