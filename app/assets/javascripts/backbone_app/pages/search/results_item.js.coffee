Fragments.Search.ShowResultsItem = Backbone.Marionette.ItemView.extend
  template:  'fragments/search/results_item'
  tagName:   'li'

  events:
    'click .main' : 'showItem'

  initialize: (attributes)->

  onRender: ->
    @$el.attr('class', 'row-fluid')

  showItem: ->
    id = @model.get('id').toNumber()
    type = @model.get('type')
    if type is 'user'
      Backbone.history.navigate Routers.Main.showUserVehiclesPath(id), true
    else
      vehicle_id = @model.get('additional').vehicle_id
      user_id = @model.get('additional').user_id.toNumber()
      if vehicle_id?
        vehicle = new Models.Vehicle(id: vehicle_id.toNumber())
        vehicle.collection = new Collections.Vehicles
        vehicle.fetch success: ->
          if type is 'vehicle'
            Backbone.history.navigate Routers.Main.showVehicleIdentificationPath(vehicle), true
          else if type is 'modification'
            Backbone.history.navigate "#{Routers.Main.showNewVehiclePath vehicle}/modi", true
      else
        comparison = new Models.ComparisonTable(id: id)
        comparison.collection = new Collections.ComparisonTables
        comparison.fetch success: ->
          Backbone.history.navigate Routers.Main.showUserComparisonPath(user_id, comparison), true

    false

  serializeData: ->
    searchResult: @model
