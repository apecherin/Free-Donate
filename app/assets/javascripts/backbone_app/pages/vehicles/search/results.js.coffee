#=require ./results_item
Fragments.Vehicles.Search.Results = Backbone.Marionette.CompositeView.extend
  template: 'fragments/vehicles/search/results'
  itemView: Fragments.Vehicles.Search.ResultsItem


  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.thumbnails').append(itemView.el)
