#= require ./modification_property_bar.coffee

class Pages.Vehicles.Modifications.ModificationPropertiesBars extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/modifications/modification_properties_bars'
  itemView: Pages.Vehicles.Modifications.ModificationPropertyBar
  className: 'modification-properties-bars row-fluid'

  initialize: ({@collection, @versionProperties})->

  itemViewOptions: ->
    versionProperties:   @versionProperties

  appendHtml: (collectionView, itemView)->
    collectionView.$('.properties-bars-container').append itemView.el