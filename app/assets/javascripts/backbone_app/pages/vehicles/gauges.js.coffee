#= require ./gauge_item.js.coffee
class Fragments.Vehicles.Gauges extends Backbone.Marionette.CompositeView
  template: 'pages/vehicles/gauges'
  itemView: Fragments.Vehicles.GaugeItem

  initialize: ({})->

  appendHtml: (collectionView, itemView)->
    unless typeof itemView.current_unit == 'energy'
      collectionView.$('.gauges').append(itemView.el)
