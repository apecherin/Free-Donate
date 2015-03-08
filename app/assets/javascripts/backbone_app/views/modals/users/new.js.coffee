class Modals.Users.New extends Backbone.Marionette.ItemView
  template: 'modals/users/new'

  events:
    'ajax:success #new-user' : 'userCreated'

  userCreated: (event, user)->
    @storeUser new Models.User user
    @close()
    ## TODO: fix server response and navifate to my dashboard page
    ## Backbone.history.navigate Routers.Main.myDashboardPath(), true
    Backbone.history.navigate Routers.Main.afterRegistratePath(), true
    false

  storeUser: (user)->
    Store.set 'currentUser', new Models.User user
    #MyApp.vent.trigger 'user:created'