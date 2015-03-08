#= require ./custom_builder
#= require ./selector

class Fragments.Vehicles.SilhouetteShow extends Backbone.Marionette.Layout
  template: 'pages/vehicles/silhouette/show'

  regions:
    sideViewSelector: '#vehicle-side-view-selector'
    sideViewCustomBuilder: '#vehicle-side-view-custom-builder'

  initialize: ({@model, @vehicle, @side_views})->

  onRender: ->
    @sideViewSelector.show new Fragments.Vehicles.SilhouetteSelector collection: @side_views, sideViews: @side_views, vehicle: @vehicle
    @sideViewCustomBuilder.show new Fragments.Vehicles.SilhouetteCustomBuilder model: @model, vehicle: @vehicle