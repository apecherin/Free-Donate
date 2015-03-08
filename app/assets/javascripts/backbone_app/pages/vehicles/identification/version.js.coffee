#=require ./identification

class Fragments.Vehicles.Identification.Version extends Backbone.Marionette.Layout
  getTemplate: ->
    basePath = 'fragments/vehicles/version'
    if @vehicle.isAuto()
      "#{basePath}_car"
    else if @vehicle.isTruck()
      "#{basePath}_truck"
    else
      "#{basePath}_bike"

  tagName: 'tbody'

  regions:
    generation: "#generationContainer"
    ownership:  "#ownership"

  events:
    'change .attribute'            : 'saveVersion'
    'change .production-row'       : 'saveProductionRow'
    'mouseenter  .add-select-options'  : 'showPopover'
    'mouseleave  .popover'             : 'hidePopover'
    'click .chzn-container'            : 'hidePopovers'
    'click .add-select-option'     : 'addSelectOption'
    'click .remove-select-option'  : 'removeSelectOption'

  initialize: ({@vehicle, @versionAttributes, @generations})->
    @modelId = @versionAttributes.get('model_id')
    @versionAttributes.unset('model_id')

    @modelSelectOptions = @vehicle.get('model').get('select_options')
    console.log @modelSelectOptions
    @modelSelectOptionsHash = @modelSelectOptions.toHash()

    @setBindings()
    @versionAttributesFetchRequests = 0

  setBindings: ->
    @bindTo @model, 'change:body', =>
      @fetchAttributeSet(['name', 'second_name'])

    @bindTo @model, 'change:production_year', =>
      @fetchAttributeSet(['production_code'])

    @bindTo @model, 'change:transmission_type', =>
      MyApp.vent.trigger '[version]change:transmission_type'

  onRender: ->
    @initPopovers()
    if @versionAttributesFetchRequests is 0
      that = @

      callback = =>

        @$('.addable-chosen').chosen
          no_results_text: ' '
          create_option_text: I18n.t('create_option_text', scope: 'ui')
          create_option: (value) ->
            @.append_option value: value, text: value
            field = $(@form_field)
            if field.prop('name') in ['production_year']
              that.versionAttributes.get(field.prop('name')).add(parseInt value)
            else
              that.versionAttributes.get(field.prop('name')).add(value)

            field.trigger 'change'

        @$('.attribute-checkbox').on 'change', (e) =>
          $target = $(e.currentTarget)
          @model.set($target.attr('name'), $target.is(':checked'))
          promise = @model.save()
          promise.done => @render()

        @$('.attribute-checkbox-engine').on 'change', (e) =>       
          $target = $(e.currentTarget)
          @model.set($target.attr('name'), $target.is(':checked'))
          promise = @model.save()
          promise.done => @render()


        @$('.chosen').chosen(no_results_text: ' ')

        if @generation
          @generation.show new Fragments.Vehicles.Identification.Version.Generation
            model: @model.get('generation')
            generations: @generations
            showControls: Models.Ability.canManageVehicle @vehicle

        new Fragments.Vehicles.Identification.Ownership(
          model: @vehicle.get('ownership')
          el: @ownership.el).render()
      _.defer(callback)

  saveVersion: ->
    @model.set @collectVersionData()
    @model.save null, wait: true

  fetchAttributeSet: (attributes)->
    @versionAttributesFetchRequests += 1
    @model.save null,
      silent: true
      success: =>
        @versionAttributes.fetch data: {attributes: attributes}, success: =>
          @versionAttributesFetchRequests -= 1
          @render()

  saveProductionRow: ->
    @model.set @collectProductionRowData()
    @model.save null,
      silent: true
      wait: true
      success: =>
        @render()

  initPopovers: ->
    that = @
    @$('.add-select-options').each ->
      attr = $(this).data('attr')
      $(this).popover(
        placement: 'right'
        html: true
        trigger: 'manual'
        content: ->
          that.contentForPopover(attr)
      )

  contentForPopover: (attr) ->
    modelOptions = @modelSelectOptionsHash[attr]
    globalOptions = I18n.t(attr, scope: "data.global_select_option.#{@vehicle.get('type')}")
    JST['fragments/vehicles/popover_select_options'](globalOptions: globalOptions || [], modelOptions: modelOptions || [], attr: attr)

  showPopover: (e) ->
    $target = $(e.currentTarget)
    if $target.siblings('.popover').length is 0
      @hidePopovers()
      $target.popover('show')

  hidePopover: (e) ->
    $(e.currentTarget).siblings('.add-select-options').popover('hide')

  hidePopovers: ->
    @$('.popover').remove()

  addSelectOption: (e) ->
    $target = $(e.currentTarget)
    attr = $target.closest('ul').data('attr')
    option = $target.data('option').toString()
    optionDisplay = $.trim($target.text())
    @addOption attr, option, success: =>
      $select = @$("select[name=#{attr}]")
      $select.append("<option value=\"#{option}\">#{optionDisplay}</option>")
      $select.trigger('liszt:updated')
      $target.removeClass('add-select-option').addClass('chosen-select-option')
      text = $target.text()
      $target.html($("<a class=\"remove-select-option\" style=\"cursor: pointer;\">&times;</a><span>#{text}</span>"))
    false

  addOption: (attr, value, opts) ->
    option = @modelSelectOptions.find (model) ->
      model.get('name') is attr
    unless option
      option = new Models.ModelSelectOption
        model_id: @modelId
        name: attr
        values: []
    option.get('values').push(value)
    option.save null, success: =>
      @modelSelectOptions.add(option)
      opts.success()

  removeSelectOption: (e) ->
    $target = $(e.currentTarget)
    $chosen = $target.closest('.chosen-select-option')
    attr = $chosen.closest('.popover-global-selects').data('attr')
    value = $chosen.data('option').toString()
    @removeOption attr, value, success: =>
      $select = $target.closest('td').find('select.attribute')
      $select.find("option[value='#{value}']").remove()
      $select.trigger('liszt:updated')
      @hidePopovers()
    false

  removeOption: (attr, value, opts) ->
    remove = (el) -> el.toString() is value
    option = @modelSelectOptions.find (model) ->
      model.get('name') is attr
    option.set 'values', _.reject(option.get('values'), remove)
    option.save null, wait: true, success: ->
      opts.success()

  stringAttrs: (ary) ->
    ary.map (e) -> e.toString()

  selectOptionsForAttr: (attr) ->
    modelSelectOption = @modelSelectOptions.find (model) ->
      model.get('name') is attr
    return [] unless modelSelectOption
    modelSelectOption.get('values')

  # includes current attribute even if it isn't in the possible set of
  # selectable attributes
  selectOptionsForAttrWithCurrent: (attr) ->
    selectOptions = @selectOptionsForAttr(attr)
    attrVal = @model.get(attr)
    return selectOptions if attrVal is null
    selectOptions.push(attrVal) unless _.include(@stringAttrs(selectOptions), attrVal.toString())
    selectOptions

  collectVersionData: ->
    body:                 @$('#version_body_id').val()
    name:                 @$('#name_id').val()
    transmission_numbers: @$('#version_transmission_numbers_id').val()
    transmission_type:    @$('#version_transmission_type_id').val()
    production_year:      @$('#production_year_id').val()
    doors:                @$('#version_doors').val()
    energy:               @$('#version_energy').val()
    transmission_details: @$('#version_transmission_details').val()
    second_name:          @$('#second_name_id').val()

  collectProductionRowData: ->
    production_code:      @$('#production_code_id').val()
    market_version_name:  @$('#market_version_name_id').val()

  defaultProductionYears: ->
    _.range(1920, (new Date().getFullYear() + 2)).reverse()

  serializeData: ->
    brand:                 @vehicle.get('brand')
    model:                 @vehicle.get('model')
    user:                  @vehicle.get('user')
    version:               @model
    vehicle:               @vehicle
    vehicle_approved:      @vehicle.get('approved')
    attributes:            @versionAttributes
    productionYears:       @defaultProductionYears()
    showControls:          Models.Ability.canManageVehicle @vehicle
    showBody:              Models.Ability.canShowIdentificationRow @vehicle, 'body'
    showModelVersionData:  Models.Ability.canShowIdentificationRow @vehicle, 'modelVersion'
    showMarketRow:         Models.Ability.canShowIdentificationRow @vehicle, 'market'
    showProductionCodeRow: Models.Ability.canShowIdentificationRow @vehicle, 'productionCode'
    showProductionYearRow: Models.Ability.canShowIdentificationRow @vehicle, 'productionYear'
    showGenerationRow:     Models.Ability.canShowIdentificationRow @vehicle, 'generation'
    showGearboxRow:        Models.Ability.canShowIdentificationRow @vehicle, 'gearBox'
    showGearboxTypeData:   Models.Ability.canShowIdentificationRow @vehicle, 'gearBoxType'
    showTransmissionRow:   Models.Ability.canShowIdentificationRow @vehicle, 'transmission'
    showEnergyRow:         Models.Ability.canShowIdentificationRow @vehicle, 'energy'
    showOwnershipRows:     Models.Ability.canShowIdentificationRow @vehicle, 'ownership'
    aliases:               @vehicle.aliases()

    globalSelectOptions:    I18n.lookup("data.global_select_option.#{@vehicle.get('type')}")
    modelSelectOptionsHash: @modelSelectOptionsHash