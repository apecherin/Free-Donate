class Pages.Dashboard.NewsFeedsItem extends Backbone.Marionette.Layout
  regions:
    'news_actions'    : '.news-actions'
    'changesBars'     : '.changes-bars'
    'comparisonTable' : '.comparison-table'

  getTemplate: ->
    if @model.get('target').type is 'ComparisonTable'
      "pages/dashboard/news_feeds/actions_on_comparison_table"
    else
      "pages/dashboard/news_feeds/#{@model.get('event_type')}"

  events:
#    'click .go-to-gallery'      : 'goToGallery'
#    'click .gallery-image' : 'goToGallery'
#    'click .go-to-comparison'   : 'goToComparison'
#    'click .go-to-new-vehicle'  : 'goToNewVehicle'
#    'click .go-to-part-purchase' : 'goToModification'

    'touchstart .item-content' : 'handleTouchStart'
    'touchmove .item-content' : 'handleTouchMove'
    'touchend .item-content' : 'handleTouchEnd'

    'click .slider' : 'sliderContainer'
    'click .vehicle-side-view' : 'goToComparison'

  className: 'news-feed-item-container'

  initialize: ({@myNews, @followingsNews, @followersNews})->
    @extra = @model.get('target').extra
    @startX = @endX = @deltaX = 0

  handleTouchStart: (e) ->
    if e.originalEvent.touches.length is 1
      touch = e.originalEvent.touches[0]
      @startX = touch.pageX
      @deltaX = 0
    return

  handleTouchMove: (e) ->
    if e.originalEvent.touches.length is 1
      touch = e.originalEvent.touches[0]
      @endX = touch.pageX
      @deltaX = @endX - @startX
    return

  handleTouchEnd: (e) ->
    if e.originalEvent.touches.length is 0
      if Math.abs(@deltaX) > 30
        @sliderContainer()
    return

  onRender: ->
    @bindTo MyApp.vent, 'screen_width:changed', =>
      @changeSizesAndPositionsOfElements()

#    @startComparisonSlideshow()
    @eventTypeContainers = []
