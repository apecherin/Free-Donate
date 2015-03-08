#= require ./identification_show
class Fragments.Vehicles.IdentificationShow.SidebarInfo extends Backbone.Marionette.Layout
  template: 'pages/vehicles/identification_show/sidebar_info'

  events:
    'click .edit-data' : 'editData'
    'click .edit-thumbnail' : 'editPictures'
    'click .carousel-button-right' : 'carouselRight'
    'click .carousel-button-left' : 'carouselLeft'
    'click .bubble-comment-avatar-link' : 'goToUserProfile'

  regions:
    'add_prewritten_comment' : '.version-add-prewritten-comment'

  initialize: ({@version, @vehicle, @versionAttributes}) ->
    @generation = @version.get('generation')
    @currentUser = Store.get('currentUser')

  onRender: ->
    @showPrewrittenVersionCommentsRegion()
    @$('.bubble-comment-avatar').popover('show')
    @auto_right(".carousel")

  showPrewrittenVersionCommentsRegion: ->
    region = new Fragments.Vehicles.AddPrewrittenVersionComment
      model: @version
      currentUser: @currentUser
    @add_prewritten_comment.show region

  editData: ->
    $('.show-identification').click()
    false

  editPictures: ->
    $("html, body").animate({ scrollTop: 250 }, "slow")
    $('.lock-unlock').click()
    false

  rowGroups: ->
    # [1...5] (exclusive)
    range = _.range(1, 5)
    rowGroups = []
    rowGroups.push(this['rowGroup' + i]()) for i in range
    rowGroups

  rowGroup1: ->
    [started_at, finished_at] = [@generation.get('started_at'), @generation.get('finished_at')]
    if started_at && finished_at
      suffix = " (#{started_at} - #{finished_at})"
    else
      suffix = ''
    if @version.get('vehicle_type') is 'motorcycle'
      {
        brand: @version.get('brand')?.get('name')
        model_type: @version.get('name')
        version_bike: @version.get('second_name')
        model_year: @version.get('production_year')
      }
    else
      {
        brand: @version.get('brand')?.get('name')
        model_type: @version.get('model')?.get('name')
        version: @version.get('name')
        model_year: @version.get('production_year')
      }

  rowGroup2: ->
    {
#      energy: @version.get('energy')
#      transmission_numbers: @version.get('transmission_numbers')
#      transmission_type: @version.get('transmission_type')
    }

  rowGroup3: ->
    if @version.get('vehicle_type') is 'motorcycle'
      {
        category: @version.get('body')
        market_version: @version.get('market_version_name')
      }
    else
      {
        body: @version.get('body')
        doors: @version.get('doors')
        market_version: @version.get('market_version_name')
      }

  rowGroup4: ->
    ownership = @vehicle.get('ownership')
    year = ownership.get('year')
    {
      status: {
        text: ownership.get('status')
        year: year
      },
      owner_name: ownership.get('owner_name')
    }

  translateGlobalAttr: (attr, attrVal) ->
#    translations = @versionAttributes.get('global_select_options_translations')?[attr]
    translations = I18n.lookup("data.global_select_option.#{@vehicle.get('type')}")[attr]

    if translations? and translations[attrVal]?
      translations[attrVal]
    else
      attrVal

  leftCarusel: (carusel) ->
    block_width = $(carusel).find(".comment").outerWidth()
    $(carusel).find(".carousel-items .comment").eq(-1).clone().prependTo $(carusel).find(".carousel-items")
    $(carusel).find(".carousel-items").css left: "-" + block_width + "px"
    $(carusel).find(".carousel-items .comment").eq(-1).remove()
    $(carusel).find(".carousel-items").animate
      left: "0px"
    , 200
    return


  rightCarusel: (carusel) ->
    block_width = $(carusel).find(".comment").outerWidth()
    $(carusel).find(".carousel-items").animate
      left: "-" + block_width + "px"
    , 200, ->
      $(carusel).find(".carousel-items .comment").eq(0).clone().appendTo $(carusel).find(".carousel-items")
      $(carusel).find(".carousel-items .comment").eq(0).remove()
      $(carusel).find(".carousel-items").css left: "0px"
      return
    return

  auto_right: (carusel) ->
    carusel = @$(carusel)
    setInterval (->
      unless carusel.is(".hover")
        block_width = carusel.find(".comment").outerWidth()
        carusel.find(".carousel-items").animate
          left: "-" + block_width + "px"
        , 900, ->
          carusel.find(".carousel-items .comment").eq(0).clone().appendTo carusel.find(".carousel-items")
          carusel.find(".carousel-items .comment").eq(0).remove()
          carusel.find(".carousel-items").css left: "0px"
          return
    ), 6000

  carouselRight: (event) ->
    carusel = @$(event.currentTarget ).parents(".carousel")
    @rightCarusel(carusel)
    false

  carouselLeft: (event) ->
    carusel = @$(event.currentTarget ).parents(".carousel")
    @leftCarusel(carusel)
    false

  goToUserProfile: (e) ->
    $target = $(e.currentTarget)
    userId = $target.data('user-id')
    path = Routers.Main.showUserProfilePath(userId)
    Backbone.history.navigate path, true
    false


  serializeData: ->
    rowGroups: @rowGroups()
    canManage: Models.Ability.canManageVehicle(@vehicle)
    aliases: @vehicle.aliases()
    version: @version
    vehicle: @vehicle
    translateGlobalAttr: _.bind(@translateGlobalAttr, this)
    currentUser: @currentUser
    status_approved: @vehicle.get('approved')
