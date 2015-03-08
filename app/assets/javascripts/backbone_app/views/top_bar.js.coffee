class Views.TopBar extends Backbone.Marionette.Layout
  template: 'top_bar'

  regions:
    unreadCountTop: '.top_unreadCount'
    unreadCountMenu: '.menu_unreadCount'
    topBarMini: '.top_bar_minim'

  events:
    'click .all-news'              : 'goToAllNews'
    'click .my-news-pub'           : 'goToMyNewsPub'
    'click .my-followings-news'    : 'goToMyFollowingsNews'
    'click .my-followers-news'     : 'goToMyFollowersNews'
    'click .users-vehicles'        : 'goToVehiclesSearch'
    'click .users-cars'            : 'goToVehiclesSearchCars'
    'click .users-trucks'          : 'goToVehiclesSearchTrucks'
    'click .users-bikes'           : 'goToVehiclesSearchBikes'
    'click .albums'                : 'goToAlbums'
    'click .pin-likes'             : 'goToMyLikesAlbums'
    'click .my-profile'            : 'goToMyProfile'
    'click .my-cars'               : 'goToMyCars'
    'click .my-trucks'             : 'goToMyTrucks'
    'click .my-bikes'              : 'goToMyBikes'
    'click .country-settings'      : 'goToEditMyCountry'
    'click .privacy-settings'      : 'goToEditMyPrivacy'
    'click .my-comparisons'        : 'goToMyComparisons'

    'click .imported-content'      : 'goToImportedContent'
    'click .my-public-albums'      : 'goToMyPublicAlbums'
    'click .my-private-albums'     : 'goToMyPrivateAlbums'

    'click .edit-my-profile'       : 'goToEditMyProfile'
    'click .followings'            : 'goToFollowings'
    'click .followers'             : 'goToFollowers'
    'click .blocked'               : 'goToBlocked'
    'click .sign-out'              : 'signOut'
    'click .signup'                : 'signUp'
    'click #login'                 : 'signIn'
    'click .dropdown-menu a'       : 'hideDropDown'
    'click .forgotten_password'    : 'resetPassword'
    'click .inactive .unit-system-change-link' : 'switchUnitSystem'
    'click .inactive .locale-change-link' : 'switchLocale'
    'click .inactive .currency-change-link' : 'switchCurrency'
    'click .messages'              : 'goToMessagesShow'
    'click .filter'                : 'goToFilterVehicle'
    'click .news_filter'           : 'goToNewsVehicle'
    'click .ppl_filter'            : 'goToPplFilter'
    'click .my-signatures'         : 'goToMysignature'
    'click .vehicles-follow'       : 'goToVehicleFollow'
    'click .sales-follow'          : 'goToSalesFollow'
    'click .comparison-likes'      : 'goToComparisonLikes'
    'click .recent-comparisons'    : 'goToComparisonsRecent'
    'click .all-sales'             : 'goToAllSales'
    'click .my-comments'           : 'goToMyComments'
    'click .my-sales'              : 'goToMySales'
    'click .my-pins'               : 'goToMyPins'
    'click .my-wall'               : 'goToMyWall'

    'click .my-oem'                : 'goToMyOEM'
    'click .my-suppliers'          : 'goToMySuppliers'
    'click .my-vendors'            : 'goToMyVendors'

    'click .mods-liked'            : 'goToMyLikesMods'
    'click .mods-saved'            : 'goToMySavesMods'
    'click .my-mods'               : 'goToMyMods'
    'click .my-vehicles-popular'   : 'goToMyPopularMods'
    'click .my-mods-popular'       : 'goToMostPopularMods'

    'click .accordion-inner a' : 'closeMenu'
    'click .add-new-vehicle' : 'addNewVehicle'

  initialize: ->
    @input_value = if @input_value? then @input_value else ''
    @currentUser = Store.get('currentUser')
    @currentLocaleCode = if @currentUser && @currentUser.get('locale')? then @currentUser.get('locale') else $.cookie('locale') || 'en'
    @currentCurrencyCode = Store.get('currentCurrency')
    @bindTo(MyApp.vent, 'uneadMessageCount:updated', @updateUnreadMessageCount)
    unless @currentUser?
      @bindTo MyApp.vent, 'user:created', =>
        @currentUser = Store.get('currentUser')
        @render()

  onRender: ->
    if @currentUser?
      unreadMessageCount = new Models.UnreadMessageCount
      unreadMessageCount.fetch success: =>
        count = unreadMessageCount.get('count')
        @unreadCountTop.show new Pages.Messages.UnreadCount
          count: count
        @unreadCountMenu.show new Pages.Messages.UnreadCount
          count: count

    @topBarMini.show new Views.TopBarMini

    setTimeout( =>
      @$('.chosen').chosen()
      @$('#slide-menu .chosen').chosen()
    , 0)

  closeMenu: ->
    document.body.className = ''
