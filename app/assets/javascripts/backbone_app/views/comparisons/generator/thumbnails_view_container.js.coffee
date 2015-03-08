class Fragments.Comparisons.Generator.ThumbnailsViewContainer extends Backbone.Marionette.Layout
  template: 'fragments/comparisons/generator/thumbnails_view_container'

  className: 'thumbnails-view-container'

  initialize: ({ @vehicle1, @vehicle2, @selectedAttr })->

  serializeData: ->
    vehicle1: @vehicle1
    vehicle2: @vehicle2
    selectedAttr: @selectedAttr