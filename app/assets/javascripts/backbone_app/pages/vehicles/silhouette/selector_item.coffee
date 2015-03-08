class Fragments.Vehicles.SilhouetteSelectorItem extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/silhouette/selector_item'

  events:
    'click .selected .save' : 'saveSideView'

  initialize: ({@vehicle})->

  onRender: ->
    @$el.attr 'id', HAML.globals()['domId'](@model)

  saveSideView: ->
    @vehicle.set side_view: @model
    @vehicle.save null,
      wait: true
      success: =>
        @render()
    false

  serializeData: ->
    side_view: @model
    isCurrent: @vehicle.get('side_view')?.get('id') is @model.id