class Fragments.Pictures.CommentsItem extends Backbone.Marionette.ItemView
  template: 'fragments/pictures/comments_item'
  tagName:   'li'

  events:
    'click .edit-comment'   : 'showPictureCommentInput'
    'blur .comment-input'   : 'hidePictureCommentInput'
    'keydown .comment-input': 'submitPictureComment'
    'click .delete-comment' : 'deletePictureComment'
    'click .add-opposer'    : 'addToUserOpposers'
    'click .show-user'      : 'goToUserProfile'

  initialize: ->
    @bindTo @model, 'change:body', @render

  onRender: ->
    @$el.attr 'id', "comment_#{@model.id}"

  showPictureCommentInput: ->
    @$('.picture-comment').hide()
    @$('.comment-input').show().focus()

  hidePictureCommentInput: ->
    @$('.picture-comment').show()
    @$('.comment-input').hide()

  submitPictureComment: (event)->
    event.stopPropagation()
    if event.which == 13
      @updatePictureComment()
      event.preventDefault()

  updatePictureComment: ->
    @model.set body: @$('.comment-input').val()
    @model.save {}, wait: true

    @hidePictureCommentInput()

  deletePictureComment: ->
    @model.destroy
      wait: true

  addToUserOpposers: ->
    bootbox.confirm(
      "Are you sure to block <strong>#{@model.get('user').username}</strong> permanently?",
      (submit)=>
        if submit
          userOpposition = new Models.UserOpposition
          userOppositionAttrs =
            opposer_id: @model.get('user').id
          userOpposition.save userOppositionAttrs,
            wait: true
            success: =>
              @model.collection.fetch()
    )
    false

  goToUserProfile: ->
    Backbone.history.navigate(Routers.Main.showUserProfilePath(@model.get('user')), true)
    MyApp.modal.currentView.close()
    false

  serializeData: ->
    username: if @model.get('user').username? then @model.get('user').username else @model.get('user').get('username')
    avatar_url: if @model.get('user').avatar_url? then @model.get('user').avatar_url else @model.get('user').get('avatar_url')
    comment:   @model
    commentUserPath:  Routers.Main.showUserProfilePath(@model.get('user'))
    canManage: Models.Ability.canManageComment(@model)
    canAddToOpposers: Models.Ability.canAddToOpposers(@model.get('user'))