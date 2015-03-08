#= require ./collages_item

class Fragments.Collages extends Backbone.Marionette.CompositeView
  template: 'fragments/collages/collages'
  itemView : Fragments.CollagesItem

  events:
    'click .add-collage'    : 'addCollage'

  initialize: ({@canManage, @mode})->
    @modeEdit = if @mode == 'collages_edit' then true else false
    @itemViewOptions = =>
      modeEdit: @modeEdit

  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.collages').append(itemView.el)

  onRender: ->
    @showAddButton() if @modeEdit

  addCollage: ->
    if @collection.gallery?
      collageAttrs =
        gallery: @collection.gallery
      collage = new Models.Collage
    if @collection.profile?
      collageAttrs =
        profile: @collection.profile
      collage = new Models.ProfileCollage

    collage.modeEdit = true
    collage.set collageAttrs
    collage.save {}, wait: true, success: (model, response) =>
      @render()

    false

  hideAddButton: ->
    @$('.btn-group.collage-buttons').hide()
    @$('.btn.edit-controls').hide()

  showAddButton: ->
    @$('.btn-group.collage-buttons').show()
    @$('.btn.edit-controls').show()

  serializeData: ->
    canManage: @canManage
