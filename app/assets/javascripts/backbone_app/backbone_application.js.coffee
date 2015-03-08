Backbone.Marionette.Renderer.render = (template, data)->
  throw "Template '#{template}' not found!" unless JST[template]
  JST[template](data)


window.Store = new Backbone.Model
window.MyApp = new Backbone.Marionette.Application


MyApp.addRegions
  content: '#application'
  modal:   Views.ModalRegion
  innerModal: Views.InnerModalRegion


MyApp.addInitializer ->
  new Routers.Main

  MyApp.layout = new Layouts.Main

  # Backbone-relational issue#91
  new Models.User # otherwise the app won't work correctly for guest users

  MyApp.vent.on 'notify:success', (message)->
    Lib.Notifications.bindNoty message, 'success'

  MyApp.vent.on 'notify:error', (message)->
    Lib.Notifications.bindNoty message, 'error'

  MyApp.vent.on 'notify:warning', (message)->
    Lib.Notifications.bindNoty message, 'warning'

  MyApp.vent.on 'notify:information', (message)->
    Lib.Notifications.bindNoty message, 'information'

  MyApp.vent.on 'notify:alert', (message)->
    Lib.Notifications.bindNoty message, 'alert'

  if Seeds.currentUser
    currentUser = new Models.User(Seeds.currentUser)
    currentUser.set('bookmarkedVehicles', new Collections.UserVehicles)
    Collections.UserVehicles.bookmarks(currentUser.get('bookmarkedVehicles'))
    I18n.locale = currentUser.get('locale')
    Store.set('currentUser', currentUser)

    getUnreadCount = =>
      unreadMessageCount = new Models.UnreadMessageCount
      unreadMessageCount.fetch success: =>
        MyApp.vent.trigger 'uneadMessageCount:updated', unreadMessageCount.get('count')
    setInterval getUnreadCount, 30000

  else
    I18n.locale = $.cookie('locale') || 'en'
    Store.set('currentUser', null)

  locales = new Backbone.Collection([
    { code: "ar", label: "Arabic", available: false },
    { code: "bg", label: "Bulgarian", available: false },
    { code: "cs", label: "Czech", available: false },
    { code: "da", label: "Danish", available: false },
    { code: "en", label: "English", available: true },
    { code: "de", label: "German", available: false },
    { code: "es", label: "Spanish", available: false },
    { code: "fa", label: "Persian", available: false },
    { code: "fi", label: "Finnish", available: false },
    { code: "fr", label: "French", available: true },
    { code: "grc", label: "Greek", available: false },
    { code: "hu", label: "Hungarian", available: false },
    { code: "id", label: "Indonesian", available: false },
    { code: "it", label: "Italian", available: false },
    { code: "ja", label: "Japanese", available: false },
    { code: "ko", label: "Korean", available: false },
    { code: "nl", label: "Dutch", available: false },
    { code: "no", label: "Norwegian", available: false },
    { code: "pl", label: "Polish", available: false },
    { code: "pt", label: "Portuguese", available: false },
    { code: "ro", label: "Romanian", available: false },
    { code: "ru", label: "Russian", available: false },
    { code: "sk", label: "Slovak", available: false },
    { code: "sv", label: "Swedish", available: false },
    { code: "tr", label: "Turkish", available: false },
    { code: "vi", label: "Vietnamese", available: false },
    { code: "zh", label: "Chinese", available: false }
  ])
  Store.set('locales', locales)

  currencies = []
  currencyRates = window.Seeds.currencyRates
  _.each currencyRates, (i, el) ->
    currencies.push({code: i.code, label: i.label})

  Store.set('currencies', new Backbone.Collection(currencies))

  if @currentUser
    if $.cookie('current_currency') is undefined
      $.cookie('current_currency', @currentUser.get('currency'))
  else
    $.cookie('current_currency', 'USD') if $.cookie('current_currency') is undefined

  Store.set('currentCurrency', $.cookie('current_currency'))
  Store.set('current_currency_rate', currencyRates[Store.get('currentCurrency').toLowerCase()])

  systemsOfUnits = new Backbone.Collection([
    { code: 'EU', label: 'EU' },
    { code: 'US', label: 'US' },
    { code: 'UK', label: 'UK' },
    { code: 'IN', label: 'IN' }
  ])
  Store.set('systemsOfUnits', systemsOfUnits)

  MyApp.layout.on 'render', (layout)->
    Backbone.history.start(pushState: true)

  MyApp.content.show(MyApp.layout)

jQuery ->
  MyApp.start()
