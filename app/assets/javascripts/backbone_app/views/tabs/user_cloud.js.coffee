class Fragments.Tabs.UserCloud extends Backbone.Marionette.ItemView
  template: 'fragments/tabs/user_cloud'

  events:
    'click #tabs-bar li a' : 'redirectToTab'
    'click #user-information' : 'showUserInfo'

  initialize: ({@user, @gallery}) ->

  onRender: ->

  redirectToTab: (event) ->
    target = $(event.target)
    if target.data('target')?
      Backbone.history.navigate Routers.Main.myyCloudPath(target.data('target').substr(1), @user), true
    false

  showUserInfo: ->
    if @currentUser?
      @user.fetch success: (user) =>
        MyApp.modal.show new Modals.Users.UserInfo
          user: user
          current_user: @currentUser
          user_ratings: user.get('ratings')
          user_oppositions: @currentUser.get('user_oppositions')
    false

  serializeData: ->
    user: @user
    private: @gallery.get('privacy') is 'private'