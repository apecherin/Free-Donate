#= require ./transfert_galleries

class Pages.MyyCloud.ImportedContent.Transfert extends Backbone.Marionette.Layout
  template:  'pages/myy_cloud/transfert'

  events:
    'click .transfert-tab' : 'tabClicked'

  regions:
    publicGalleries  : '#transfert_public_galleries'
    privateGalleries : '#transfert_private_galleries'

  initialize: ({@albums})->
    newAlbum = new Models.Album
    @privateAlbums = new Collections.Albums @albums.where(privacy: 'private')
    @privateAlbums.add newAlbum

    @publicAlbums = new Collections.Albums @albums.where(privacy: 'public')
    @publicAlbums.add newAlbum

  onRender: ->

    @privateGalleries.show new Pages.MyyCloud.TransfertGalleries
      collection: @privateAlbums
      pictures: @collection
      galleryPrivacy: 'private'

    @publicGalleries.show  new Pages.MyyCloud.TransfertGalleries
      collection: @publicAlbums
      pictures: @collection
      galleryPrivacy: 'public'

    @albumReSize('#transfert_private_galleries')

  tabClicked: (event) ->
    @albumReSize(@$(event.target).data('target'))
    $(event.target).tab('show')
    false

  albumReSize: (type) ->
    if type is '#transfert_public_galleries'
      @resizeModal(@publicAlbums.size())
    else
      @resizeModal(@privateAlbums.size())

  resizeModal: (album_size) ->
    modal_width = { max: '665px', min: '400px' }
    body_width = { max: '635px', min: '355px' }
    type = 'max'
    type = 'min' if album_size is 1
    @$('#transfert-modal').css('width', modal_width[type])
    @$('#transfert-modal .modal-body').css('width', body_width[type])


  serializeData: ->
    user: @user