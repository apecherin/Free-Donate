class Fragments.Vehicles.Specifications.SameVehiclesItem extends Backbone.Marionette.ItemView
  template: 'pages/vehicles/specifications/same_vehicles_item'
  tagName: 'tr'

  onRender: ->
    @$el.data('dataSheetId', @model.id)
    @$el.attr 'id', HAML.globals()['domId'](@model)

  serializeData: ->
    dataSheet: @model
    version:   @model.get('vehicle').get('version')
    vehicle:   @model.get('vehicle')