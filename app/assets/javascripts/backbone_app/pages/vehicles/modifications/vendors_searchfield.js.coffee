class Fragments.Vehicles.Modifications.VendorsSearchfield extends Backbone.Marionette.ItemView
  template: 'fragments/modifications/vendors_searchfield'

  events:
    'change .maker_list' : 'changeMaker'

  initialize: ({ @vendorType, @vendors, @user, @input_id })->
    @input_id = if @input_id? then @input_id else ''
    @selected_maker = @vendors.where(id: @input_id.toNumber() )?[0] || new Models.UserMaker(type: @vendorType.capitalize())
    @bindTo MyApp.vent, 'user_maker:removed', @updateMakersList
    @bindTo MyApp.vent, 'user_maker:created', @updateMakersList

  onRender: ->
    _.defer => @$('.maker_list').chosen()

  updateMakersList: (maker_id, type)->
    makers = new Collections.UserMakers
    makers.fetch data: {user_id: @user.id}, success: (user_makers) =>
      @vendors = new Collections.UserMakers(user_makers.where(type: @vendorType.capitalize()))
      @selected_maker = if maker_id? && @vendorType.capitalize() is type then @vendors.where(id: maker_id.toNumber())?[0] else (@vendors.models[0] || new Models.UserMaker(type: @vendorType.capitalize()))
      if @vendorType.capitalize() is type
        @render()

  changeMaker: (e) ->
    $target = $(e.currentTarget)
    id = $target.find(':selected').val()
    return false if id is 'undefined'
    if id isnt '0'
      @selected_maker = @vendors.where(id: id.toNumber())?[0]
      @render()
    else
      @render()
      @addNewVendor()

  addNewVendor: ->
    MyApp.modal.show new Modals.PartProList
      vendorType: @vendorType
      newVendorName: null
      user: @user
    false

  serializeData: ->
    selectedMaker: @selected_maker
    makers: @vendors
    user: @user
    vendorType: @vendorType
    input_id: @input_id