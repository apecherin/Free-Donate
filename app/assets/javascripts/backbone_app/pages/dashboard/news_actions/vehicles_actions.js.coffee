class Pages.Dashboard.NewsActions.VehiclesActions extends Backbone.Marionette.Layout

  template: 'pages/dashboard/news_actions/vehicles_actions'

  regions:
    follow_to_user: '.follow_to_user'
    follow_to_obj:  '.follow_to_obj'

  events:
    'click .go-to-user' : 'goToUser'

    'click .watch-vehicle'     : 'goToVehicle'
    'click .vehicle-like-it'   : 'likeVehicle'
    'click .vehicle-unlike-it' : 'unlikeVehicle'
    'click .vehicle-share-it'  : 'shareVehicle'

  initialize: ({ @model, @myNews, @followingsNews, @followersNews, @vehicle }) ->
    @current_user = @currentUser = Store.get('currentUser')
    @initiator = @modelUser = @model.get('initiator')
    @extra = @model.get('target').extra
    @event_type = @model.get('event_type')

    @canSave = @canLike = (@currentUser && @modelUser.id isnt @currentUser.id)
    @canUnLike = Models.Ability.canUnLike(@vehicle)

  onRender: ->
    if @current_user?
      @current_user.get('followings').fetch success: (followings) =>
        @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()
    else
      @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: new Collections.Followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()
    
    @follow_to_obj?.show new Fragments.Vehicles.FavoriteButton vehicle: @model.get('vehicle'), vehicleType: @extra['vehicle_type']

  goToVehicle: ->
    vehicle = new Models.Vehicle({id: @extra['vehicle_id']})
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      Backbone.history.navigate(
        Routers.Main.showVehicleIdentificationPath(vehicle),
        true
      )
    false

  upperIcon: (object) ->
    if @$(object).hasClass('icon')
      @$(object).css('font-size', 25)
    else
      @$(object).parent('.icon').css('font-size', 25)

  likeVehicle: (event) ->
    return false unless @canLike
    vehicle = @vehicle
    return false unless vehicle && @currentUser
    vehicleLike = new Models.VehicleLike
      vehicle_id: vehicle.id
    vehicleLike.save null, success: =>
      @upperIcon(event.target)
      vehicle.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(vehicle)
        @render()
    false

  unlikeVehicle: (event) ->
    return false unless @canLike
    vehicle = @vehicle
    return false unless vehicle && @currentUser
    vehicleUnlike = new Models.VehicleUnlike
      vehicle_id: vehicle.id
    vehicleUnlike.save null, success: =>
      @upperIcon(event.target)
      vehicle.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(vehicle)
        @render()
    false

  shareVehicle: (event) ->
    vehicle = new Models.Vehicle({id: @extra['vehicle_id']})
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      MyApp.modal.show new Modals.CommonSharesButtons
        page_url: Routers.Main.showVehicleIdentificationPath(vehicle)
    false

  goToUser: (e) ->
    userId = $(e.currentTarget).data('user-id')
    userId ||= @model.get('initiator').id
    Backbone.history.navigate Routers.Main.showUserProfilePath(userId), true
    false

  serializeData: ->
    news_feed:      @model
    event_type:     @event_type
    extra:          @extra
    myNews:         @myNews
    followingsNews: @followingsNews
    followersNews:  @followersNews
    initiator:      @initiator
    last_updated:   @model.get('updated_at').substring(10, 0)
    canLike:        @canLike
    canUnLike:      @canUnLike
    canSave:        @canSave