#= require ./properties_item
class Fragments.Vehicles.Specifications.Properties extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/specifications/properties'
  itemView: Fragments.Vehicles.Specifications.PropertiesItem

  initialize: ({@showControls, @group, @modifications, @vehicle})->

  itemViewOptions: ->
    showControls:  @showControls
    modifications: @modifications
    vehicle:       @vehicle

  appendHtml: (collectionView, itemView)->
    collectionView.$('tbody').append(itemView.el)

  serializeData: ->
    group: @group
    is_owner: Models.Ability.canManageVehicle(@vehicle)
