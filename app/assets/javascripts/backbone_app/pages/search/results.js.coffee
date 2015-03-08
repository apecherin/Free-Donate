#=require ./results_item
Pages.Search.ShowResults = Backbone.Marionette.CompositeView.extend
  template: 'fragments/search/results'
  itemView: Fragments.Search.ShowResultsItem

  initialize: (attributes)->

  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.thumbnails').append(itemView.el)

  serializeData: ->
    countResults: @collection.size()