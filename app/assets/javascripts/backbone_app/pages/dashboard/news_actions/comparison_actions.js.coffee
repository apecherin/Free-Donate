class Pages.Dashboard.NewsActions.ComparisonActions extends Backbone.Marionette.Layout

  template: 'pages/dashboard/news_actions/comparison_actions'

  regions:
    follow_to_user: '.follow_to_user'
    follow_to_obj:  '.follow_to_obj'

  events:
    'click .go-to-user' : 'goToUser'

    'click .watch-comparison' : 'goToComparison'
    'click .comparison-table-save-it'     : 'saveComparison'
    'click .comparison-table-delete-it'   : 'deleteComparison'
    'click .comparison-table-like-it'     : 'likeComparison'
    'click .comparison-table-unlike-it'   : 'unlikeComparison'
    'click .comparison-table-share-it'    : 'shareComparison'

  initialize: ({ @model, @myNews, @followingsNews, @followersNews, @comparisonTable }) ->
    @current_user = @currentUser = Store.get('currentUser')
    @initiator = @modelUser = @model.get('initiator')
    @extra = @model.get('target').extra
    @event_type = @model.get('event_type')

    @canSave = @canLike = (@currentUser && @modelUser.id isnt @currentUser.id)
    @canUnLike = Models.Ability.canUnLike(@comparisonTable)
    @ownsComparison = @currentUser and !@canSave
    @canRemoveSave = Models.Ability.canRemoveSaveComparisonTable(@comparisonTable)

  onRender: ->
    if @current_user?
      @current_user.get('followings').fetch success: (followings) =>
        @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()
    else
      @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: new Collections.Followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()

    @follow_to_obj?.show new Fragments.Vehicles.SaveComparisonButton vehicle: @model.get('vehicle')

  goToComparison: ->
    path = Routers.Main.showUserComparisonPath(@model.get('initiator'), new Models.ComparisonTable(@extra.table))
    Backbone.history.navigate(path, true)
    false

  upperIcon: (object) ->
    if @$(object).hasClass('icon')
      @$(object).css('font-size', 25)
    else
      @$(object).parent('.icon').css('font-size', 25)

  likeComparison: (event) ->
    return false unless @canLike
    comparison = @comparisonTable
    return false unless comparison && @currentUser
    comparisonLike = new Models.ComparisonTableLike
      comparison_table_id: comparison.id
    comparisonLike.save null, success: =>
      @upperIcon(event.target)
      comparison.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(comparison)
        @render()
    false

  unlikeComparison: (event) ->
    return false unless @canLike
    comparison = @comparisonTable
    return false unless comparison && @currentUser
    comparisonUnlike = new Models.ComparisonTableUnlike
      comparison_table_id: comparison.id
    comparisonUnlike.save null, success: =>
      @upperIcon(event.target)
      comparison.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(comparison)
        @render()
    false

  deleteComparison: (event) ->
    return false unless @canSave
    comparison = @comparisonTable
    return false unless comparison && @currentUser
    comparisonDelete = new Models.ComparisonTableDelete
      comparison_table_id: comparison.id
    comparisonDelete.save null, success: =>
      @upperIcon(event.target)
      comparison.fetch data: {light: true}, success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveComparisonTable(comparison)
        @render()
    false

  saveComparison: (event) ->
    return false unless @canSave
    comparison = @comparisonTable
    return false unless comparison && @currentUser
    comparisonSave = new Models.ComparisonTableSave
      comparison_table_id: comparison.id
    comparisonSave.save null, success: =>
      @upperIcon(event.target)
      comparison.fetch data: {light: true}, success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveComparisonTable(comparison)
        @render()
    false

  shareComparison: (event) ->
    @comparisonTable.fetch success: =>
      MyApp.modal.show new Modals.Comparisons.Share
        model: @comparisonTable
    false

  goToUser: (e) ->
    userId = $(e.currentTarget).data('user-id')
    userId ||= @model.get('initiator').id
    Backbone.history.navigate Routers.Main.showUserProfilePath(userId), true
    false

  serializeData: ->
    news_feed:      @model
    event_type:     @event_type
    extra:          @extra
    myNews:         @myNews
    followingsNews: @followingsNews
    followersNews:  @followersNews
    initiator:      @initiator
    last_updated:   @model.get('updated_at').substring(10, 0)
    canLike:        @canLike
    canUnLike:      @canUnLike
    canSave:        @canSave
    canRemoveSave:  @canRemoveSave