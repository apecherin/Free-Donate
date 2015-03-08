class Fragments.Comparisons.SocialActions extends Backbone.Marionette.ItemView
  template: 'fragments/comparisons/social_actions'

  events:
    'click .comparison-table-save-it'     : 'saveComparison'
    'click .comparison-table-delete-it'   : 'deleteComparison'
    'click .comparison-table-like-it'     : 'likeComparison'
    'click .comparison-table-unlike-it'   : 'unlikeComparison'
    'click .comparison-table-share-it'    : 'shareComparison'

  initialize: ({ @comparisonTable, @currentUser, @modelUser })->
    @bindTo(MyApp.vent, 'comparison_shares:new', => @renderSocialActions())

    @canSave = @canLike = (@currentUser && @modelUser.id isnt @currentUser.id)
    @canUnLike = Models.Ability.canUnLike(@comparisonTable)
    @ownsComparison = @currentUser and !@canSave
    @canRemoveSave = Models.Ability.canRemoveSaveComparisonTable(@comparisonTable)

  renderSocialActions: ->
    @comparisonTable.fetch success: =>
      @render()

  upperIcon: (object) ->
    @$(object).css('font-size', 25)

  likeComparison: (event) ->
    return false unless @canLike
    comparison = @comparisonTable
    return false unless comparison && @currentUser
    comparisonLike = new Models.ComparisonTableLike
      comparison_table_id: comparison.id
    comparisonLike.save null, success: =>
      @upperIcon(event.target)
      comparison.fetch success: =>
        @canUnLike = Models.Ability.canUnLike(@comparisonTable)
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
      comparison.fetch success: =>
        @canUnLike = Models.Ability.canUnLike(@comparisonTable)
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
      comparison.fetch success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveComparisonTable(@comparisonTable)
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
      comparison.fetch success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveComparisonTable(@comparisonTable)
        @render()
    false

  shareComparison: (event) ->
    MyApp.modal.show new Modals.Comparisons.Share
      model: @comparisonTable
    false

  serializeData: ->
    comparisonTable: @comparisonTable
    canLike:         @canLike
    canUnLike:       @canUnLike
    canSave:         @canSave
    canRemoveSave:   @canRemoveSave
