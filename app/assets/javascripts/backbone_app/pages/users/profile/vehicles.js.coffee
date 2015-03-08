class Fragments.Users.Profile.Vehicles extends Backbone.Marionette.CompositeView
  template: 'fragments/users/profile/vehicles'
  itemView: Fragments.Users.Profile.VehiclesItem

  events:
    'click .add-vehicle' : 'addVehicle'
    'click .all-vehicles': 'showAllVehicles'

  initialize: ({@user})->

  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.thumbnails').append(itemView.el)

  addVehicle: ->
    Backbone.history.navigate('/vehicles/new', true)
    false

  showAllVehicles: ->
    path = Routers.Main.showUserVehiclesPath(@user)
    Backbone.history.navigate(path, true)
    false

  serializeData: ->
    canManage: Models.Ability.canManageUser(@user)
