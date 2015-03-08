class Fragments.Vehicles.IdentificationShow extends Backbone.Marionette.Layout
  template: 'pages/vehicles/identification_show/identification_show'

  regions:
    mosaic:        "#mosaic-container"
    sidebar:       "#vehicle-info-sidebar"
    vehicleGauges: "#vehicle-gauges"

  initialize: ({@model, @versionAttributes})->
    @bindTo MyApp.vent, 'model_name_available:changed', => @updateVersion()
    @gauges_attrs = @model.get('accepted_properties').filter (model) ->
      v = model.get("max_value")
      (typeof (v) isnt "undefined") and (v isnt null)

    @gauges_attrs = new Collections.VersionProperties @gauges_attrs

  updateVersion: ->
    @model.fetch success: (model) =>
      @model = model
      @render()

  onRender: ->
    @sidebar.show new Fragments.Vehicles.IdentificationShow.SidebarInfo
      version:           @model.get('version')
      vehicle:           @model
      versionAttributes: @versionAttributes

    @mosaic.show new Fragments.Vehicles.IdentificationShow.Mosaic
      model: @model

    @vehicleGauges.show new Fragments.Vehicles.Gauges
      collection: @gauges_attrs

  serializeData: ->
    vehicle: @model
    properties: @model.get('accepted_properties')
    modifications: @model.get('modifications')
    gaugesAttrs: @gauges_attrs
