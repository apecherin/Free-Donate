Views.Mixins.editCollages = ->
  @collageMode = 'collages_edit'
  @render()
  false

Views.Mixins.editCollagesOut = ->
  @collageMode = 'collages_list'
  @render()
  false

Views.Mixins.renderCollages = (collection, collageRegion)->
  if @collageMode == 'collages_edit'
    @$('.enter-edit').hide()
    @$('.exit-edit').show()
  else
    @$('.enter-edit').show()
    @$('.exit-edit').hide()
  collageRegion.show new Fragments.Collages
    collection: collection
    canManage:  @canManage()
    mode:       @collageMode
