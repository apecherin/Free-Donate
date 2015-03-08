class Pages.Users.PublicSale extends Backbone.Marionette.Layout
  template: 'pages/users/public_sale'

  regions:
    breadcrumb:          '#breadcrumb'

  onRender: ->
 		@breadcrumb.show new Fragments.Breadcrumb.Index 
 			collection: new Collections.Breadcrumbs.forPublications('my_sales'), true
     	 
      