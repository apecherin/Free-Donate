class Pages.Users.VehicleFollow extends Backbone.Marionette.Layout
  template: 'pages/users/vehicle_follow'

  regions:
    breadcrumb:          '#breadcrumb'

  onRender: ->
  	@breadcrumb.show new Fragments.Breadcrumb.Index collection: new Collections.Breadcrumbs.forMySelection('vehicle')
     