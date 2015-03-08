class Fragments.Users.ComparisonTablesRow extends Backbone.Marionette.ItemView
  template: 'pages/users/comparison_tables_row'
  tagName: 'tr'

  events:
    'click .vehicle-img'                : 'showVehicle'
    'click .edit-avatar'                : 'showUser'
    'click .comparision_num'            : 'showComparisonTable'
    'click .comparison-table-save-it'   : 'saveComparison'
    'click .comparison-table-like-it'   : 'likeComparison'
    'click .comparison-table-delete-it' : 'deleteComparison'
    'click .comparison-table-unlike-it' : 'unlikeComparison'

  initialize: ->
    @currentUser = Store.get('currentUser')
    @modelUser = @model.get('user')
    @canSave = @canLike = (@currentUser && @modelUser.id isnt @currentUser.id)
    @ownsComparison = @currentUser and !@canSave
    @canUnLike = Models.Ability.canUnLike(@model)
    @canRemoveSave = Models.Ability.canRemoveSaveComparisonTable(@model)

  onRender: ->
    @$el.attr 'id', HAML.globals()['domId'](@model)
    @$('.vehicle-img').tooltip()
    _.defer =>
      labelHeight = @$('.comparison-label-data a').height()
      if labelHeight > 45
        @$('.comparison-label-data').css({height: "#{labelHeight + 5}px"})

  showVehicle: (event) ->
    $target = $(event.currentTarget)
    $link = if $target.hasClass('vehicle') then $target else $target.closest('.vehicle')
    comparisonTable = @model
    vehicle = comparisonTable.get('vehicles').get $link.data 'id'
    Backbone.history.navigate Routers.Main.showVehicleIdentificationPath(vehicle), true
    false

  showUser: (event) ->
    $target = $(event.currentTarget)
    userId = $target.data('user-id')
    path = Routers.Main.showUserProfileWallsPath(userId)
    Backbone.history.navigate path, true
    false

  showComparisonTable: (event) ->
    Backbone.history.navigate Routers.Main.showUserComparisonPath @modelUser, @model, true
    MyApp.layout.content.show new Pages.ComparisonTables.Show model: @model
    false

  saveComparison: (event) ->
    comparison = @model
    return false unless comparison && @currentUser
    comparisonSave = new Models.ComparisonTableSave
      comparison_table_id: comparison.id
    comparisonSave.save null, success: =>
      comparison.fetch success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveComparisonTable(@model)
        @render()
    false

  likeComparison: (event) ->
    comparison = @model
    return false unless comparison && @currentUser
    comparisonLike = new Models.ComparisonTableLike
      comparison_table_id: comparison.id
    comparisonLike.save null, success: =>
      comparison.fetch success: =>
        @canUnLike = Models.Ability.canUnLike(@model)
        @render()
    false

  unlikeComparison: (event) ->
    comparison = @model
    return false unless comparison && @currentUser
    comparisonUnlike = new Models.ComparisonTableUnlike
      comparison_table_id: comparison.id
    comparisonUnlike.save null, success: =>
      comparison.fetch success: =>
        @canUnLike = Models.Ability.canUnLike(@model)
        @render()
    false

  deleteComparison: (event) ->
    comparison = @model
    return false unless comparison && @currentUser
    comparisonDelete = new Models.ComparisonTableDelete
      comparison_table_id: comparison.id
    comparisonDelete.save null, success: =>
     comparison.fetch success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveComparisonTable(@model)
        @render()
    false

  serializeData: ->
    comparison: @model
    canSave: @canSave
    canLike: @canLike
    canUnLike: @canUnLike
    canRemoveSave: @canRemoveSave