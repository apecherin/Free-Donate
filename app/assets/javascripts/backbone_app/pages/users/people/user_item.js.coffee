class Fragments.Users.People.UserItem extends Backbone.Marionette.ItemView
  template:  'fragments/users/people/user_item'
  tagName:   'li'
  className: 'following'

  events:
    'click .name' : 'goToProfile'

  goToProfile: ->
    Backbone.history.navigate Routers.Main.showUserProfilePath(@model), true

    false

  serializeData: ->
    user: @model