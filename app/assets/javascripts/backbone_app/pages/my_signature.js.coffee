class Pages.Users.Signature extends Backbone.Marionette.Layout
  template: 'pages/my_signature'

  regions:
    breadcrumb:          '#breadcrumb'

  onRender: ->
  	@breadcrumb.show new Fragments.Breadcrumb.Index collection: new Collections.Breadcrumbs.forMySignature('my_signature')