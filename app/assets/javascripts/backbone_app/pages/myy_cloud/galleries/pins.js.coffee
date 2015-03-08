class Pages.MyyCloud.Pins extends Backbone.Marionette.Layout
  template: 'pages/myy_cloud/galleries/pins'

  regions:
    albumsList: '#albums-list'
    adContainer: '.ad-container'

  initialize: ({@userPins})->


  onRender: ->
    @albumsList.show new Pages.MyyCloud.Galleries collection: @userPins
    @adContainer.show new Pages.Ads.Ad_300x600