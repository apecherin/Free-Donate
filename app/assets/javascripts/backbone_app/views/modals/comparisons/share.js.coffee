class Modals.Comparisons.Share extends Backbone.Marionette.Layout
  template: 'modals/comparisons/share'

  regions:
    pictureThumbnailsGenerator:  '#picture-thumbnails-generator'

  initialize: ({@model}) ->

  onRender: ->
    @pictureThumbnailsGenerator.show new Fragments.Comparisons.Generator.VehiclesChoisenContainer
      comparisonsTable: @model

  serializeData: ->