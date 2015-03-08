class Pages.Dashboard.NewsActions.ModificationsActions extends Backbone.Marionette.Layout

  template: 'pages/dashboard/news_actions/modifications_actions'

  regions:
    follow_to_user: '.follow_to_user'
    follow_to_obj:  '.follow_to_obj'

  events:
    'click .go-to-user' : 'goToUser'

    'click .watch-modification'     : 'goToModification'
    'click .modification-like-it'   : 'likeModification'
    'click .modification-unlike-it' : 'unlikeModification'
    'click .modification-save-it'   : 'saveModification'
    'click .modification-delete-it' : 'deleteModification'
    'click .modification-share-it'  : 'shareModification'

  initialize: ({ @model, @myNews, @followingsNews, @followersNews, @modification }) ->
    @current_user = @currentUser = Store.get('currentUser')
    @initiator = @modelUser = @model.get('initiator')
    @extra = @model.get('target').extra
    @event_type = @model.get('event_type')

    @canSave = @canLike = (@currentUser && @modelUser.id isnt @currentUser.id)
    @canUnLike = Models.Ability.canUnLike(@modification)
    @canRemoveSave = Models.Ability.canRemoveSaveModification(@modification)

  onRender: ->
    if @current_user?
      @current_user.get('followings').fetch success: (followings) =>
        @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()
    else
      @follow_to_user?.show new Fragments.Users.Profile.Follow model: @initiator, followings: new Collections.Followings, buttonLabel: @initiator.get('username').toLowerCase().capitalize()

    @follow_to_obj?.show new Fragments.Vehicles.FavoriteButton vehicle: @model.get('vehicle'), vehicleType: @extra['vehicle_type']

  upperIcon: (object) ->
    if @$(object).hasClass('icon')
      @$(object).css('font-size', 25)
    else
      @$(object).parent('.icon').css('font-size', 25)

  likeModification: (event) ->
    return false unless @canLike
    modification = @modification
    return false unless modification && @currentUser
    modificationLike = new Models.ModificationLike
      modification_id: modification.id
    modificationLike.save null, success: =>
      @upperIcon(event.target)
      modification.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(modification)
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
      modification.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(modification)
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
      modification.fetch data: {light: true}, success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveModification(modification)
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
      modification.fetch data: {light: true}, success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveModification(modification)
        @render()
    false

  goToModification: ->
    modification_id = @extra.id
    vehicle = @model.get('vehicle')
    vehicle.fetch success: =>
      modification = new Models.Modification(id: modification_id, vehicle: vehicle)
      modification.fetch success: ->
        Backbone.history.navigate Routers.Main.showModificationsConfDomainMod1Path(vehicle, modification.get('change_set_id'), modification.get('change_set_name'), modification.get('domain'), modification, 'changes'), true
    false

  shareModification: (event) ->
    modification_id = @extra.id
    vehicle = new Models.Vehicle(id: @extra.vehicle_id)
    vehicle.collection = new Collections.Vehicles
    vehicle.fetch success: ->
      vehicle.get('user').fetch success: =>
        modification = new Models.Modification(id: modification_id, vehicle: vehicle)
        modification.fetch success: ->
          MyApp.modal.show new Modals.CommonSharesButtons
            page_url: Routers.Main.showModificationsConfDomainMod1Path(modification.get('vehicle'), modification.get('change_set_id'), modification.get('change_set_name'), modification.get('domain'), modification, 'changes')
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