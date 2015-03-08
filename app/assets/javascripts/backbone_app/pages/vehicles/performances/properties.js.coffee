#= require ./properties_item
class Fragments.Vehicles.Performances.Properties extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/performances/properties'
  itemView: Fragments.Vehicles.Performances.PropertiesItem

  initialize: ({@dependant_collection, @props_dependencies, @showControls, @showCurrent, @group, @current_change_set, @column, @vehicle, @modifications})->

  itemViewOptions: ->
    showControls:         @showControls
    showCurrent:          @showCurrent
    dependant_collection: @dependant_collection
    props_dependencies:   @props_dependencies
    current_change_set:   @current_change_set
    vehicle:              @vehicle
    modifications:        @modifications

  appendHtml: (collectionView, itemView)->
    collectionView.$('tbody').append(itemView.el)

  serializeData: ->
    group: @group
    showCurrent: @showCurrent
    column: @column
    is_owner: Models.Ability.canManageVehicle(@vehicle)
