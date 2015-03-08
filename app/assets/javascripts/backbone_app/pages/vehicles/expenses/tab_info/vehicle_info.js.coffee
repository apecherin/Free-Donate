class Pages.Vehicles.Expenses.VehicleInfo extends Backbone.Marionette.Layout
  template: 'pages/vehicles/expenses/tab_info/vehicle_info'

  regions:
    purchase_info: '#purchase-info'
    selling_info:  '#selling-info'
    sold_info:     '#sold-info'

  events:
    'click #to-edit-mode' : 'toEditMode'
    'click #to-view-mode' : 'toViewMode'
    'change .vehicle_price' : 'changeValue'

  initialize: ({@vehicle})->
    @currentUser = Store.get('currentUser')
    @user = @vehicle.get('user')
    @vehiclePrice = @vehicle.get('vehicle_price')
    @modeEdit = false
    @canEdit = @currentUser && @user.id is @currentUser.id

  onRender: ->
    users = new Collections.ActiveUsers
    users.fetch wait: true, success: (active_users) =>
      @purchase_info.show new Fragments.Expenses.PurchaseInfo
        modeEdit: @modeEdit
        vehiclePrice: @vehiclePrice
        users: users

      @selling_info.show new Fragments.Expenses.SellingInfo
        modeEdit: @modeEdit
        vehiclePrice: @vehiclePrice

      @sold_info.show new Fragments.Expenses.SoldInfo
        modeEdit: @modeEdit
        vehiclePrice: @vehiclePrice
        users: users

      @$('.vehicle_price_date').datepicker({format: 'yyyy-mm-dd', separator: '-'}).on "changeDate", (ev) ->
        $(@).blur()

  toEditMode: () ->
    @modeEdit = true
    @render()
    false

  toViewMode: () ->
    @modeEdit = false
    @render()
    false

  changeValue: (e) ->
    data = @collectData($(e.target))
    @vehiclePrice.save(data)

    false

  collectData: (source)->
    id = source.attr('id')
    obj = {}
    obj[id.split("_#{@vehiclePrice.id}_")[1]] = source.val().replace(',', '.')
    return obj

  serializeData: ->
    modeEdit: @modeEdit
    canEdit: @canEdit