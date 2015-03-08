#= require ./modification_property.coffee

class Pages.Vehicles.Modifications.ModificationSeparatorProperties extends  Backbone.Marionette.Layout
  template: 'pages/vehicles/modifications/modification_separator_properties'

  regions:
    propertiesPerfViewerContainer: '.properties-perf-viewer-container'
    propertiesSpecViewerContainer: '.properties-spec-viewer-container'
    propertiesDynoViewerContainer: '.properties-dyno-viewer-container'

  initialize: ({@collection, @modification, @versionProperties})->
    @perfModificationCollection = new Collections.ModificationProperties(@collection.where({is_spec: false}))
    @specModificationCollection = new Collections.ModificationProperties(@collection.where({is_spec: true}))
    @dynoModificationCollection = new Collections.ModificationProperties(@collection.where({is_dyno: true}))
    @perfModificationCollection.modification = @modification
    @specModificationCollection.modification = @modification
    @dynoModificationCollection.modification = @modification

  onRender: ->
    @propertiesPerfViewerContainer.show new Pages.Vehicles.Modifications.ModificationViewerProperties modification: @modification, collection: @perfModificationCollection, versionProperties: new Collections.VersionProperties(@versionProperties.where({is_spec: false}))
    @propertiesSpecViewerContainer.show new Pages.Vehicles.Modifications.ModificationViewerProperties modification: @modification, collection: @specModificationCollection, versionProperties: new Collections.VersionProperties(@versionProperties.where({is_spec: true}))
    @propertiesDynoViewerContainer.show new Pages.Vehicles.Modifications.ModificationViewerProperties modification: @modification, collection: @dynoModificationCollection, versionProperties: new Collections.VersionProperties(@versionProperties.where({is_dyno: true}))