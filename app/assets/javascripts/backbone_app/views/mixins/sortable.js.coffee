Views.Mixins.initializeSortable = ->
  if @$('ul.thumbnails').data().sortable? then return

  @$('ul.thumbnails').sortable({tolerance: 'pointer'}).singular_sortable
    positionAttribute : 'data-position'
    update: (event, ui)=>
      obj = @collection.getByCid(ui.item.context.dataset.modelCid)
      obj.set position: ui.numericalPosition
      obj.save({})


Views.Mixins.initializeSortableItem = ->
  @$el.attr('data-position', @model.get('position'))
  @$el.attr('data-model-cid', @model.cid)
