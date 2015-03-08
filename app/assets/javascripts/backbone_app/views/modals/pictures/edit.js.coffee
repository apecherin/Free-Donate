Modals.Pictures.Edit = Backbone.Marionette.ItemView.extend
  template: 'modals/pictures/edit'

  events:
    'submit form' : 'updatePicture'


  initialize: (attributes)->
    @model = attributes.picture
    @updatedPictureAttrs = {}

    @bindTo @, 'item:before:close', =>
      @$('.input-append.date').data().datepicker?.picker.remove()


  onRender: ->
    @$('textarea#picture-title').autogrow()
    callback = =>
      @$('.input-append.date').datepicker().on 'changeDate', (event)=>
        @updatedPictureAttrs.created_at = new Date(event.date.valueOf())
        @$('.input-append.date').datepicker('hide')
    setTimeout(callback, 0)


  serializeData: ->
    picture: @model


  updatePicture: ->
    @updatedPictureAttrs.title = @$('#picture-title').val()
    if @updatedPictureAttrs.created_at
      @updatedPictureAttrs.created_at = new Date(
        @updatedPictureAttrs.created_at.getTime() + @model.millisecCreatedAt()
      )

    @model.set @updatedPictureAttrs
    @model.save {}, wait: true

    @close()
    false
