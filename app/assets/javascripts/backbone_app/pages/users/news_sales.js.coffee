class Pages.Users.NewsSales extends Backbone.Marionette.Layout
  template: 'pages/users/news_sales'

  regions:
    breadcrumb:          '#breadcrumb'

  onRender: ->
  	@breadcrumb.show new Fragments.Breadcrumb.Index collection: new Collections.Breadcrumbs.forNews('sales')
     	 