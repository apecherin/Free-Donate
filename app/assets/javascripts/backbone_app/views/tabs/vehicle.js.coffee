class Fragments.Tabs.Vehicle extends Backbone.Marionette.ItemView
  template: 'fragments/tabs/vehicle'

  events:
    'click .vehicle-tabs li a' : 'redirectToTab'
    'click #user-information'  : 'showUserInfo'

  initialize: ({@vehicle}) ->
    @currentUser = Store.get('currentUser')
    @user = @vehicle.get('user')
    @vehicle_tabNames = ['galleries', 'performances', 'modifications', 'specifications', 'expenses', 'identification_show', 'identification', 'version_comments', 'silhouette']
    @soloTabNames = ['version_comments']

  onRender: ->

  showUserInfo: ->
    if @currentUser?
      @vehicle.get('user').fetch success: (user) =>
        MyApp.modal.show new Modals.Users.UserInfo
          user: user
          current_user: @currentUser
          user_ratings: user.get('ratings')
          user_oppositions: @currentUser.get('user_oppositions')
    false

  redirectToTab: (event) ->
    MyApp.layout.content.show new Pages.Vehicles.Show model: @vehicle, currentTab: @$(event.target).attr('href').substring(1)

  serializeData: ->
    user: @user
    vehicle: @vehicle
    canEditBookmarks:  !Models.Ability.canManageVehicle(@vehicle) and @currentUser
    canAddToBookmarks: !@canRemoveFromBookmarks
    canAddToOpposers:  @currentUser and @user.get('id') isnt @currentUser.get('id')
    canManage:         @currentUser and @user.get('id') is @currentUser.get('id')
    currentUser:       @currentUser
    tabNames:          @vehicle_tabNames
    soloTabNames:      @soloTabNames
    currentTab:        'galleries'