#    @mainSearchShow($('#main-search'))

  goToAllNews: ->
    Backbone.history.navigate 'gar/news', true
    false

  goToMyFollowingsNews: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/news/followings", true
    false

  goToMyFollowersNews: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/news/followers", true
    false

  goToMyNewsPub: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/pub/news", true
    false

  goToVehiclesSearch: ->
    Backbone.history.navigate 'gar/veh', true
    false

  goToVehiclesSearchCars: ->
    Backbone.history.navigate 'gar/veh/car', true
    false

  goToVehiclesSearchTrucks: ->
    Backbone.history.navigate 'gar/veh/truck', true
    false

  goToVehiclesSearchBikes: ->
    Backbone.history.navigate 'gar/veh/bik', true
    false

  goToMyLikesAlbums: ->
    Backbone.history.navigate Routers.Main.myLikedAlbumsPath(), true
    false

  goToAlbums: ->
    Backbone.history.navigate Routers.Main.albumsPath(), true
    false

  goToImportedContent: ->
    Backbone.history.navigate Routers.Main.myyCloudPath('import', @currentUser), true
    false

  goToMyPublicAlbums: ->
    Backbone.history.navigate Routers.Main.myyCloudPath('pub', @currentUser), true
    false

  goToMyPrivateAlbums: ->
    Backbone.history.navigate Routers.Main.myyCloudPath('priv', @currentUser), true
    false

  goToMyProfile: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserProfilePath(@currentUser), true
    false

  goToMyCars: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showMyCarsPath(@currentUser), true
    false

  goToMyTrucks: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showMyTrucksPath(@currentUser), true
    false

  goToMyBikes: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showMyBikesPath(@currentUser), true
    false


  goToEditMyProfile: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/profile/info", true

    false

  goToEditMyCountry: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/profile/geoloc", true

    false

  goToEditMyPrivacy: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/profile/priva", true
    false

  goToFollowings: ->
    Backbone.history.navigate Routers.Main.showMyPeopleFollowingsPath(), true
    false

  goToFollowers: ->
    Backbone.history.navigate Routers.Main.showMyPeopLeFollowersPath(), true
    false

  goToBlocked: ->
    Backbone.history.navigate Routers.Main.showMyPeopleBlockedPath(), true
    false

  goToMyComparisons: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showMyComparisonsHerePath(), true
    false

  hideDropDown: (e)->
    $(e.target).parents('.dropdown').removeClass('open')
    false

  resetPassword: ->
    MyApp.modal.show new Modals.Users.Resetpassword
    false

  signOut: ->
    if @currentUser?
      bootbox.confirm "Are you sure?",
        (submit)=>
          if submit
            # TODO: better is user#sign_out
            $.ajax(type: 'DELETE', url:  '/api/user_accounts/sign_out')
              .success (data)=>
                Store.set 'currentUser', null
                window.location.replace '/'

    false

  signUp: ->
