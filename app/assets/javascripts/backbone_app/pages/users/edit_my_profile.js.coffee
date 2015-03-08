class Pages.Users.EditMyProfile extends Backbone.Marionette.Layout
  template: 'pages/edit_my_profile'

  events:
    'click ul.nav-tabs li > a' : 'tabClicked'

    'change form input'  : 'inputChanged'
    'click .edit-avatar' : 'avatarClicked'
    'change select'      : 'saveUser'

  regions:
    breadcrumb       : '#breadcrumb'

  initialize: ({@countries, @currentTab})->

  tabClicked: (event)->
    target = $(event.target)
    tab = target.attr('href').substr(1)

    @renderBreadcrumbs(tab)
    target.tab('show')
    false

  avatarClicked: (event)->
    $('input[type=file]').click()
    false

  collectData: ->
    result =
      system_of_units_code: @$('select[name=system_of_units]').val()
      locale:               @$('select[name=locale]').val()
      dob:                  @$('select[name="user[dob]"]').val()
      gender:               @$('select[name="user[gender]"]').val()
      country_code:         @$('select[name=country_code]').val()
      currency:             @$('select[name=currency]').val()

  saveUser: ->
    @model.set @collectData()
    @model.save null,
      wait: true
      success: ->
        location.reload(true)

  inputChanged: (event)->
    input = event.target
    if input.name isnt ''
      @model.set input.name, if input.type == 'checkbox' then input.checked else input.value
      @model.save {}

  onRender: ->

    callback = =>
      @currentTab = if ["info", "geoloc", "priva"].indexOf(@currentTab) == -1 then "info" else @currentTab
      @renderBreadcrumbs(@currentTab)
      $('select').chosen(no_results_text: ' ')

      $('input[type=file]').fileupload
        done: (event, data)=>
          avatar = data.result
          @model.set(avatarUrl: avatar.url)
          @$('.avatar img').prop('src', avatar.url)

      if @currentTab?
        @$("a[href=\"##{@currentTab}\"]").tab('show')

    setTimeout(callback, 0)

  renderBreadcrumbs:(tab) ->
    Backbone.history.navigate Routers.Main.editMyProfilePath(tab)
    @breadcrumb.show new Fragments.Breadcrumb.Index
      collection: new Collections.Breadcrumbs.forEditProfile(tab)

  dob: ->
    _.range(1950, (new Date().getFullYear() + 1)).reverse()

  serializeData: ->
    user:           @model
    countries:      @countries
    currentUser:    Store.get('currentUser')
    systemsOfUnits: Store.get('systemsOfUnits')
    dob:            @dob
    locales:        Store.get('locales')
    currencies:     Store.get('currencies')