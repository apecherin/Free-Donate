class Pages.Users.New extends Backbone.Marionette.ItemView
  template: 'modals/users/new'

  events:
    'click .cancel'               : 'cancelCreate'
    'click #register'             : 'saveUser'

  cancelCreate: ->
    @close()

  collectData: ->
    username:                @$('#user_new_username').val()
    terms_of_service:        @$('#user_new_terms_of_service').prop("checked")
    email: @$('#user_new_email').val()

  saveUser: ->
    # TODO: better is user#sign_up.
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

  serializeData: ->
    user: @model