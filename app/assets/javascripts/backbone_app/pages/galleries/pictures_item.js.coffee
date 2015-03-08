#= require backbone_app/views/mixins/sortable

class Fragments.Galleries.PicturesItem extends Fragments.PicturesItem
  initializeSortable: Views.Mixins.initializeSortableItem


  initialize: ->
    super

    @bindTo @model, 'change:upload_progress', @updateUploadProgress
    @bindTo MyApp.vent, 'check:pictures:order', (picture)=>
      @model.set('position', @$el.data().position) unless @model.id == picture.id
    @bindTo @, 'render', @initializeSortable


  updateUploadProgress: ->
    @$('.progress .bar').css 'width', @model.get('upload_progress')
