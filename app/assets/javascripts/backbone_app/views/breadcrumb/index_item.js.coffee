Fragments.Breadcrumb.IndexItem = Backbone.Marionette.ItemView.extend
  template  : 'fragments/breadcrumb/index_item'
  tagName   : 'li'

  events:
    'click a': 'handleClick'

  initialize: ->
    @bindTo @model, 'change:text', @render

  onRender: ->
    @isActive() && @$el.addClass('active')

  isActive: ->
    @model.collection.indexOf(@model) == @model.collection.size() - 1

  handleClick: ->
    @model.get('callback').call() if @model.get('callback')?
    false

  serializeData: ->
    breadcrumb: @model
    isActive  : @isActive()
