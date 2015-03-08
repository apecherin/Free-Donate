class Pages.Vehicles.Search extends Backbone.Marionette.Layout
  template: 'pages/vehicles/search'

  regions:
    searchResults: '#vehicles-search-results'
    breadcrumb:          '#breadcrumb'

  events:
    'change select.chosen' : 'selectChosenChanged'
    'submit form'          : 'fetchSearchResults'
    'click .custom-search' : 'showSearchForm'

  initialize: ({@brands, @countries, @type, @tab, @query})->
    @searchParams = {type: @type}
    @bindTo(MyApp.vent, 'vehicles:search:results', @showSearchResults)
    @fetchSearchResults()

  onRender: ->
    @customSearchLink = @$('#custom-search a.custom-search')
    @customSearchForm = @$('#vehicles-search')
    @renderBreadcrumb(@tab)

    _.defer =>
      $('select').chosen no_results_text: ' ', allow_single_deselect: true

  serializeData: ->
    brands:    @brands
    countries: @countries

  selectChosenChanged: (event)->
    input = event.currentTarget
    @searchParams[input.name] = $(input).val()

  fetchSearchResults: ->
    unless @query == "undefined"
      @searchParams.query = @query
      @query = "undefined"
    else
      @searchParams.query = @$('input[name=query]').val()
    Collections.UserVehicles.search(@searchParams)
    false

  showSearchForm: ->
    @customSearchLink.hide()
    @customSearchForm.show()
    false

  hideSearchForm: ->
    @customSearchLink.show()
    @customSearchForm.hide()

  showSearchResults: (foundVehicles) ->
    @searchResults.show(new Fragments.Vehicles.Search.Results(collection: foundVehicles))
    @hideSearchForm()

  renderBreadcrumb:(@tab) ->
    @breadcrumb.show new Fragments.Breadcrumb.Index
      collection: Collections.Breadcrumbs.forVehicleSearch(@tab)