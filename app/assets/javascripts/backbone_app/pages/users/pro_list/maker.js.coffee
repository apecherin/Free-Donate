class Pages.Users.ProList.Maker extends Backbone.Marionette.Layout
  template: 'pages/users/pro_list/maker'

  regions:
    makerForm: '#maker-form'

  events:
    'change .maker_list' : 'changeMaker'

  initialize: ({@makersType, @makers, @user})->
    @selected_maker = @makers.models[0] || new Models.UserMaker(type: @makersType)
    @bindTo MyApp.vent, 'user_maker:removed', @updateMakersList
    @bindTo MyApp.vent, 'user_maker:created', @updateMakersList

  onRender: ->
    _.defer => @$('.maker_list').chosen()
    @makerForm.show new Pages.Users.ProList.MakerForm selectedMaker: @selected_maker, user: @user

  updateMakersList: (maker_id, type)->
    makers = new Collections.UserMakers
    makers.fetch data: {user_id: @user.id}, success: (user_makers) =>
      @makers = new Collections.UserMakers(user_makers.where(type: @makersType))
      @selected_maker = if maker_id? && @makersType is type then @makers.where(id: maker_id.toNumber())?[0] else (@makers.models[0] || new Models.UserMaker(type: @makersType))
      @render()

  changeMaker: (e) ->
    $target = $(e.currentTarget)
    id = $target.find(':selected').val()
    return false if id is 'undefined'
    if id isnt '0'
      @selected_maker = @makers.where(id: id.toNumber())?[0]
      @render()
    else
      @selected_maker = new Models.UserMaker(type: @makersType)
      @render()

    false

  serializeData: ->
    makers: @makers
    user: @user
    selectedMaker: @selected_maker