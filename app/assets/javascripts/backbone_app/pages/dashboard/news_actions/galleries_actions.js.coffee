class Pages.Dashboard.NewsActions.GalleriesActions extends Backbone.Marionette.Layout

  template: 'pages/dashboard/news_actions/galleries_actions'

  regions:
    follow_to_user: '.follow_to_user'
    follow_to_obj:  '.follow_to_obj'

  events:
    'click .go-to-user' : 'goToUser'

    'click .watch-gallery'     : 'goToGallery'
    'click .gallery-like-it'   : 'likeGallery'
    'click .gallery-unlike-it' : 'unlikeGallery'
    'click .gallery-share-it'  : 'shareGallery'

  initialize: ({ @model, @myNews, @followingsNews, @followersNews, @gallery }) ->
    @current_user = @currentUser = Store.get('currentUser')
    @initiator = @modelUser = @model.get('initiator')
    @extra = @model.get('target').extra
    @event_type = @model.get('event_type')

    @canSave = @canLike = (@currentUser && @modelUser.id isnt @currentUser.id)
    @canUnLike = Models.Ability.canUnLike(@gallery)
    @ownsComparison = @currentUser and !@canSave

  onRender: ->
    if @current_user?
      @current_user.get('followings').fetch success: (followings) =>
        @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()
    else
      @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: new Collections.Followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()
    
    @follow_to_obj?.show new Fragments.Vehicles.FavoriteButton vehicle: @model.get('vehicle'), vehicleType: @extra['vehicle_type']

  goToGallery: ->
    vehicle = @model.get('vehicle')
    gallery_id = @extra['gallery_id']
    gallery = new Models.Gallery(id: gallery_id)
    gallery.url = "/vehicles/#{vehicle.get('id')}/galleries/#{gallery_id}"
    gallery.fetch success: =>
      Backbone.history.navigate Routers.Main.showVehicleGalleryPath(gallery, vehicle), true
    false

  upperIcon: (object) ->
    if @$(object).hasClass('icon')
      @$(object).css('font-size', 25)
    else
      @$(object).parent('.icon').css('font-size', 25)

  likeGallery: (event) ->
    return false unless @canLike
    gallery = @gallery
    return false unless gallery && @currentUser
    galleryLike = new Models.GalleryLike
      gallery_id: gallery.id
    galleryLike.save null, success: =>
      @upperIcon(event.target)
      gallery.url = "/vehicles/#{@model.get('target').extra.vehicle_id}/galleries/#{@model.get('target').extra.gallery_id}"
      gallery.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(gallery)
        @render()
    false

  unlikeGallery: (event) ->
    return false unless @canLike
    gallery = @gallery
    return false unless gallery && @currentUser
    galleryUnlike = new Models.GalleryUnlike
      gallery_id: gallery.id
    galleryUnlike.save null, success: =>
      @upperIcon(event.target)
      gallery.url = "/vehicles/#{@model.get('target').extra.vehicle_id}/galleries/#{@model.get('target').extra.gallery_id}"
      gallery.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(gallery)
        @render()
    false

  shareGallery: (event) ->
    gallery_id = @extra['gallery_id']
    vehicle_id = @extra['vehicle_id']
    vehicle = @model.get('vehicle')
    gallery = new Models.Gallery(id: gallery_id)
    gallery.url = "/vehicles/#{vehicle_id}/galleries/#{gallery_id}"
    gallery.fetch success: =>
      MyApp.modal.show new Modals.CommonSharesButtons
        page_url: Routers.Main.showVehicleGalleryPath(gallery, vehicle)
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