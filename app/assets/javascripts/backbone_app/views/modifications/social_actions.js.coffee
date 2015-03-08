class Fragments.Vehicles.Modifications.SocialActions extends Backbone.Marionette.ItemView
  template: 'fragments/modifications/social_actions'

  events:
    'click .modification-save-it'     : 'saveModification'
    'click .modification-delete-it'   : 'deleteModification'
    'click .modification-like-it'     : 'likeModification'
    'click .modification-unlike-it'   : 'unlikeModification'
    'click .modification-share-it'    : 'shareModification'

  initialize: ({ @modification, @currentUser, @modelUser })->
    @bindTo(MyApp.vent, 'modification_shares:new', => @renderSocialActions())
    @canSave = @canLike = (@currentUser && @modelUser.id isnt @currentUser.id)
    console.log @canSave
    @canUnLike = Models.Ability.canUnLike(@modification)
    @ownsModification = @currentUser and !@canSave
    @canRemoveSave = Models.Ability.canRemoveSaveModification(@modification)

  renderSocialActions: ->
    @modification.fetch success: =>
      @render()

  upperIcon: (object) ->
    @$(object).css('font-size', 25)

  likeModification: (event) ->
    return false unless @canLike
    modification = @modification
    return false unless modification && @currentUser
    modificationLike = new Models.ModificationLike
      modification_id: modification.id
    modificationLike.save null, success: =>
      @upperIcon(event.target)
      modification.fetch success: =>
        @canUnLike = Models.Ability.canUnLike(@modification)
        @render()
    false

  unlikeModification: (event) ->
    return false unless @canLike
    modification = @modification
    return false unless modification && @currentUser
    modificationUnlike = new Models.ModificationUnlike
      modification_id: modification.id
    modificationUnlike.save null, success: =>
      @upperIcon(event.target)
      modification.fetch success: =>
        @canUnLike = Models.Ability.canUnLike(@modification)
        @render()
    false

  deleteModification: (event) ->
    return false unless @canSave
    modification = @modification
    return false unless modification && @currentUser
    modificationDelete = new Models.ModificationDelete
      modification_id: modification.id
    modificationDelete.save null, success: =>
      @upperIcon(event.target)
      modification.fetch success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveModification(@modification)
        @render()
    false

  saveModification: (event) ->
    return false unless @canSave
    modification = @modification
    return false unless modification && @currentUser
    modificationSave = new Models.ModificationSave
      modification_id: modification.id
    modificationSave.save null, success: =>
      @upperIcon(event.target)
      modification.fetch success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveModification(@modification)
        @render()
    false

  shareModification: (event) ->
    MyApp.modal.show new Modals.ModificationSharesButtons
      model: @modification
    false

  serializeData: ->
    modification: @modification
    canLike:         @canLike
    canUnLike:       @canUnLike
    canSave:         @canSave
    canRemoveSave:   @canRemoveSave
