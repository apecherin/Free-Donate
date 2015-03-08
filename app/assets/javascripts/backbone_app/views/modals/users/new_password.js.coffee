class Modals.Users.Newpassword extends Backbone.Marionette.ItemView
  template: 'modals/users/new_password'
  
  events:
    'ajax:success #reset-password' : 'userPassword'

  userPassword: ->
    @close()
