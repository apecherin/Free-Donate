class Pages.Dashboard.NewsActions.LikesActions extends Backbone.Marionette.Layout
  template: 'pages/dashboard/news_actions/likes_actions'

  regions:
    follow_to_user: '.follow_to_user'
    follow_to_obj:  '.follow_to_obj'

  events:
    'click .go-to-user' : 'goToUser'

    'click .watch-picture'     : 'goToPicture'
    'click .picture-like-it'   : 'likePicture'
    'click .picture-unlike-it' : 'unlikePicture'
    'click .picture-share-it'  : 'sharePicture'

  initialize: ({ @model, @myNews, @followingsNews, @followersNews, @picture }) ->
    @current_user = @currentUser = Store.get('currentUser')
    @initiator = @modelUser = @model.get('initiator')
    @extra = @model.get('target').extra
    @event_type = @model.get('event_type')

    @canSave = @canLike = (@currentUser && @modelUser.id isnt @currentUser.id)
    @canUnLike = Models.Ability.canUnLike(@picture)
    @ownsComparison = @currentUser and !@canSave

  onRender: ->
    if @current_user?
      @current_user.get('followings').fetch success: (followings) =>
        @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()
    else
      @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: new Collections.Followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()

    if !@model.get('target').extra.is_web_picture
      @follow_to_obj?.show new Fragments.Vehicles.FavoriteButton vehicle: @model.get('vehicle'), vehicleType: @extra['vehicle_type']

  goToPicture: ->
    if @model.get('target').extra.is_web_picture
      Backbone.history.navigate "/usr/#{@picture.get('user').id}/gar/pins/album/#{@picture.get('album_id')}/picture/#{@picture.get('id')}", true
    else
      vehicle = @model.get('vehicle')
      picture_id = @picture.get('id')
      gallery_id = @extra['gallery_id']
      gallery = new Models.Gallery(id: gallery_id)
      gallery.url = "/vehicles/#{vehicle.get('id')}/galleries/#{gallery_id}"
      gallery.fetch success: =>
        Backbone.history.navigate Routers.Main.showVehicleGalleryPath(gallery, vehicle) + "/picture/#{picture_id}", true
    false

  upperIcon: (object) ->
    if @$(object).hasClass('icon')
      @$(object).css('font-size', 25)
    else
      @$(object).parent('.icon').css('font-size', 25)

  likePicture: (event) ->
    return false unless @canLike
    picture = @picture
    return false unless picture && @currentUser
    pictureLike = new Models.PictureLike
      picture_id: picture.id
    pictureLike.url = '/api/pictures/' + picture.get('id') + '/like'
    pictureLike.save null, success: =>
      @upperIcon(event.target)
      picture.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(picture)
        @render()
    false

  unlikePicture: (event) ->
    return false unless @canLike
    picture = @picture
    return false unless picture && @currentUser
    pictureUnlike = new Models.PictureUnlike
      picture_id: picture.id
    pictureUnlike.url = '/api/pictures/' + picture.get('id') + '/unlike'
    pictureUnlike.save null, success: =>
      @upperIcon(event.target)
      picture.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(picture)
        @render()
    false

  sharePicture: (event) ->
    if @model.get('target').extra.is_web_picture
      MyApp.modal.show new Modals.CommonSharesButtons
        page_url: "/usr/#{@picture.get('user').id}/gar/pins/album/#{@picture.get('album_id')}/picture/#{@picture.get('id')}"
    else
      vehicle = @model.get('vehicle')
      picture_id = @picture.get('id')
      gallery_id = @extra['gallery_id']
      gallery = new Models.Gallery(id: gallery_id)
      gallery.url = "/vehicles/#{vehicle.get('id')}/galleries/#{gallery_id}"
      gallery.fetch success: =>
        MyApp.modal.show new Modals.CommonSharesButtons
          page_url: Routers.Main.showVehicleGalleryPath(gallery, vehicle) + "/picture/#{picture_id}"
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