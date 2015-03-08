class Pages.Dashboard.Login extends Backbone.Marionette.Layout
  template: 'pages/dashboard/login'

  events:
    'click #make-login' : 'login'
    'click .sign_up'    : 'signUp'
    'click .forgot'     : 'forgot'
    'click #facebook-login' : 'facebookLogin'

  initialize: ->

  onRender: ->

  login: ->
    @$('.login-form input').removeClass('error')
    email = @$('.login-form #user-email').val()
    pass = @$('.login-form #user-password').val()

    if email is '' or pass is ''
      MyApp.vent.trigger 'notify:error', I18n.t('please_fill_in', scope: 'signin.errors')
      @$('.login-form input').addClass('error')
    else
      $.ajax(type: 'POST', url:  '/api/user_accounts/sign_in', data: {user_account: {email: email, password: pass}})
        .success (data)=>
          Store.set 'currentUser', data
          window.location.replace '/'
        .error (data) =>
          MyApp.vent.trigger 'notify:error', I18n.t('incorrect', scope: 'signin.errors')
          $('.login-form input').addClass('error')

    false

  signUp: ->
    Backbone.history.navigate Routers.Main.registrationPath(), true
    false

  forgot: ->
    MyApp.modal.show new Modals.Users.Resetpassword
    false

  facebookLogin: ->
    window.location.replace '/api/user_accounts/auth/facebook'
    false

  serializeData: ->