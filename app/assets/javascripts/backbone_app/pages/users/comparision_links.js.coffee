class Pages.Users.ComparisionLinks  extends Backbone.Marionette.Layout
  template: 'pages/users/comparison_links'

  regions:
    'search_area' : '#search-area'
    breadcrumb    : '#breadcrumb'

  events:
    'click .custom-search' : 'toggleSearchForm'

  initialize: ( { @comparisonTables, @user, tab, @bradcumView, @searchView } ) ->
    @tab = tab
    @currentUser = Store.get('currentUser')
    @userForAvatarRegion = if @user then @user else @currentUser
    @setBindings()
    @page = 1

  setBindings: ->
    $win = $(window)
    $doc = $(document)
    $win.on 'scroll', _.throttle( =>
      if $win.scrollTop() >= $doc.height() - $win.height() - 10
        @paginate()
    , 1500)

  paginate: ->
    return if @fetchingPaginationData
    @fetchingPaginationData = true
    newComparisons = new Collections.ComparisonTables()
    data = @searchData()
    data.page = @page + 1
    promise = newComparisons.fetch(data: data)
    promise.then (collection, response, options) =>
      unless _.isEmpty(collection)
        @page += 1
        @comparisonTables.add(collection)
        @renderTableRows()
    promise.complete =>
      @fetchingPaginationData = false

  searchData: ->
    return {} unless @searchAreaView
    _.clone(@searchAreaView.data)

  onRender: ->
    if !@searchAreaView
      @brands = new Collections.Brands()
      promise = @brands.fetch()
      promise.then (brands) =>
        @searchAreaView = new Fragments.Users.ComparisonTablesSearchArea
          brands: @brands
        @searchAreaView.on 'new_results', (newResults) =>
          @$el.find('.custom-search').click()
          @comparisonTables = newResults
          @clearTableRows()
          @renderTableRows()
        @search_area.show @searchAreaView
    @renderTableRows()
    @renderBreadcrumbs(@tab)

  onClose: ->
    if @searchAreaView
      @searchAreaView.off('new_results')
    $(window).off('scroll')

  renderTableRows: ->
    rows = new Fragments.Users.ComparisonTablesRows
      collection: @comparisonTables
      el: @$el.find('tbody')
    rows.render()

  clearTableRows: ->
    @$('tbody').html('')

  toggleSearchForm: (e) ->
    $form = $(e.currentTarget).siblings('form')
    if $form.is(':hidden')
      $form.show()
    else
      $form.hide()
    false

  renderBreadcrumbs:(@tab) ->
    @breadcrumb.show new Fragments.Breadcrumb.Index
      collection: Collections.Breadcrumbs.forPublications(@tab)

  getTitle: ->
    if @tab == 'recent'
      I18n.t('comparison_tables', scope: 'ui')
    else
      I18n.t('my_liked_comparison_tables_title', scope: 'ui')

  serializeData: ->
    title: @getTitle()
    bradcumView: @bradcumView
    searchView: @searchView
