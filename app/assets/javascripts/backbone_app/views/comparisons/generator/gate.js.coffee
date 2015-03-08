class Fragments.Comparisons.Generator.Gate extends Backbone.Marionette.Layout
  template: 'fragments/comparisons/generator/gate'

  regions:
    thumbnailsViewContainer: '#thumbnails-view-container'

  initialize: ({ @vehicle1, @vehicle2, @selectedAttr })->

  onRender: ->
    @thumbnailsViewContainer.show new Fragments.Comparisons.Generator.ThumbnailsViewContainer
      vehicle1: @vehicle1
      vehicle2: @vehicle2
      selectedAttr: @selectedAttr