class Layouts.Main extends Backbone.Marionette.Layout
  template: 'layouts/main'

  regions:
    topBar:  '#top-bar'
    content: '#content'
    navSlideMenu: 'nav#slide-menu'

  initialize: ->
    $(window).on('resize', @resizeWin)
    @withoutTopBar = false
    Store.set('widthOfScreen', $(window).width())
    @on('item:rendered', @renderSubViews)

    $(window).resize ->
      clearTimeout @resizeTO if @resizeTO
      @resizeTO = setTimeout(->
        Store.set('widthOfScreen', $(window).width())
        MyApp.vent.trigger 'screen_width:changed'
        return
      , 500)
      return

  renderSubViews: ->
    top_view = new Views.TopBar
    @topBar.show(top_view) unless @withoutTopBar
    @navSlideMenu.show new Views.SlideMenu

  serializeData: ->
    locales:              Store.get('locales')
    currencies:           Store.get('currencies')
    currentUser:          @currentUser
    currentLocaleCode:    @currentLocaleCode
    currentCurrencyCode:  @currentCurrencyCode