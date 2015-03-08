class Pages.Dashboard.NewsActions.Actions extends Backbone.Marionette.Layout
  template: 'pages/dashboard/news_actions/actions'

  regions:
    follow_to_user: '.follow_to_user'
    follow_to_obj:  '.follow_to_obj'

  events:
    'click .more-info.create_vehicle' : 'goToVehicle'
    'click .more-info.create_gallery' : 'goToGallery'
    'click .more-info.add_pictures_to_gallery' : 'goToGallery'
    'click .more-info.create_modification' : 'goToModification'
    'click .more-info.create_part_purchase' : 'goToPartPurchase'
    'click .more-info.create_comparison_table' : 'goToComparison'
    'click .more-info.modify_comparison_table' : 'goToComparison'
    'click .more-info.add_likes' : 'goToPicture'
    'click .more-info.add_comments_to_picture' : 'goToPicture'

    'click .reply-on-comment' : 'goToPicture'
    'click .go-to-user' : 'goToUser'

  initialize: ({ @model, @myNews, @followingsNews, @followersNews }) ->
    @current_user = Store.get('currentUser')
    @initiator = @model.get('initiator')
    @extra = @model.get('target').extra
    @event_type = @model.get('event_type')

  onRender: ->
    if @current_user?
      @current_user.get('followings').fetch success: (followings) =>
        @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()
    else
      @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: new Collections.Followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()

    if @event_type in ['create_vehicle', 'create_gallery', 'add_pictures_to_gallery', 'add_comments_to_picture'
                       'create_modification', 'create_part_purchase', 'add_pictures_to_gallery', 'add_likes']
      vehicle = new Models.Vehicle id: @extra['vehicle_id']
      vehicle.collection = new Collections.Vehicles
      vehicle.fetch success: =>
        @follow_to_obj?.show new Fragments.Vehicles.FavoriteButton vehicle: vehicle, vehicleType: @extra['vehicle_type']
    else if @event_type in ['create_comparison_table', 'modify_comparison_table']
      console.log @model.get('target')
      vehicle = new Models.Vehicle id: @extra['vehicle_id']
      vehicle.collection = new Collections.Vehicles
      vehicle.fetch success: =>
        @follow_to_obj?.show new Fragments.Vehicles.SaveComparisonButton vehicle: vehicle

  goToVehicle: ->
    vehicle = new Models.Vehicle({id: @extra['vehicle_id']})
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      Backbone.history.navigate(
        Routers.Main.showVehicleIdentificationPath(vehicle),
        true
      )
    false

  goToGallery: ->
    gallery_id = @extra['gallery_id']
    vehicle = new Models.Vehicle(id: @extra['vehicle_id'])
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      gallery = new Models.Gallery id : gallery_id
      vehicle.get('galleries').add(gallery)
      vehicle.get('galleries').fetch success: =>
        gallery = vehicle.get('galleries')._byId[gallery_id]
        Backbone.history.navigate Routers.Main.showVehicleGalleryPath(gallery, vehicle), true
    false

  goToModification: ->
    modification_id = @extra.id
    vehicle = new Models.Vehicle(id: @extra.vehicle_id)
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      vehicle.get('user').fetch success: =>
        modification = new Models.Modification(id: modification_id, vehicle: vehicle)
        modification.fetch success: ->
          Backbone.history.navigate Routers.Main.showModificationsConfDomainMod1Path(modification.get('vehicle'), modification.get('change_set_id'), modification.get('change_set_name'), modification.get('domain'), modification, 'changes'), false
          MyApp.layout.content.show new Pages.Vehicles.Show
            model: vehicle
            currentTab: 'modifications'
            changeSetId:  modification.get('change_set_id')
            domainName: modification.get('domain')
            modificationId: modification.get('id')
    false

  goToPartPurchase: ->
    modification_id = @extra.modification_id
    vehicle = new Models.Vehicle(id: @extra.vehicle_id)
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      vehicle.get('user').fetch success: =>
        modification = new Models.Modification(id: modification_id, vehicle: vehicle)
        modification.fetch success: ->
          Backbone.history.navigate Routers.Main.showModificationsConfDomainMod1Path(modification.get('vehicle'), modification.get('change_set_id'), modification.get('change_set_name'), modification.get('domain'), modification, 'parts'), false
          MyApp.layout.content.show new Pages.Vehicles.Show
            model: vehicle
            currentTab: 'modifications'
            changeSetId:  modification.get('change_set_id')
            domainName: modification.get('domain')
            modificationId: modification.get('id')
            cps_tab: 'parts'
    false

  goToComparison: ->
    path = Routers.Main.showUserComparisonPath(@model.get('initiator'), new Models.ComparisonTable(@extra.table))
    Backbone.history.navigate(path, true)
  false

  saveComparison: ->
    false

  likeComparison: ->
    false

  goToPicture: ->
    gallery_id = @extra['gallery_id']
    picture_id = @extra['picture_id']
    vehicle = new Models.Vehicle(id: @extra['vehicle_id'])
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      gallery = new Models.Gallery id : gallery_id
      vehicle.get('galleries').add(gallery)
      vehicle.get('galleries').fetch success: =>
        gallery = vehicle.get('galleries')._byId[gallery_id]
        Backbone.history.navigate (Routers.Main.showVehicleGalleryPath(gallery, vehicle) + "/picture/#{picture_id}"), true
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