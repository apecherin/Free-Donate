class Pages.Profiles.PicturesNew extends Backbone.Marionette.ItemView
  id        : 'profiles-pictures-new'
  template  : 'pages/profiles/pictures_new'
  attributes:
    style: 'position: relative; top: -60px'

  #TODO: DRY Pages.Pictures.Show
  triggers:
    'click .prev-picture' : 'nav:prev'
    'click .next-picture' : 'nav:next'

  events:
    'click .add-picture' : 'addProfilePicture'
    'click .cancel'      : 'cancel'


  initialize: (attributes)->
    bookmarkletPictures = JSON.parse(decodeURIComponent(window.location.hash).substring(1))
    @modelCollection = Store.get('currentUser').get('profile_pictures')
    @bindTo @modelCollection, 'add', (picture)=>
      if picture.get('media_type') == 'youtube' and picture.get('title') == ''
        $.ajax {
          url: "http://gdata.youtube.com/feeds/api/videos/#{picture.get('video_id')}"
          data: 'alt=json'
          success: (result)=>
            picture.set('title', result.entry.title.$t)
        }
    for bookmarkletAttrs in bookmarkletPictures
      @modelCollection.add new Models.ProfilePicture
        remote_image_url: bookmarkletAttrs.src
        title           : bookmarkletAttrs.alt
        media_type      : bookmarkletAttrs.mediaType
        video_id        : bookmarkletAttrs.videoId

    #TODO: DRY Pages.Pictures.Show
    @model = @modelNext = @modelPrev = @modelCollection.models[0]
    @bindModel()
    @bindTo @, 'nav:prev', @prevPicture
    @bindTo @, 'nav:next', @nextPicture


  #TODO: DRY Pages.Pictures.Show
  bindModel: ->
    @bindTo @model, 'change:title', => @render()
    @bindTo @model, 'change:created_at', => @render()

  unbindModel: ->
    @model.unbind 'change:title'
    @model.unbind 'change:created_at'


  onRender: ->
    #TODO: DRY Pages.Pictures.Show
    @setPrevNext()
    MyApp.layout.withoutTopBar = true

  addProfilePicture: (event)->
    MyApp.vent.trigger 'notify:success', I18n.t('wait_message', scope: 'notification.cloud')
    @model.set('title', @$('#picture-title').val())
    @$('.add-picture').attr('disabled', true)
    profile = @modelCollection.profile
    profile.save null,
      wait: true
      error: =>
        @$('.add-picture').hide()
        @$('.view-pictures').show()
      success: ->
        setTimeout =>
          window.close()
        , 2000
    false

  cancel: ->
    window.close()
    false


  #TODO: DRY Pages.Pictures.Show
  setPrevNext: ->
    index = @modelCollection.indexOf(@model)

    # traverse collection in reverse order
    if index > 0
      @modelNext = @modelCollection.at(index - 1)
    else
      @modelNext = @modelCollection.last()

    if index < @modelCollection.size() - 1
      @modelPrev = @modelCollection.at(index + 1)
    else
      @modelPrev = @modelCollection.first()


  #TODO: DRY Pages.Pictures.Show
  prevPicture: ->
    @jumpToPicture @modelPrev

  nextPicture: ->
    @jumpToPicture @modelNext

  jumpToPicture: (picture)->
    @unbindModel()
    @model.set('title', @$('#picture-title').val())
    @model = picture
    @bindModel()
    @render()

  serializeData: ->
    picture: @model
    containerHeight: screen.height