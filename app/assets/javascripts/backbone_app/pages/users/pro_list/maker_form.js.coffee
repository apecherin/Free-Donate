class Pages.Users.ProList.MakerForm extends Backbone.Marionette.Layout
  template: 'pages/users/pro_list/maker_form'

  events:
    'click #to-edit-mode' : 'toEditMode'
    'click #remove-item' : 'removeMaker'
    'click #save-new-maker' : 'saveMaker'
    'click #cancel-new-maker' : 'cancelEdit'

  initialize: ({@selectedMaker, @user})->
    @modeEdit = if @selectedMaker.isNew() then true else false
    @currentUser = Store.get('currentUser')
    @canEdit = @currentUser && @user.id is @currentUser.id
    @countries = []
    if @modeEdit
      @toEditMode()

  onRender: ->
    _.defer => @$('.company-country-code').chosen()
    callback = =>
      input = @$('input.company-name')
      input_street = @$('input.company-street')
      input_zipcode = @$('input.company-zipcode')
      input_city = @$('input.company-city')
      input_web = @$('input.company-website')
      vendor_type = @selectedMaker.get('type')
      input.autocomplete(
        minLength: 2
        source: (request, response) ->
          $.getJSON "/search/vendors.json?query=#{request.term}&type=#{vendor_type}&format=json", (data) ->
            response data

        select: (event, ui) ->
          item = ui.item
          id = item.id
          input.val item.name
          input.attr('data-id', id)
          input_street.val item.street
          input_zipcode.val item.zipcode
          input_city.val item.city
          $("select.company-country-code option[value=#{item.country_code}]").attr('selected','selected');
          $('.company-country-code').trigger("liszt:updated")
          input_web.val item.website
          false

        focus: (event, ui) ->
#          item = ui.item
#          id = item.id
#          input.val item.name
#          input.attr('data-id', id)
#          input_street.val item.street
#          input_zipcode.val item.zipcode
#          input_city.val item.city
#          $("select.company-country-code option[value=#{item.country_code}]").attr('selected','selected');
#          $('.company-country-code').trigger("liszt:updated");
#          input_web.val item.website

      ).data("autocomplete")._renderItem = (ul, item) ->
        searchMask = this.element.val()
        regEx = new RegExp(searchMask, 'ig')
        replaceMask = "<b style='color:#535353;'>$&</b>"
        title =  item.name
        desc = item.country
        desc = desc + if item.city isnt '' then ", #{item.city}" else ''
        desc = desc + if item.street isnt '' then ", #{item.street}" else ''
        desc = desc + if item.zipcode isnt '' then ", #{item.zipcode}" else ''

        title = title.replace(regEx, replaceMask)
        desc = desc.replace(regEx, replaceMask)
        template = "<a><div class='search-template main row-fluid'>
                                              <div class='info span12'>
                                                <div class='row-fluid title'>#{title}</div>
                                                <div class='row-fluid desc'>#{desc}</div>
                                                <div class='row-fluid website'>#{item.website}</div>
                                              </div>
                                            </div></a>"
        $("<li></li>").data("item.autocomplete", item).append(_.template(template, item)).appendTo ul

    if @modeEdit && @selectedMaker.isNew()
      setTimeout(callback, 0)


  toEditMode: ->
    @modeEdit = true
    $.getJSON '/countries.json', (countries)=>
      @countries = countries
      @render()

    false

  removeMaker: ->
    bootbox.confirm  'Are you sure?', (submit) =>
      if submit
        promise = @selectedMaker.destroy wait: true
        promise.done -> MyApp.vent.trigger('user_maker:removed')
    false

  saveMaker: ->
    @selectedMaker.set @collectData()
    name    = @selectedMaker.get('user_maker').name || ''
    country = @selectedMaker.get('user_maker').country_code
    if 0 < name.length && country
      @selectedMaker.save null, success: (maker) =>
        MyApp.vent.trigger('user_maker:created', maker.get('id'), maker.get('type'))
    false

  collectData: ->
    user_maker:
      name: @$('.company-name').val()
      website: @$('.company-website').val()
      street: @$('.company-street').val()
      zipcode: @$('.company-zipcode').val()
      city: @$('.company-city').val()
      country_code: @$('.company-country-code').val()

  cancelEdit: ->
    @modeEdit = false
    @render()
    false

  serializeData: ->
    modeEdit: @modeEdit
    canEdit: @canEdit
    selectedMaker: @selectedMaker
    countries: @countries