class Pages.MyyCloud.SoftwareSetup  extends Backbone.Marionette.ItemView
  template: 'pages/myy_cloud/software_setup'

  getBookmarklet: ->
    view = Backbone.Marionette.ItemView.extend
      template: 'bookmarklet'
      serializeData: ->
        srcHost: window.location.host
        srcHostParam: 'host=' + encodeURIComponent(window.location.host)
        userIdParam: 'prof=' + encodeURIComponent(Store.get('currentUser').get('id'))
    bookmarkletSrc = new view
    bookmarkletSrc.render()
    bookmarkletSrc.$el.text().replace /\s+/g, ""

  serializeData: ->
    bookmarklet: @getBookmarklet()