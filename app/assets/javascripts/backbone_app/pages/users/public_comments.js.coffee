class Pages.Users.PublicComment extends Backbone.Marionette.Layout
  template: 'pages/users/public_comment'

  regions:
    breadcrumb:          '#breadcrumb'

  onRender: ->
 		@breadcrumb.show new Fragments.Breadcrumb.Index 
 			collection: new Collections.Breadcrumbs.forPublications('my_comments'), true
     	 
      