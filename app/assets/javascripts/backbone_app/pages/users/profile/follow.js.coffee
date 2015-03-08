class Fragments.Users.Profile.Follow extends Backbone.Marionette.ItemView
  template: 'fragments/users/profile/follow'

  events:
    'click .follow'   : 'follow'
    'click .unfollow' : 'unfollow'

  initialize: ({@followings, @buttonLabel})->
    @buttonLabel = if @buttonLabel then @buttonLabel else null
    @canManage = Models.Ability.canManageUser(@model)

  follow: ->
    unless @canManage
      following = new Models.Following
      following.collection = @followings
      following.set thing_id: @model.id, thing_type: 'User',
      following.save null,
        success: (model)=>
          @followings.add model
          @render()
    return false

  unfollow: ->
    unless @canManage
      f = @followings.find (following) => following.isFollow(@model)
      return false unless f
      promise = f.destroy()
      promise.then =>
        @render()
    false

  serializeData: ->
    canFollow: Models.Ability.canFollow(@model)
    canManage: Models.Ability.canManageUser(@model)
    buttonLabel: @buttonLabel
    currentUser: Store.get('currentUser')
