class Pages.Users.AllUsers extends Backbone.Marionette.Layout
  template: 'pages/users/allusers'

  regions:
    breadcrumb:    '#breadcrumb'

 	onRender: ->
 		@breadcrumb.show new Fragments.Breadcrumb.Index collection: new Collections.Breadcrumbs.forAllUsers()
    
    