class Pages.Vehicles.UserVehicleMenu extends Backbone.Marionette.ItemView

  getTemplate: ->
    "pages/vehicles/vehicle_menu"

  events:
    'click .users-vehicles'              : 'goToVehiclesSearch'

  goToVehiclesSearch: ->
    Backbone.history.navigate 'gar/veh', true
    false