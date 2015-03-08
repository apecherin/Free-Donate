class Pages.Dashboard.ComparisonTable extends Backbone.Marionette.Layout
  template: 'pages/dashboard/news_feeds/comparison_table'

  initialize: ({@event_type, @extra, @vehicles})->

  onRender: ->


  serializeData: ->
    event_type: @event_type
    extra: @extra
    vehicles: @vehicles