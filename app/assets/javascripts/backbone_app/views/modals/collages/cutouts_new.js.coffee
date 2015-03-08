Modals.Collages.CutoutsNew = Backbone.Marionette.ItemView.extend
  template:  'modals/collages/cutouts_new'

  events:
    'click .crop-area' : 'cropArea'
    'click .cancel'    : 'viewPicture'


  initialize: (attributes)->
    @model = attributes.picture
    @modelCollection = attributes.pictures
    @cutout = attributes.cutout


  onRender: ->
    that = @
    @$('.picture-image img').Jcrop {
      boundary: 0,
      trueSize: [ @model.get('big_width'), @model.get('big_height') ]
      aspectRatio: @cutout.get('width') / @cutout.get('height')
      minSize: [ @cutout.get('width'), @cutout.get('height') ]
      onSelect: =>
        @$('.crop-area').show()
      onRelease: =>
        @$('.crop-area').hide()
    }, ->
      that.api = @
    @$('.picture-image').css('margin-bottom', '-5px')
    @$('.picture-image').css('overflow', 'hidden')


  serializeData: ->
    picture: @model

  cropArea: ->
    console.log @model
    @cutout.set crop: @api.tellSelect(), picture_id: @model.id, image_extension: @model.get('extension')
    @cutout.save {}, wait: true
    @close()

  viewPicture: ->
    MyApp.modal.show new Pages.Pictures.Show
      picture:  @model
      pictures: @modelCollection
      cutout:   @cutout
    false
