class Pages.Modifications.Dashboard extends Backbone.Marionette.Layout
  template: 'pages/modifications/dashboard'
  className: 'users-modifications-lists'

  regions:
    breadcrumb: '#breadcrumb'
    tabContent: '#tab_content'

  events:
    'click ul.nav-tabs li > a' : 'tabClicked'
    'click .edit-avatar' : 'goToUserProfilePage'

  initialize: ({@user, @activeTab})->
    @activeTab = if @activeTab? then @activeTab else 'my_mods'

  onRender: ->
    if @activeTab?
      callback = =>
        @$('.nav-tabs a[data-target="#' + @activeTab + '"]').tab('show')
      setTimeout(callback, 0)


    modifications = new Collections.UserModifications
    modifications.fetch data: {user_id: @user.id, type: @activeTab}, success: (modifications) =>
      @filters = {
        vehicle: {
          types:  _.keys(modifications.groupBy((ac) -> ac.get("vehicle_type"))),
          brands: _.keys(modifications.groupBy((ac) -> ac.get("vehicle_brand"))),
          models: _.keys(modifications.groupBy((ac) -> ac.get("vehicle_model")))
        },
        modification: {
          domains:    _.keys(modifications.groupBy((ac) -> ac.get("domain"))),
          categories: _.uniq(_.flatten((_.values(_.keys(modifications.groupBy((ac) -> ac.get("category"))))).map (cat) -> if cat is '[object Object]' then [] else cat.split(',')), false),
          elements:   _.uniq(_.flatten((_.values(_.keys(modifications.groupBy((ac) -> ac.get("element"))))).map (cat) -> if cat is '[object Object]' then [] else cat.split(',')), false)
        },
        user: {
          countries : _.keys(modifications.groupBy((ac) -> ac.get("user_country")))
        }
      }

      @tabContent.show new Pages.Modifications.ModificationItemLayout
        modifications: modifications,
        user: @user,
        activeTab: @activeTab,
        filters: @filters
      @$('#tab_content').show()
    @renderBreadcrumbs()

  renderBreadcrumbs: ->
    @breadcrumb.show new Fragments.Breadcrumb.Index
      collection: Collections.Breadcrumbs.forUserModifications(@user, @activeTab)

  tabClicked: (event) ->
    @$('#tab_content').hide()
    target = $(event.target)
    if target.data('target')?
      @activeTab = target.data('target').substr(1)
      @renderBreadcrumbs()
      Backbone.history.navigate Routers.Main.showUserModificationsPath(@user, @activeTab)
      @render()
    false

  goToUserProfilePage: (e) ->
    $target = $(e.currentTarget)
    userId = $target.data('user-id')
    return false unless userId
    userProfilePath = Routers.Main.showUserProfilePath(userId)
    Backbone.history.navigate(userProfilePath, true)
    false

  serializeData: ->
    user: @user