Fragments.Vehicles.Search.ResultsItem = Backbone.Marionette.ItemView.extend
  template:  'fragments/vehicles/search/results_item'
  tagName:   'li'

  events:
    'click a.thumbnail' : 'showVehicle'

  onRender: ->
    @$el.attr 'id', HAML.globals()['domId'](@model)

  showVehicle: ->
    Backbone.history.navigate Routers.Main.showVehicleIdentificationPath(@model), true
    false

  serializeData: ->
    vehicle:    @model
    caption:    @model.longLabel()
    subcaption: "#{@model.get('version')?.get('production_year') || ''}"
