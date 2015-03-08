class Fragments.Pictures.Vote extends Backbone.Marionette.ItemView
  template: 'fragments/pictures/vote'
  className: 'row'

  events:
    'click .vote#like'   : 'likePicture'
    'click .vote#unlike' : 'unlikePicture'

  initialize: ({@picture}) ->
    @currentUser  = Store.get('currentUser')
    @likes = @picture.get('likes')
    @canVote = Models.Ability.canVote(@picture)

  likePicture: (event) ->
    return false unless @picture && @currentUser
    pictureLike = new Models.PictureLike
      picture: @picture
    pictureLike.save null, wait: true,  success: =>
      @changeButton(event.target)
    false

  unlikePicture: (event) ->
    return false unless @picture && @currentUser
    pictureUnlike = new Models.PictureUnlike
      picture: @picture
    pictureUnlike.save null, wait: true, success: =>
      @changeButton(event.target)
    false

  changeButton: (target) ->
    if target.id is 'like'
      @$(target).attr('id', 'unlike')
      @$(target).text(I18n.t('unlike', scope: 'likes.button'))
    else
      @$(target).attr('id', 'like')
      @$(target).text(I18n.t('like', scope: 'likes.button'))

  onRender: ->

  serializeData: ->
    likes:      @likes
    canVote:    @canVote
    canUnlike:  Models.Ability.canUnLike(@picture)