#    MyApp.layout.content.show new Pages.Users.New(model: new Models.User)
    Backbone.history.navigate Routers.Main.registrationPath(), true
    false

  signIn: ->
    Backbone.history.navigate Routers.Main.loginPath(), true
    false

  goToMessagesShow: ->
    Backbone.history.navigate Routers.Main.showMyPeopleMessagesPath(), true
    false

  goToFilterVehicle: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/profile/filters/veh", true
    false

  goToPplFilter: ->
    Backbone.history.navigate "usr/#{Store.get('currentUser').id}/pple/filters", true
    false

  goToNewsVehicle: ->
    if @currentUser?
      Backbone.history.navigate "usr/#{Store.get('currentUser').id}/profile/filters/news", true
    false

  goToMysignature:->
    Backbone.history.navigate Routers.Main.showMysignaturePath(), true
    false

  goToVehicleFollow:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.vehicleFollowPath(), true
    false

  goToSalesFollow:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.SalesFollowPath(), true
    false

  goToComparisonLikes:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.ComparisonLikesPath(), true
    false

  goToComparisonsRecent:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.ComparisonsRecentPath(), true
    false

  goToAllSales:->
    Backbone.history.navigate Routers.Main.allSalesPath(), true
    false

  goToMyComments:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.myCommentPath(), true
    false

  goToMySales:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.mySalesPath(), true
    false

  goToMyPins:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserPinsPath(@currentUser), true
    false

  goToMyWall:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.myVehiclesMenuPath(), true
    false

  goToMyOEM:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserProListPath(@currentUser, 'oem'), true
    false

  goToMySuppliers:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserProListPath(@currentUser, 'suppliers'), true
    false

  goToMyVendors:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserProListPath(@currentUser, 'vendors'), true
    false

  goToMyLikesMods:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserModificationsPath(@currentUser, 'my_likes'), true
    false

  goToMySavesMods:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserModificationsPath(@currentUser, 'my_saves'), true
    false

  goToMyMods:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserModificationsPath(@currentUser, 'my_mods'), true
    false

  goToMyPopularMods:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserModificationsPath(@currentUser, 'my_populars'), true
    false

  goToMostPopularMods:->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showUserModificationsPath(@currentUser, 'most_populars'), true
    false

  switchUnitSystem: (e) ->
    unless @currentUser
      MyApp.vent.trigger 'notify:error', I18n.t('switch_locale_error', scope: 'top_bar')
      return false
    oldSys = @currentUser.get('system_of_units_code')
    newSys = $(e.currentTarget).data('unit-system')
    return false if oldSys == newSys
    @currentUser.set('system_of_units_code', newSys)
    promise = @currentUser.save({}, wait: true)
    promise.done ->
      location.reload(true)

  switchLocale: (e) ->
    oldLoc = @currentLocaleCode
    newLoc = $(e.currentTarget).data('locale')
    return false if oldLoc == newLoc
    $.cookie('locale', newLoc)
    if @currentUser
      @currentUser.set('locale', newLoc)
      promise = @currentUser.save({}, wait: true)
      promise.done ->
        location.reload(true)
    else
      location.reload(true)

  switchCurrency: (e) ->
    oldCurrency = @currentCurrencyCode
    newCurrency = $(e.currentTarget).data('currency')
    return false if oldCurrency == newCurrency
    $.cookie('current_currency', newCurrency)
    if @currentUser
      @currentUser.set('currency', newCurrency)
      promise = @currentUser.save({}, wait: true)
      promise.done ->
        location.reload(true)
    else
      location.reload(true)

  updateUnreadMessageCount: (count)->
    @unreadCountTop.show new Pages.Messages.UnreadCount
      count: count
    @unreadCountMenu.show new Pages.Messages.UnreadCount
      count: count

  addNewVehicle: ->
    if @currentUser?
      Backbone.history.navigate Routers.Main.showNewVehiclesPath(), true
    else
      Backbone.history.navigate Routers.Main.loginPath(), true

#  mainSearch: (event) ->
#    event.stopPropagation()
#    btn = $(event.currentTarget)
#    @mainSearchShow(btn)
#
#    false
#
#  mainSearchShow : (btn) ->
#    input = @$('.input-append')
#    if btn.hasClass('search-input-active')
#      btn.removeClass('search-input-active')
#      input.hide()
#    else
#      btn.addClass('search-input-active')
#      input.show()

  serializeData: ->
    locales:              Store.get('locales')
    currencies:           Store.get('currencies')
    currentUser:          @currentUser
    currentLocaleCode:    @currentLocaleCode
    currentCurrencyCode:  @currentCurrencyCode