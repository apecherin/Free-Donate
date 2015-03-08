class Fragments.Tabs.User extends Backbone.Marionette.ItemView
  template: 'fragments/tabs/user'

  events:
    'click #tabs-bar li a' : 'redirectToTab'
    'click #user-information' : 'showUserInfo'

  initialize: ({@user}) ->
    @currentUser = Store.get('currentUser')

  onRender: ->

  redirectToTab: (event) ->
    target = $(event.target)
    if target.data('target')?
      @activeTab = target.data('target').substr(1)
    if @activeTab is 'comparisons'
      Backbone.history.navigate Routers.Main.showUserProfileComparisonsPath(@user), true
    else if @activeTab is 'vehicles'
      Backbone.history.navigate Routers.Main.showUserVehiclesPath(@user), true
    else if @activeTab is 'pins'
      Backbone.history.navigate Routers.Main.showUserPinsPath(@user), true
    else if @activeTab is 'wall'
      Backbone.history.navigate Routers.Main.showUserProfileWallsPath(@user), true
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

  goToUserProfilePage: (e) ->
    $target = $(e.currentTarget).closest('a').first()
    userId = $target.data('user-id')
    return false unless userId
    userProfilePath = Routers.Main.showUserProfilePath(userId)
    Backbone.history.navigate(userProfilePath, true)
    false


  serializeData: ->
    user: @user
    canManage: Models.Ability.canManageComparisonTable(@user)