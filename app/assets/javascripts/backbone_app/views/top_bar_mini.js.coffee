class Views.TopBarMini extends Views.TopBar
  template: 'top_bar_mini'

  events:
    'click .menu-trigger' : 'renderMenuIcon'
    'click button .icon-search' : 'searchItems'

  regions:
    unreadCountMenu: '.menu_unreadCount'

  showMenu: ->
    $('.page-container').css('position', 'relative')
    $('.page-container, .navbar-fixed-top').animate({
      duration: 1000,
      left:'+=320'
    })

  hideMenu: ->
    $('.page-container').css('position', 'inherit;')
    $('.page-container, .navbar-fixed-top').animate({
      duration: 1000,
      left:'-=320'
    })

  renderMenuIcon: ->
    i_menu = @$('i.menu')
    $body = document.body
    if i_menu.hasClass('menu-open')
      i_menu.removeClass('menu-open')
      i_menu.addClass('menu-close')
      $body.className = "menu-active"
      @showMenu()
    else
      i_menu.removeClass('menu-close')
      i_menu.addClass('menu-open')
      $body.className = ""
      @hideMenu()

  onRender: ->
    setTimeout( =>
      @$('.chosen').chosen()
      $('#appendedInputButton').val(@input_value)
      $('#appendedInputButton').autocomplete(
        minLength: 2
        source: (request, response) ->
          $.getJSON "/search/main.json?query=" + request.term + "&format=json", (data) ->
            response data
        select: (event, ui) ->
          $("#news-searchfield input").val ui.item.title
          id = ui.item.id.toNumber()
          type = ui.item.type
          if type is 'user'
            Backbone.history.navigate Routers.Main.showUserVehiclesPath(id), true
          else
            vehicle_id = ui.item.additional.vehicle_id
            user_id = ui.item.additional.user_id.toNumber()
            if vehicle_id?
              vehicle = new Models.Vehicle(id: vehicle_id.toNumber())
              vehicle.collection = new Collections.Vehicles
              vehicle.fetch success: ->
                if type is 'vehicle'
                  Backbone.history.navigate Routers.Main.showVehicleIdentificationPath(vehicle), true
                else if type is 'modification'
                  Backbone.history.navigate "#{Routers.Main.showNewVehiclePath vehicle}/modi", true
            else
              comparison = new Models.ComparisonTable(id: id)
              comparison.collection = new Collections.ComparisonTables
              comparison.fetch success: ->
                Backbone.history.navigate Routers.Main.showUserComparisonPath(user_id, comparison), true

          false

        focus: (event, ui) ->
          $("#appendedInputButton").val ui.item.title
      ).data("autocomplete")._renderItem = (ul, item) ->
        searchMask = this.element.val();
        regEx = new RegExp(searchMask, 'ig');
        replaceMask = "<b style='color:#535353;'>$&</b>";
        html = item.title.replace(regEx, replaceMask);
        template = "<a><div class='search-template main row-fluid'>
                                      <div class='span2'>
                                        <img src='#{item.image}'>
                                      </div>
                                      <div class='info span10'>
                                        <div class='row-fluid title'>#{html}</div>
                                        <div class='row-fluid type'>#{item.type}</div>
                                      </div>
                                    </div></a>"
        $("<li></li>").data("item.autocomplete", item).append(_.template(template, item)).appendTo ul
    , 0)

  searchItems: ->
    @fetchSearchResults()
    @$('i.menu').removeClass('menu-close')
    @$('i.menu').addClass('menu-open')
    $body = document.body
    $body.className = ''
    @$('input[name=query]').val('')

  fetchSearchResults: ->
    input_value = @$('input[name=query]').val()
    results = new Collections.SearchResults
    results.fetch data: {query: @$('input[name=query]').val()}, success: (results) =>
      Backbone.history.navigate 'search/results', false
      MyApp.layout.content.show new Pages.Search.SearchResults
        results: results
        input_value: input_value

  updateUnreadMessageCount: (count)->
    false