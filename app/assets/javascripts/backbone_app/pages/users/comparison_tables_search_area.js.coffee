class Fragments.Users.ComparisonTablesSearchArea extends Backbone.Marionette.ItemView
  template: 'pages/users/comparison_tables_search_area'

  events:
    'click .form-actions .btn' : 'searchForComparisons'

  initialize: ({@brands}) ->
    @data = {}

  searchForComparisons: ->
    oldData = @data
    @data = @collectData()
    if _.isEqual(oldData, @data)
      return false
    comparisons = new Collections.ComparisonTables()
    promise = comparisons.fetch({data: @data})
    promise.then =>
      @trigger('new_results', comparisons)
    false

  collectData: ->
    keywords = @$el.find('input[type=text]').val()
    brand_id = @$el.find('select.chosen').val()
    data = {}
    if keywords
      data.query = keywords
    if brand_id
      data.brand_id = brand_id
    data

  serializeData: ->
    brands: @brands.sortBy @brands.byNameComparator
