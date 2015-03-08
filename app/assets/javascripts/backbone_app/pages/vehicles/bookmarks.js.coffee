Pages.Vehicles.Bookmarks = Backbone.Marionette.Layout.extend
  template: 'pages/vehicles/bookmarks'

  regions:
    searchResults: '#vehicles-search-results'


  initialize: (attributes)->
    @bookmarkedVehicles = attributes.vehicles


  onRender: ->
    @searchResults.show(new Fragments.Vehicles.Search.Results(collection: @bookmarkedVehicles))
