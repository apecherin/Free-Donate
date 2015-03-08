class Fragments.Vehicles.AddPrewrittenVersionComment extends Backbone.Marionette.ItemView
  template: 'fragments/vehicles/add_prewritten_version_comment'

  events:
    'change .version-add-prewritten-comment-select' : 'addCommentToVersion'

  initialize: ({@currentUser}) ->
    @version = @model

  addCommentToVersion: (e) ->
    $target = $(e.currentTarget)
    commentKey = $target.val()
    commentAssoc = new Models.PrewrittenVersionCommentWithUser
      version_id: @version.id
      user_id: @currentUser.id
      prewritten_comment_key: commentKey
    commentAssoc.save null, wait: true,
      success: (model)=>
        newVersionComment = if isNaN(commentKey) then null else commentKey
        @version.set 'current_user_comment', newVersionComment
        @render()

  onRender: ->
    _.defer => @$('select').chosen()

  commentsForVersion: ->
    I18n.t("#{@version.get('vehicle_type')}", scope: 'data.prewritten_comments')

  serializeData: ->
    currentCommentOnVersionByUser: @version.get('current_user_comment')
    comments: @commentsForVersion()
