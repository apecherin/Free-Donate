Modals.Users.UnbindFacebookAccount = Backbone.Marionette.ItemView.extend
  template: 'modals/users/unbind_facebook_account'

  events:
    'submit form' : 'formSubmitted'


  formSubmitted: (event)->
    data =
      user_id: @model.get('id')
      user:
        email:                 @$('#email').val()
        password:              @$('#password').val()
        password_confirmation: @$('#password_confirmation').val()


    amplify.request 'users.unbind_facebook_account', data, (response)->
      if response == true
        MyApp.modal.close()
      else
        alert 'An error occured!'

    false


  serializeData: ->
    user: @model
