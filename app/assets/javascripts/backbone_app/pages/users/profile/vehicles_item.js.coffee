class Fragments.Users.Profile.VehiclesItem extends Backbone.Marionette.ItemView
  template:  'fragments/users/profile/vehicle_item'
  tagName:   'li'

  events:
    'click a.thumbnail' : 'showVehicle'

  initialize: ->
    @version = @model.get('version')

  showVehicle: ->
    Backbone.history.navigate Routers.Main.showVehicleIdentificationPath(@model), true
    false

  serializeData: ->
    vehicle: @model
    caption: @model.longLabel()
    subcaption: "#{@version.get('production_year') || ''}"
    ownership: @model.get 'ownership'
    count_modifications: @model.get 'count_modifications'
    count_pictures: @model.get 'count_pictures'