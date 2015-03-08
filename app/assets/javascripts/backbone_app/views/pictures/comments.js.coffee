#=require ./pictures
#=require ./comments_item

class Fragments.Pictures.Comments extends Backbone.Marionette.CompositeView
  template:  'fragments/pictures/comments'
  className: 'comments'
  itemView:  Fragments.Pictures.CommentsItem

  events:
    'click .edit-title'       : 'showPictureTitleInput'
    'blur .title-input'       : 'hidePictureTitleInput'
    'keydown .title-input'    : 'submitPictureTitle'
    'click .show-user'        : 'goToUserProfile'
    'click .shares-buttons a' : 'sharePicture'

  initialize: (attributes)->
    @picture = attributes.picture
    @layout = attributes.layout
    @collection = @picture.get('comments')
    @collection.fetch()

    currentUser = Store.get('currentUser')
    @avatarUrl = currentUser?.get('avatarUrl') || currentUser?.get('gravatarUrl')

    @firstRender = true
    @canManage() && @bindTo @, 'collection:before:close', =>
      @$('.edit-picture-date').data().datepicker?.picker.remove()

    @sharesURLS = {
      'facebook' : 'https://www.facebook.com/sharer/sharer.php?u=',
      'twitter' : 'http://twitter.com/share?url=',
      'google' : 'https://plus.google.com/share?url='
    }

  setBindings: ->
    @$('.new-comment-input').on 'keydown', (e) =>
      @keyHandler(e)
    @bindTo this, 'collection:before:close', =>
      @$('.new-comment-input').off('keydown')

  setMobileBindings: ->
    @$('.new-comment-input').on 'change', (e) =>
      @postComment()
    @bindTo this, 'collection:before:close', =>
      @$('.new-comment-input').off('change')

  onRender: ->
    if @firstRender
      if typeof window.ontouchstart isnt 'undefined'
        @setMobileBindings()
      else
        @setBindings()

    if @$el.parent().css('height')
      @$('.comments-list-wrap').slimScroll
        height: @layout.commentsHeight - @layout.topBar2Height + 'px'
        distance: '2px'
        start: 'bottom'
      @$('.comments-list-wrap').slimScroll { scroll: '1px' }
    @$('textarea').autogrow()

    if @firstRender
      callback = =>
        @$('.edit-picture-date').datepicker()
          .on 'changeDate', (event)=>
            updatedPictureAttrs =
              created_at: new Date(new Date(event.date.valueOf()).getTime() + @picture.millisecCreatedAt())

            @picture.set updatedPictureAttrs
            @picture.save {}, wait: true

            @$('.edit-picture-date').datepicker('hide')

          .on 'show', =>
            @$('.edit-picture-date').data().datepicker.picker.css('margin-left', '-150px')
            @$('.edit-picture-date').data().datepicker.picker.addClass('right-side')
      setTimeout(callback, 0)
      @firstRender = false

  appendHtml: (collectionView, itemView)->
    collectionView.$('ul.comments-list').append(itemView.el)

  canManage: ->
    Models.Ability.canManagePicture(@picture)

  postComment: ->
    commentAttrs =
      picture: @picture
      body: @$('.new-comment-input').val()
    @$('.new-comment-input').val('')

    comment = new Models.Comment
    comment.save commentAttrs,
      wait: true,
      success: (model, response)=>
        @picture.set('comments_size', @collection.size())
        @$('.comments-list-wrap').slimScroll { scroll: '45px' }

  keyHandler: (event) ->
    event.stopPropagation()
    if event.which == 13
      @postComment()
      event.preventDefault()

  showPictureTitleInput: ->
    @$('.picture-title').hide()
    @$('.title-input').show().focus()

  hidePictureTitleInput: ->
    @$('.picture-title').show()
    @$('.title-input').hide()

  submitPictureTitle: (event)->
    event.stopPropagation()
    if event.which == 13
      @updatePictureTitle()
      event.preventDefault()

  updatePictureTitle: ->
    updatedPictureAttrs =
      title: @$('.title-input').val()
    @picture.save updatedPictureAttrs,
      wait: true
    @hidePictureTitleInput()

  goToUserProfile: ->
    Backbone.history.navigate(Routers.Main.showUserProfilePath(@picture.user()), true)
    MyApp.modal.currentView.close()
    false

  sharePicture: (e) ->
    width = 575
    height = 400
    type = @$(e.target).data('type')
    left = ($(window).width() - width) / 2
    top = ($(window).height() - height) / 2
    opts = "status=1" + ",width=" + width + ",height=" + height + ",top=" + top + ",left=" + left
    window.open @sharesURLS[type] + document.URL, type, opts

    false

  serializeData: ->
    picture:     @picture
    pictureUser: @picture.user()
    pictureUserPath: Routers.Main.showUserProfilePath(@picture.user())
    avatarUrl: @avatarUrl
    layout:    @layout
    canManage: @canManage()
    showPencils: !(@picture.constructorName? && @picture.constructorName is 'part_purchase_picture')