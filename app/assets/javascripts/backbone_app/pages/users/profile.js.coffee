# This page display the public profile of an user.
class Pages.Users.Profile extends Backbone.Marionette.Layout
  template: 'pages/users/profile'

  regions:
    breadcrumb:  '#breadcrumb'
    collages:    '#collages'
    vehicles:    '#vehicles'
    comparisons: '#comparisons'
    follow:      '#follow'
    user_rate:   '#user-rate'
    user_rating: '#user-rating'
    pins:        '#pins'

  events:
    'click ul.dropdown-menu li > a' : 'tabClicked'
    'click ul.nav-tabs li > a' : 'tabClicked'
    'click .add-opposer'       : 'addToUserOpposers'
    'click .edit-collages'     : 'editCollages'
    'click .edit-collages-out' : 'editCollagesOut'
    'click .silhouettes-bar-link' : 'showVehicle'
    'click #user-information > .edit-avatar' : 'goToUserProfilePage'

  editCollages   : Views.Mixins.editCollages
  editCollagesOut: Views.Mixins.editCollagesOut
  renderCollages : Views.Mixins.renderCollages

  initialize: ({@activeTab, @vehicleType, @userPins, @collages_collection})->
    @activeTab ||= 'wall'
    @collageMode = 'collages_list'
    @currentUser = Store.get('currentUser')
    @profileView = 'false'
    @maxSideViewsToDisplay = 3
    @wall_hidden = @needHideWall @collages_collection

  onRender: ->
    @renderCollages @collages_collection, @collages
    if @activeTab?
      if @activeTab is 'wall' && (typeof @collages_collection == 'undefined' || @collages_collection.models.length == 0) && @collageMode == 'collages_list'
        @activeTab = 'vehicles'
        Backbone.history.navigate( Routers.Main.showUserVehiclesPath( @model))
        @renderBreadcrumbs()

      else if @activeTab is 'wall' && @collageMode == 'collages_edit'
        Backbone.history.navigate Routers.Main.showUserProfileWallsPath(@model)

      callback = =>
        @$('.nav-tabs a[data-target="#' + @activeTab + '"]').tab('show')
      setTimeout(callback, 0)

    @vehicles.show new Fragments.Users.Profile.Vehicles
      user:       @model
      collection: if @vehicleType? then new Collections.Vehicles @model.get('vehicles').where(type: @vehicleType) else @model.get('vehicles')

    if @currentUser?
      @user_rate?.show new Fragments.Users.Profile.Rate
        user: @model
        rating_info: @currentUser.get('rating_info')
        can_manage: @canManage()
        can_add_to_opposers: Models.Ability.canAddToOpposers(@model)
      @currentUser.get('followings').fetch success: (followings)=>
        @follow.show new Fragments.Users.Profile.Follow model: @model, followings: followings

    comparisonTables = new Collections.ComparisonTables
    comparisonTables.fetch
      data: {user_id: @model.id},
      success: (comparisonTables) =>
        @comparisons.show new Pages.Users.ComparisonTables comparisonTables: comparisonTables, user: @model, bradcumView: 'false', searchView: 'false'

    @pins.show new Pages.Users.Pins userPins: @userPins

    @$('.bubble-comment-avatar').popover('show')

    @user_rating?.show new Fragments.Users.Profile.Rating user: @model

    @renderBreadcrumbs()

  needHideWall: (collages) ->
    typeof collages == 'undefined' || collages.models.length == 0

  renderBreadcrumbs: ->
    @breadcrumb.show new Fragments.Breadcrumb.Index
      collection: Collections.Breadcrumbs.forProfile(@model, @activeTab, @vehicleType)

  tabClicked: (event) ->
    target = $(event.target)
    if target.data('target')?
      @activeTab = target.data('target').substr(1)
      @renderBreadcrumbs()
    if @activeTab is 'comparisons'
      Backbone.history.navigate Routers.Main.showUserProfileComparisonsPath(@model)
    else if @activeTab is 'vehicles'
      Backbone.history.navigate Routers.Main.showUserVehiclesPath(@model)
    else if @activeTab is 'pins'
      Backbone.history.navigate Routers.Main.showUserPinsPath(@model)
    else if @activeTab is 'wall'
      Backbone.history.navigate Routers.Main.showUserProfileWallsPath(@model)
      @renderBreadcrumbs()
    target.tab('show')
    false

  showVehicle: (e) ->
    vehicle_id = $(e.target).data 'id'
    vehiclePath = Routers.Main.showVehicleIdentificationPath(@model.get('vehicles').get(vehicle_id),'identification')
    Backbone.history.navigate(vehiclePath, true)
    false

  canManage: ->
    Models.Ability.canManageUser(@model)

  addToUserOpposers: ->
    bootbox.confirm(
      "Are you sure to block <strong>#{@model.get('username')}</strong> permanently?",
      (submit) =>
        if submit
          userOpposition = new Models.UserOpposition
          userOpposition.set opposer_id: @model.id
          userOpposition.save null, wait: true
    )
    false

  goToUserProfilePage: (e) ->
    $target = $(e.currentTarget).closest('a').first()
    userId = $target.data('user-id')
    return false unless userId
    userProfilePath = Routers.Main.showUserProfilePath(userId)
    Backbone.history.navigate(userProfilePath, true)
    false

  goToCommentsPage: (e) ->
    vehicleId = $(e.currentTarget).data('vehicle-id')
    vehicle = new Models.Vehicle({id: vehicleId})
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      Backbone.history.navigate(
        Routers.Main.showVehicleCommentsPath(vehicle),
        true
      )
    false

  serializeData: ->
    user:                      @model
    canManage:                 @canManage()
    canAddToOpposers:          Models.Ability.canAddToOpposers(@model)
    profileView:               false
    wallHidden:                @wall_hidden