class Pages.Dashboard.Registration extends Backbone.Marionette.Layout
  template: 'pages/dashboard/registration'

  events:
    'click #register' : 'saveUser'
    'click .sign_in'  : 'signIn'
    'click #facebook-login' : 'facebookLogin'

  initialize: ({@countries}) ->
    @model =  new Models.User

  onRender: ->
    @$('#user_country_code').chosen()

  collectData: ->
    username: @$('#user_new_username').val()
    terms_of_service: true
    email: @$('#user_new_email').val()
    country_code: @$('select[name=country_code]').val()
    language_code: (@$('select[name=country_code]').val())?.toLowerCase()

  saveUser: ->
    @model.set @collectData()
    @model.save null,
      url: '/api/user_accounts'
      success: =>
        if @model.isServerValid()
          @close()
          MyApp.vent.trigger 'notify:success', 'User is successfully registered'
          Backbone.history.navigate Routers.Main.afterRegistratePath(), true
        else
          @render()
      error: =>
        @render()

    false

  signIn: ->
    Backbone.history.navigate Routers.Main.loginPath(), true
    false

  facebookLogin: ->
    window.location.replace '/api/user_accounts/auth/facebook'
    false

  serializeData: ->
    user: @model
    countries: @countries