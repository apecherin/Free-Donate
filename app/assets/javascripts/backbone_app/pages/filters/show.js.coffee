class Pages.Filters.Show extends Backbone.Marionette.Layout
  template: 'pages/filters/show'

  regions:
    breadcrumb:    '#breadcrumb'
    


 	onRender: ->
 		@breadcrumb.show new Fragments.Breadcrumb.Index collection: new Collections.Breadcrumbs.forFilters()
    