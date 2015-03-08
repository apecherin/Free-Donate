class Fragments.Vehicles.VersionCommentItem extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/version_comment_item'
  tagName: 'li'

  events:
    'click .delete-version-comment'           : 'destroyVersionComment'
    'click .version-commenter-username-link'  : 'goToUserProfile'

  destroyVersionComment: (e) ->
    return unless @model.get('canManage')
    bootbox.confirm 'Are you sure?', (submit) =>
      if submit
        promise = @model.set version_id: @model.get('version_id'), user_id: @model.get('commenter').id, prewritten_comment_key: "0"
        promise = @model.save()
        promise.done =>
          @model.collection.remove(@model)
          @remove()
    false

  goToUserProfile: (e) ->
    userId = $(e.currentTarget).data('user-id')
    path = Routers.Main.showUserProfilePath(userId)
    Backbone.history.navigate(path, true)
    false

  serializeData: ->
    comment: @model
    canManage: @model.get('canManage')
