Pages.Pictures.EditImage = Backbone.Marionette.ItemView.extend
  template: 'pages/pictures/edit_image'

  events:
    'click .blur-area' : 'blurArea'
    'click .cancel'    : 'viewPicture'

  initialize: (attributes)->
    @model = attributes.picture

  onRender: ->
    that = @
    @$('.picture-image img').Jcrop {
      boundary: 0,
      trueSize: [ @model.get('big_width'), @model.get('big_height') ]
      onSelect: =>
        @$('.blur-area').show()
      onRelease: =>
        @$('.blur-area').hide()
    }, ->
      that.api = @
    @$('.picture-image').css('margin-bottom', '-5px')
    @$('.picture-image').css('overflow', 'hidden')

  blurArea: (e) ->
    @model.set blur: @api.tellSelect()
    @model.save(null, {wait: true}).done =>
      @model.set('blur', null)
      @model.trigger('change:title')
    @viewPicture()

  # TODO: DRY Fragments.Galleries.Pictures#viewPicture
  viewPicture: (e) ->
    modal = new Pages.Pictures.Show(picture: @model)
    MyApp.modal.show(modal)
    false

  serializeData: ->
    picture: @model
