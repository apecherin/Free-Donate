class Pages.Vehicles.Modifications.ModificationViewerProperties extends  Backbone.Marionette.Layout
  template: 'pages/vehicles/modifications/modification_viewer_properties'

  regions:
    propertiesContainer: '.properties-container'
    propertiesBarsContainer: '.properties-bars-container'

  initialize: ({@modification, @collection, @versionProperties})->
    @bindTo(MyApp.vent, 'modification_property:created', => @render())
    @bindTo(MyApp.vent, 'modification_property:removed', => @render())

  onRender: ->
    @propertiesBarsContainer.show new Pages.Vehicles.Modifications.ModificationPropertiesBars collection: @collection, versionProperties: @versionProperties
    @propertiesContainer.show new Pages.Vehicles.Modifications.ModificationProperties modification: @modification, collection: @collection, versionProperties: @versionProperties