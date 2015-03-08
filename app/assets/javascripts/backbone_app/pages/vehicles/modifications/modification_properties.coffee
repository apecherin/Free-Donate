#= require ./modification_property.coffee

class Pages.Vehicles.Modifications.ModificationProperties extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/modifications/modification_properties'
  itemView: Pages.Vehicles.Modifications.ModificationProperty
  className: 'modification-properties'

  events:
    'click .add-modification-property' : 'addModificationProperty'

  initialize: ({@modification, @collection, @versionProperties})->
    @versionPropertyNames = @versionProperties.pluck('name')
    @propertyDefinitions = _.extend {}, Seeds.propertyDefinitions
    for name in @collection.pluck('name')
      delete @propertyDefinitions[name]
    for name, unit of @propertyDefinitions
      delete @propertyDefinitions[name] if name not in @versionPropertyNames

  itemViewOptions: ->
    versionProperties:   @versionProperties
    propertyDefinitions: @propertyDefinitions

  appendHtml: (collectionView, itemView)->
    collectionView.$('.properties-container').append itemView.el

  addModificationProperty: ->
    return false if $.isEmptyObject @propertyDefinitions
    MyApp.vent.trigger 'modification:mode_edit:active'
    @collection.push new Models.ModificationProperty
    false

  serializeData: ->
    modificationProperties: @collection
    versionProperties:   @versionProperties
    propertyDefinitions: @propertyDefinitions
    showControls: Models.Ability.canManageModification(@modification)