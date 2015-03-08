class Modals.Users.Resetpassword extends Backbone.Marionette.ItemView
  template: 'modals/users/reset_password'

  events:
    'ajax:success #reset-password' : 'userPassword'

  userPassword: ->
    @close()
    Backbone.history.navigate Routers.Main.afterResetPasswordPath(), true