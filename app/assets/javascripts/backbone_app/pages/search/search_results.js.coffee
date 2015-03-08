class Pages.Search.SearchResults extends Backbone.Marionette.Layout
  template: 'pages/search/search_results'

  regions:
    resultsList: '#results-list'
    adContainer: '.ad-container'
    searchfield: '#news-searchfield'

  initialize: ({@results, @input_value})->
    @input_value = if @input_value? then @input_value else ''


  onRender: ->
    @resultsList.show new Pages.Search.ShowResults collection: @results
    @adContainer.show new Pages.Ads.Ad_300x600
    @searchfield.show new Pages.Search.Searchfield input_value: @input_value