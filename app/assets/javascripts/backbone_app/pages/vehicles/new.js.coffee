class Pages.Vehicles.New extends Backbone.Marionette.ItemView
  id:       'vehicles-new-page'
  template: 'pages/vehicles/new'

  events:
    'click .vehicle-type'             : 'changeType'
    'change select[name=brand]'    : 'changeBrand'
    'change select[name=model]'    : 'changeModel'
    'click .save-vehicle'             : 'saveVehicle'


  initialize: (attributes)->
    @canCreate = Models.Ability.canCreateVehicle()
    @brands = new Collections.Brands
    @models = new Collections.Models

    comparator = (item)=> item.get('name')
    @brands.comparator = @models.comparator = comparator

    @vehicle = new Models.Vehicle
    @bindTo @vehicle, 'change:vehicle_type', =>
      @vehicle.set 'brand', null
    @bindTo @vehicle, 'change:brand', =>
      @vehicle.set 'model', null

    @bindTo @brands, 'reset', @updateBrandsList
    #TODO: fix this *it
    @bindTo @brands, 'add', (brand)=>
      @vehicle.set 'brand', brand
      @updateBrandsList()
      @models.reset()
    @bindTo @models, 'reset', @updateModelsList
    @bindTo @models, 'add', (model)=>
      @vehicle.set 'model', model
      @updateModelsList()

  # When the type changes, the brands are loaded from the server and reset
  # the collection, so the collection is rendered again.
  changeType: (event)->
    $target = $(event.currentTarget)
    @vehicle.set 'vehicle_type', $target.data('type')

    @brands.fetch
      data: { include_pending: false, vehicle_type: @vehicle.get('vehicle_type') }
    @render()

  changeBrand: (event)->
    @vehicle.set 'brand', @brands.get($(event.target).val())

    @models.fetch(data: { brand_id: @vehicle.get('brand').id, type: @vehicle.get('vehicle_type') })

  changeModel: (event)->
    @vehicle.set 'model', @models.get($(event.target).val())


  saveVehicle: ->
    if @canCreate
      vehicle = new Models.Vehicle
      vehicle.collection = Store.get('currentUser').get('vehicles')
      version = new Models.Version
      modelId = @vehicle.get('model')?.id
      return false unless modelId
      version.set model_id: modelId, market_version_name: Store.get('currentUser').get('country_code')
      version.save null,
        success: (model)=>
          vehicle.set 'version', model
          vehicle.save {vehicle_type: @vehicle.get('vehicle_type')},
            success: (model, response)=>
              #TODO: consider using Backbone.history.navigate(path, true)
              Backbone.history.navigate Routers.Main.showUserVehiclePath(Store.get('currentUser'), model)
              MyApp.layout.content.show new Pages.Vehicles.Show model: model

    false

  updateBrandsList: ->
    @updateChosenList 'brand'


  updateModelsList: ->
    @updateChosenList 'model'

  updateChosenList: (item)->
    $select = @$("select[name=#{item}]")
    $select.find('option[value]').remove()

    @["#{item}s"].sort(silent: true).each (model)=>
      selected = @vehicle.get("#{item}")?.id == model.id
      $option  = $('<option />', selected: selected, value: model.id, text: model.get('name'))
      $select.append($option)

    $select.trigger("liszt:updated")
    @$(".#{item}-control-group a.chzn-single").addClass('chzn-default') unless @vehicle.get("#{item}")?.id

  onRender: ->
    if @vehicle.get('vehicle_type')
      @$('.thumbnail.vehicle-type[data-type="' + @vehicle.get('vehicle_type') + '"]')
        .toggleClass('vehicle-type-active')

    that = @
    callback = ->
      @$('.addable-chosen').chosen
        search_contains: true
        no_results_text: ' '
        create_option_text: I18n.t('create_option_text', scope: 'ui')
        create_option: (value)->
          @.append_option value: value, text: value
          field = $(@form_field)
          that["create_#{field.prop 'name'}"](value, => field.trigger 'change')

    setTimeout(callback, 0)

  create_brand: (name, callback)->
    brand = new Models.Brand
    brand.collection = @brands
    brand.save {name: name, vehicle_type: @vehicle.get('vehicle_type')},
      wait: true
      success: (model)=>
        @brands.add model
        callback()

  create_model: (name, callback)->
    model = new Models.Model
    model.collection = @models
    model.save {brand_id: @vehicle.get('brand').id, name: name, vehicle_type: @vehicle.get('vehicle_type')},
      wait: true
      success: (model)=>
        @models.add model
        callback()


  serializeData: ->
    vehicle:  @vehicle
    canCreate: @canCreate
