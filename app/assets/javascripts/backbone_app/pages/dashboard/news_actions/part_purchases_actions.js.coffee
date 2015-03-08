class Pages.Dashboard.NewsActions.PartPurchasesActions extends Backbone.Marionette.Layout

  template: 'pages/dashboard/news_actions/part_purchases_actions'

  regions:
    follow_to_user: '.follow_to_user'
    follow_to_obj:  '.follow_to_obj'

  events:
    'click .go-to-user' : 'goToUser'

    'click .watch-part-purchase'     : 'goToPartPurchase'
    'click .part-purchase-like-it'   : 'likePartPurchase'
    'click .part-purchase-unlike-it' : 'unlikePartPurchase'
    'click .part-purchase-save-it'   : 'savePartPurchase'
    'click .part-purchase-delete-it' : 'deletePartPurchase'
    'click .part-purchase-share-it'  : 'sharePartPurchase'

  initialize: ({ @model, @myNews, @followingsNews, @followersNews, @part_purchase }) ->
    @current_user = @currentUser = Store.get('currentUser')
    @initiator = @modelUser = @model.get('initiator')
    @extra = @model.get('target').extra
    @event_type = @model.get('event_type')

    @canSave = @canLike = (@currentUser && @modelUser.id isnt @currentUser.id)
    @canUnLike = Models.Ability.canUnLike(@part_purchase)
    @canRemoveSave = Models.Ability.canRemoveSaveModification(@part_purchase)

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

  likePartPurchase: (event) ->
    return false unless @canLike
    part_purchase = @part_purchase
    modification_id = @model.get('target').extra.modification_id
    return false unless part_purchase && @currentUser
    partPurchaseLike = new Models.PartPurchaseLike
      part_purchase_id: part_purchase.id
      modification_id: modification_id
    partPurchaseLike.save null, success: =>
      @upperIcon(event.target)
      part_purchase.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(part_purchase)
        @render()
    false

  unlikePartPurchase: (event) ->
    return false unless @canLike
    part_purchase = @part_purchase
    modification_id = @model.get('target').extra.modification_id
    return false unless part_purchase && @currentUser
    partPurchaseUnlike = new Models.PartPurchaseUnlike
      part_purchase_id: part_purchase.id
      modification_id: modification_id
    partPurchaseUnlike.save null, success: =>
      @upperIcon(event.target)
      part_purchase.fetch data: {light: true}, success: =>
        @canUnLike = Models.Ability.canUnLike(part_purchase)
        @render()
    false

  deletePartPurchase: (event) ->
    return false unless @canSave
    part_purchase = @part_purchase
    modification_id = @model.get('target').extra.modification_id
    return false unless part_purchase && @currentUser
    partPurchaseDelete = new Models.PartPurchaseDelete
      part_purchase_id: part_purchase.id
      modification_id: modification_id
    partPurchaseDelete.save null, success: =>
      @upperIcon(event.target)
      part_purchase.fetch data: {light: true}, success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveModification(part_purchase)
        @render()
    false

  savePartPurchase: (event) ->
    return false unless @canSave
    part_purchase = @part_purchase
    modification_id = @model.get('target').extra.modification_id
    return false unless part_purchase && @currentUser
    partPurchaseSave = new Models.PartPurchaseSave
      part_purchase_id: part_purchase.id
      modification_id: modification_id
    partPurchaseSave.save null, success: =>
      @upperIcon(event.target)
      part_purchase.fetch data: {light: true}, success: =>
        @canRemoveSave = Models.Ability.canRemoveSaveModification(part_purchase)
        @render()
    false

  goToPartPurchase: ->
    modification_id = @extra.modification_id
    vehicle = @model.get('vehicle')
    modification = new Models.Modification(id: modification_id, vehicle: vehicle)
    modification.fetch success: ->
      Backbone.history.navigate Routers.Main.showModificationsConfDomainMod1Path(modification.get('vehicle'), modification.get('change_set_id'), modification.get('change_set_name'), modification.get('domain'), modification, 'parts'), true
    false

  sharePartPurchase: (event) ->
    modification_id = @extra.modification_id
    vehicle = @model.get('vehicle')
    modification = new Models.Modification(id: modification_id, vehicle: vehicle)
    modification.fetch success: ->
      MyApp.modal.show new Modals.CommonSharesButtons
        page_url: Routers.Main.showModificationsConfDomainMod1Path(modification.get('vehicle'), modification.get('change_set_id'), modification.get('change_set_name'), modification.get('domain'), modification, 'parts')
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