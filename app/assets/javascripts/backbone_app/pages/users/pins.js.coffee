class Pages.Users.Pins extends Backbone.Marionette.Layout
  template: 'pages/users/pins'

  regions:
    albumsList: '#albums-list'
    adContainer: '.ad-container'

  initialize: ({@userPins})->


  onRender: ->
    @albumsList.show new Pages.Albums.Albums collection: @userPins
    @adContainer.show new Pages.Ads.Ad_300x600

  serializeData: ->
    countPins: @userPins.size()