#    @currentlyAnimating = false
#    @setBindings()
    setTimeout =>
      if @model.get('event_type') in ['create_vehicle', 'create_gallery', 'create_modification', 'create_part_purchase',
                                      'create_comparison_table', 'modify_comparison_table', 'add_pictures_to_gallery',
                                      'add_comments_to_picture', 'add_likes']
        if @model.get('event_type') is 'create_modification'
          @modification_properties = @model.get('target').properties
          @version_properties = @model.get('target').version_properties
          maxPropertiesToShow = 3
          if @modification_properties.length > maxPropertiesToShow
            @modification_properties = @modification_properties.slice(0, maxPropertiesToShow)
          @changesBars.show new Pages.Dashboard.ModificationPropertyBars collection: new Backbone.Collection(@modification_properties), versionProperties: @version_properties

        if @model.get('event_type') in ['create_comparison_table', 'modify_comparison_table']
          @renderTables()
          comparisonTable = new Models.ComparisonTable(id: @model.get('target').extra.id)
          comparisonTable.collection = new Collections.ComparisonTables
          comparisonTable.fetch data: {light: true}, success: =>
            @news_actions.show new Pages.Dashboard.NewsActions.ComparisonActions
              model: @model
              myNews: @myNews
              followingsNews: @followingsNews
              followersNews: @followersNews
              comparisonTable: comparisonTable

        if @model.get('event_type') is 'create_gallery'
          gallery = new Models.Gallery(id: @model.get('target').extra.id)
          gallery.url = "/vehicles/#{@model.get('target').extra.vehicle_id}/galleries/#{@model.get('target').extra.gallery_id}"
          gallery.fetch data: {light: true}, success: =>
            @news_actions.show new Pages.Dashboard.NewsActions.GalleriesActions
              model: @model
              myNews: @myNews
              followingsNews: @followingsNews
              followersNews: @followersNews
              gallery: gallery

        if @model.get('event_type') is 'create_vehicle'
          @news_actions.show new Pages.Dashboard.NewsActions.VehiclesActions
            model: @model
            myNews: @myNews
            followingsNews: @followingsNews
            followersNews: @followersNews
            vehicle: @model.get('vehicle')

        if @model.get('event_type') is 'add_pictures_to_gallery'
          picture_id = @model.get('target').extra.cover_picture_id
          picture = new Models.Picture(id: picture_id)
          picture.url = "/api/galleries/#{@model.get('target').extra.gallery_id}/pictures/#{picture_id}"
          picture.fetch data: {light: true}, success: =>
            @news_actions.show new Pages.Dashboard.NewsActions.PicturesActions
              model: @model
              myNews: @myNews
              followingsNews: @followingsNews
              followersNews: @followersNews
              picture: picture

        if @model.get('event_type') is 'create_part_purchase'
          part_id = @model.get('target').extra.id
          part_purchase = new Models.PartPurchase(id: part_id)
          part_purchase.url = "/api/modifications/#{@model.get('target').extra.modification_id}/part_purchases/#{part_id}"
          part_purchase.fetch data: {light: true}, success: =>
            @news_actions.show new Pages.Dashboard.NewsActions.PartPurchasesActions
              model: @model
              myNews: @myNews
              followingsNews: @followingsNews
              followersNews: @followersNews
              part_purchase: part_purchase

        if @model.get('event_type') is 'create_modification'
          modification_id = @extra.id
          news_actions = @news_actions
          model = @model
          myNews = @myNews
          followingsNews = @followingsNews
          followersNews = @followersNews
          modification = new Models.Modification(id: modification_id, vehicle: @model.get('vehicle'))
          modification.fetch data: {light: true}, success: ->
            news_actions.show new Pages.Dashboard.NewsActions.ModificationsActions
              model: model
              myNews: myNews
              followingsNews: followingsNews
              followersNews: followersNews
              modification: modification

        if @model.get('event_type') is 'add_comments_to_picture'
          picture_id = @model.get('target').extra.picture_id
          picture = new Models.Picture(id: picture_id)
          picture.url = "/api/galleries/#{@model.get('target').extra.gallery_id}/pictures/#{picture_id}"
          if @model.get('target').extra.is_web_picture
            picture.url = "/api/pictures/#{picture_id}/show_profile_picture"
          picture.fetch data: {light: true}, success: =>
            @news_actions.show new Pages.Dashboard.NewsActions.PictureCommentsActions
              model: @model
              myNews: @myNews
              followingsNews: @followingsNews
              followersNews: @followersNews
              picture: picture

        if @model.get('event_type') is 'add_likes'
          picture_id = @model.get('target').extra.picture_id
          picture = new Models.Picture(id: picture_id)
          picture.url = "/api/galleries/#{@model.get('target').extra.gallery_id}/pictures/#{picture_id}"
          if @model.get('target').extra.is_web_picture
            picture.url = "/api/pictures/#{picture_id}/show_profile_picture"
          picture.fetch data: {light: true}, success: =>
            @news_actions.show new Pages.Dashboard.NewsActions.LikesActions
              model: @model
              myNews: @myNews
              followingsNews: @followingsNews
              followersNews: @followersNews
              picture: picture

        if @model.get('event_type') not in ['create_modification', 'create_gallery', 'add_comments_to_picture',
                                            'add_likes', 'create_comparison_table', 'modify_comparison_table',
                                            'add_pictures_to_gallery', 'create_part_purchase', 'create_vehicle']
          @news_actions.show new Pages.Dashboard.NewsActions.Actions
            model: @model
            myNews: @myNews
            followingsNews: @followingsNews
            followersNews: @followersNews

      $eventTypes = @$('.dashboard-event-type')
      $eventTypes.each (i, eventType) =>
        $eventType = $(eventType)
        $eventTypeContainer = $eventType.closest('.content').
          siblings('.newsfeed-event-first-line').find('.dashboard-event-type-container')
        @eventTypeContainers.push($eventTypeContainer)
        $eventTypeContainer.append($eventType)
        $eventTypeContainer.find('.go-to-gallery').on('click', _.bind(this['goToGallery'], this))
        @populateComparisonTab()

      @changeSizesAndPositionsOfElements()
    , 0

  onClose: ->
    _.each @eventTypeContainers, ($container) ->
      $container.off()
    @$el.off('in-view')

  renderTables: (pair_id = 0) ->
    veh_count = @model.get('vehicles').length
    #TODO need change to 2 for start sliders and OPTIMIZE! slider
    if veh_count > 2
      pairs = []
      i = 0
      while i < veh_count - 1
        j = 1
        while j < veh_count
          if i != j
            pairs.push [
              i
              j
            ]
          j++
        i++
      pair = pairs[pair_id]
      @comparisonTable.show new Pages.Dashboard.ComparisonTable
        event_type: @model.get('event_type')
        extra: @extra
        vehicles: [@model.get('vehicles').models[pair[0]], @model.get('vehicles').models[pair[1]]]

      @$('.comparison-table').fadeIn 2000, =>
        @$('.comparison-table').delay(3500).fadeOut 2000, =>
          @renderTables(if pairs.length - 1 is pair_id then 0 else pair_id + 1)
    else
      @comparisonTable.show new Pages.Dashboard.ComparisonTable
        event_type: @model.get('event_type')
        extra: @extra
        vehicles: [@model.get('vehicles').models[0], @model.get('vehicles').models[1]]


  setBindings: ->
    @$el.on 'in-view', =>
      @currentlyAnimating = false
      @startComparisonSlideshow()

  goToGallery: ->
    gallery_id = @extra['gallery_id']
    vehicle = new Models.Vehicle(id: @extra['vehicle_id'])
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      gallery = new Models.Gallery id : gallery_id
      vehicle.get('galleries').add(gallery)
      vehicle.get('galleries').fetch success: =>
        gallery = vehicle.get('galleries')._byId[gallery_id]
        Backbone.history.navigate Routers.Main.showVehicleGalleryPath(gallery, vehicle), true
    false

  goToComparison: ->
    path = Routers.Main.showUserComparisonPath(@model.get('initiator'), new Models.ComparisonTable(@extra.table))
    Backbone.history.navigate(path, true)
    false

  goToNewVehicle: (e) ->
    $target = $(e.currentTarget)
    vehicle = new Models.Vehicle({id: $target.data('vehicle-id')})
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      Backbone.history.navigate(
        Routers.Main.showVehicleIdentificationPath(vehicle),
        true
      )
    false

  goToModification: (e) ->
    modification_id = @extra.modification_id
    vehicle = new Models.Vehicle(id: @extra.vehicle_id)
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      vehicle.get('user').fetch success: =>
        modification = new Models.Modification(id: modification_id, vehicle: vehicle)
        modification.fetch success: ->
          Backbone.history.navigate Routers.Main.showModificationsConfDomainMod1Path(modification.get('vehicle'), modification.get('change_set_id'), modification.get('change_set_name'), modification.get('domain'), modification, 'parts'), false
          MyApp.layout.content.show new Pages.Vehicles.Show
            model: vehicle
            currentTab: 'modifications'
            changeSetId:  modification.get('change_set_id')
            domainName: modification.get('domain')
            modificationId: modification.get('id')
            cps_tab: 'parts'
    false

  populateComparisonTab: ->
    numVehicles = @model.get('vehicles').size()
    @$el.closest('.item-content').find('.dashboard-comparison-tab .num-vehicles').text(numVehicles)

  startComparisonSlideshow: (delay = 2000) ->
    setTimeout(_.bind(@doStartComparisonSlideShow, this), delay)

  doStartComparisonSlideShow: ->
    if !@$el.hasClass('in-view') or @currentlyAnimating
      return false
    @currentlyAnimating = true

    $vehicle3 = @$('.vehicle-3')
    $vehicle2 = @$('.vehicle-2')
    $vehicle1 = @$('.vehicle-1')

    return unless $vehicle3.length

    vehicle2OrigPos = $vehicle2.data('orig-pos')
    vehicle3OrigPos = $vehicle3.data('orig-pos')
    $vehicle2Info = $vehicle1.siblings(".vehicle-#{vehicle2OrigPos}-info").first()
    $vehicle3Info = $vehicle1.siblings(".vehicle-#{vehicle3OrigPos}-info").first()
    @$('.current-info-bottom,.current-info-top').removeClass('current-info-bottom current-info-top')
    $vehicle2Info.fadeIn(1500).addClass('current-info-bottom')
    $vehicle3Info.fadeIn(1500).addClass('current-info-top')

    $vehicle3Img = $vehicle3.find('img')
    $vehicle2Img = $vehicle2.find('img')
    $vehicle1Img = $vehicle1.find('img')

    vehicle3Width  = parseInt($vehicle3Img.css('width'))
    vehicle3WidthNext = vehicle3Width / 1
    vehicle3Height = parseInt($vehicle3Img.css('height'))
    vehicle2Width  = parseInt($vehicle2Img.css('width'))
    vehicle2WidthNext = vehicle2Width / 1
    vehicle2Height = parseInt($vehicle2Img.css('height'))
    vehicle1Width  = parseInt($vehicle1Img.css('width'))
    vehicle1WidthNext = vehicle1Width / 1
    vehicle1Height = parseInt($vehicle1Img.css('height'))

    $vehicle3.show().animate({left: "#{if vehicle3WidthNext >= 154 then 154 - vehicle3WidthNext else Math.abs(154 - vehicle3WidthNext)}px", bottom: '34px'}, 2000).css('z-index', 1)
    @animateGrowImage($vehicle3Img, vehicle3Width, vehicle3Height, 1, 2000, { opacity: 1 })

    $vehicle2.animate({left: "#{if vehicle2WidthNext >= 130 then 130 - vehicle2WidthNext else Math.abs(130 - vehicle2WidthNext)}px", bottom: '0'}, 2000).css('z-index', 2)
    @animateGrowImage($vehicle2Img, vehicle2Width, vehicle2Height, 1, 2000)

    $vehicle1.animate({left: "#{if vehicle1WidthNext >= 34 then 34 - vehicle1WidthNext else Math.abs(34 - vehicle1WidthNext)}px", bottom: '-136px', opacity: 0}, 2000)
    @animateGrowImage($vehicle1Img, vehicle1Width, vehicle1Height, 1, 2000, { opacity: 0 })

    $vehicle1.fadeOut 2000, =>
      @shrinkImage($vehicle1Img, vehicle1Width, vehicle1Height, Math.pow(1, 3), { opacity: 0 })
      newVehicle1Width = parseInt($vehicle1Img.css('width'))
      $vehicle1.css({left: "#{if newVehicle1Width >= 172 then 172 - newVehicle1Width else Math.abs(172 - newVehicle1Width)}px", bottom: '59px', opacity: 1})
      $vehicle2Info.delay(1000).fadeOut(1000)
      $vehicle3Info.delay(1000).fadeOut(1000)

      last = @lastVehicleNum($vehicle3)
      if last > 3
        range = _.range(4, last + 1).reverse()
        @moveDownClass($vehicle3.siblings(".vehicle-#{i}").first()) for i in range

      @moveDownClass($vehicle1)
      @moveDownClass($vehicle2)
      @moveDownClass($vehicle3)
      @currentlyAnimating = false
      @startComparisonSlideshow()

  moveDownClass: ($vehicle) ->
    return unless $vehicle
    previousNum = parseInt(/vehicle-(\d)/.exec($vehicle.attr('class'))[1])
    newNum = if previousNum is 1
              @lastVehicleNum($vehicle)
            else
              previousNum - 1
    $vehicle.removeClass("vehicle-#{previousNum}").addClass("vehicle-#{newNum}")

  lastVehicleNum: ($vehicle) ->
    $vehicle.closest('.dashboard-comparison-images').data('last-vehicle-num')

  animateGrowImage: ($img, origWidth, origHeight, amt = 0.75, len = 2000, properties = {}) ->
    defaults = { width: "#{origWidth / amt}px", height: "#{origHeight / amt}px" }
    defaults = _.extend(defaults, properties)
    $img.animate(defaults, len)

  growImage: ($img, origWidth, origHeight, amt = 0.75, properties = {}) ->
    defaults = { width: "#{origWidth / amt}px", height: "#{origHeight / amt}px" }
    _.extend(defaults, properties)
    $img.css(defaults)

  shrinkImage: ($img, origWidth, origHeight, amt = 0.75, properties = {}) ->
    @growImage($img, origWidth, origHeight, 1 / amt, properties)

  changeSizesAndPositionsOfElements: (max=false) ->
    if max
      width_of_jeft_container = 640
    else
      width_of_screen = Store.get('widthOfScreen')
      width_of_jeft_container =
        if width_of_screen >= 0 and width_of_screen <= 320
          width_of_screen
        else if width_of_screen >= 321 and width_of_screen <= 642
          width_of_screen - 2
        else if width_of_screen is 643
          width_of_screen - 3
        else if width_of_screen >= 644 and width_of_screen <= 963
          width_of_screen - 4 - 320
        else if width_of_screen >= 964
          640

    @$('.slider').css('left', width_of_jeft_container - 12)

    if width_of_jeft_container is 640
      if !max
        @$('.slider').hide()
        $('#main_feeds ul').css('margin', '')
        $('.main-container').css('padding-left', '')
    else
      @$('.slider').show()
      $('#main_feeds ul').css('margin', 0)
      $('.main-container').css('padding-left', 0)

    $('#news #main_feeds').css('width', width_of_jeft_container)
    @$('.item-content').css('width', width_of_jeft_container)

  sliderContainer: () ->
    if @$('.slider').hasClass('active')
      @$('.slider').removeClass('active')
      @changeSizesAndPositionsOfElements(false)
    else
      @$('.slider').addClass('active')
      @changeSizesAndPositionsOfElements(true)

  swipeContent: (event) ->
    event.stopPropagation
    event.preventDefault
    @sliderContainer()

  swipeLeft: () ->
    console.log 'swipeleft'

  serializeData: ->
    news_feed:      @model
    event_type:     @model.get('event_type')
    extra:          @extra
    myNews:         @myNews
    followingsNews: @followingsNews
    followersNews:  @followersNews
    initiator:    @model.get('initiator')
    last_updated: @model.get('updated_at').substring(10, 0)