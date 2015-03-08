#= require jqSocialSharer.min
class Fragments.Comparisons.Generator.VehiclesChoisenContainer extends Backbone.Marionette.Layout
  template: 'fragments/comparisons/generator/vehicles_choisen_container'

  events:
    'change .vehicle-choice' : 'changeVehiclePair'
    'change .property-vehicles-choice' : 'changeVehiclePropertyPair'
    'click .shares-buttons a' : 'share'
    'click #copy-image-url' : 'generateImageURL'
    'click .thumbnails-size-container .action span' : 'showGenerateTool'
    'click .btn-primary' : 'changeBGRN'

  regions:
    thumbnailsViewContainer: '#thumbnails-view-container'

  initialize: ({ @comparisonsTable })->
    @sharesURLS = {
      'facebook' : 'https://www.facebook.com/sharer/sharer.php?u=',
      'twitter' : 'http://twitter.com/share?url=',
      'google' : 'https://plus.google.com/share?url='
    }
    @vehicles = @comparisonsTable.get('vehicles')
    return false if @vehicles.size() is 0

    @change_set_list = @getChangeSetList(@vehicles)
    @comparison_attributes = @mergeComparisonAttributes(@comparisonsTable.get('comparison_attributes'))
    @selected_attr = @comparison_attributes[0]
    @vehicle_1_id = @change_set_list.first().vehicle_id
    @change_set_1_id = @change_set_list.first().id

    chs = @change_set_list.last()
    if Store.get('currentUser')?
      @change_set_list.each (change_set) =>
        if change_set.user_id is Store.get('currentUser').id
          chs = change_set
    @vehicle_2_id = chs.vehicle_id
    @change_set_2_id = chs.id
    @is_thumbnail_view_mode = false

  onRender: ->
    @$('generated_image').remove()
    @thumbnailsViewContainer.show new Fragments.Comparisons.Generator.ThumbnailsViewContainer
      vehicle1: @getVehiclePairObject(@vehicles.get(@vehicle_1_id), @change_set_1_id)
      vehicle2: @getVehiclePairObject(@vehicles.get(@vehicle_2_id), @change_set_2_id, 2)
      selectedAttr: @selected_attr
      comparison_id: @comparison_id

    callbacks = =>
      client1 = new ZeroClipboard(@$('#copy-page-url'))
      client2 = new ZeroClipboard(@$('#copy-image-url-generated'))
    setTimeout callbacks, 400

  changeBGRN: (e) ->
    btn = @$(e.currentTarget)
    old_img = btn.css('background-image')
    old_color = btn.css('background-color')
    btn.css('background-image', 'none')
    btn.css('background-color', '#0044cc')

    if btn.hasClass('copy-url')
      @$("input##{btn.attr('data-clipboard-target')}").select()
      MyApp.vent.trigger 'notify:success', I18n.t('url_in_clipboard', scope: 'notification.comparison')

    revert = =>
      btn.css('background-image', old_img)
      btn.css('background-color', old_color)
    setTimeout revert, 300

  showGenerateTool: (e) ->
    if @is_thumbnail_view_mode
      @is_thumbnail_view_mode = false
    else
      @is_thumbnail_view_mode = true
    @render()

  getChangeSetList: (vehicles) ->
    change_set_list = []
    vehicles.each (vehicle) =>
      name = vehicle.get('label')
      vehicle.get('change_sets').each (changeSet) =>
        change_set_list.push {user_id: vehicle.get('user').id, label: "#{name}(#{changeSet.get('name')})", id: changeSet.get('id'), vehicle_id: vehicle.get('id') }

    change_set_list

  mergeComparisonAttributes: (attrs) ->
    merged_attrs = attrs.performance
    merged_attrs = merged_attrs.concat attrs.consumption
    merged_attrs = merged_attrs.concat attrs.specifications
    merged_attrs

  changeVehiclePair: (e) ->
    $target = $(e.currentTarget)
    id = $target.find(':selected').val()
    name = $target.find(':selected').attr('name')
    return false if id is 'undefined'
    if $target.attr('id') is 'data-vehicle-1'
      @change_set_1_id = id.toNumber()
      @vehicle_1_id = name.toNumber()
    else
      @change_set_2_id = id.toNumber()
      @vehicle_2_id = name.toNumber()

    @render()

  changeVehiclePropertyPair: (e) ->
    $target = $(e.currentTarget)
    id = $target.find(':selected').val()
    return false if id is 'undefined'
    @selected_attr = id

    @render()

  getVehiclePairObject: (vehicle, change_set_id, pos = 1) ->
    user = vehicle.get('user')
    properties = @comparisonsTable.get('properties')[@selected_attr]
    property_value = '?'
    if properties.no_property? && vehicle.get('id') not in properties.no_property
      property_value = $.grep(properties.property_values, (e) ->
        e.vehicle_id is vehicle.get('id') && e.change_set_id is change_set_id
      )
      property_value = if property_value[0]? then property_value[0].property_value.toFloatTry() else '?'
    unit = I18n.t(Seeds.propertyDefinitions[@selected_attr], scope: 'units_new.unit_symbols') || ''

    { vehicle_brand: vehicle.get('brand').get('name'), vehicle_model: vehicle.get('model').get('name'), username: user.get('username'), user_avatar_url: user.get('avatarUrl') || user.get('gravatarUrl'), side_view_url: (if pos is 1 then vehicle.sideViewUrl('small') else vehicle.sideViewUrl('normal')), property_value: property_value, unit: unit }

  getVehiclePairObjectBig: (vehicle, change_set_id, attr, pos = 1) ->
    user = vehicle.get('user')
    properties = @comparisonsTable.get('properties')[attr]
    property_value = '?'
    if properties.no_property? && vehicle.get('id') not in properties.no_property
      property_value = $.grep(properties.property_values, (e) ->
        e.vehicle_id is vehicle.get('id') && e.change_set_id is change_set_id
      )
      property_value = if property_value[0]? then property_value[0].property_value.toFloatTry() else '?'
    unit = I18n.t(Seeds.propertyDefinitions[attr], scope: 'units_new.unit_symbols') || ''

    { vehicle_year: vehicle.get('version').get('production_year'), vehicle_second_name: vehicle.get('version').get('second_name'), vehicle_brand: vehicle.get('brand').get('name'), vehicle_model: vehicle.get('model').get('name'), username: user.get('username'), user_avatar_url: user.get('avatarUrl') || user.get('gravatarUrl'), side_view_url: (if pos is 1 then vehicle.sideViewUrl('big') else vehicle.sideViewUrl('xl')), property_value: property_value, unit: unit }

  generateImageURL: ->
    @generateImageByHTML(null, null, null)

  share: (e) ->
    @generateImageByHTML(null, 'big', e)
    false

  openShare: (page_url, image_url, e) ->
    type = @$(e.target).data('type')
    page_url = "http://cardrive.com#{page_url}"
    image_url = "http://cardrive.com#{image_url}"
    comparisonShare = new Models.ComparisonTableShare
      comparison_table_id: @comparisonsTable.id
    if type is 'facebook'
      FB.ui
        method: "feed"
        link: page_url
        picture: image_url
#        method: 'share_open_graph',
#        action_type: 'og.likes',
#        action_properties: JSON.stringify({
#          object: page_url,
#        })
      , (response) ->
        comparisonShare.save {url: page_url, network_type: type}, success: =>
          MyApp.vent.trigger('comparison_shares:new')
    else
      width = 575
      height = 400
      left = ($(window).width() - width) / 2
      top = ($(window).height() - height) / 2
      opts = "status=1" + ",width=" + width + ",height=" + height + ",top=" + top + ",left=" + left
      window.open @sharesURLS[$(e.target).data('type')] + page_url, type, opts
      comparisonShare.save {url: page_url, network_type: type}, success: =>
        MyApp.vent.trigger('comparison_shares:new')

  openShareOLd: (type, image_url, e) ->
    if type is 'facebook'
      FB.ui
        method: "feed"
        link: "http://cardrive.com"
        caption: "Look my comparison table!"
        picture: "http://cardrive.com#{image_url}"
      , (response) ->
#    $("meta[name*='facebook']").remove()
#    $("head").append("<meta name='title_facebook' property='og:title' content='m5 is coming!'/>
#      <meta  name='desc_facebook'property='og:description' content='Look my table!'/>
#      <meta  name='img_facebook'property='og:image' content='http://cardrive.com/img/generated_image/comparisons/163/1415278052.png'/>
#      <meta  name='url_facebook'property='og:url' content='http://cardrive.com'/>");
#    width = 575
#    height = 400
#    left = ($(window).width() - width) / 2
#    top = ($(window).height() - height) / 2
#    opts = "status=1" + ",width=" + width + ",height=" + height + ",top=" + top + ",left=" + left
#    window.open @sharesURLS[type], type, opts

#    page_url = document.URL
#    type = @$(e.currentTarget).data('type')
#    button = @$(".shares-buttons-hidden [data-type='#{type}']")
#
##    if button.attr('class') is 'facebook'
##      button.data('social', "{'type' => 'facebook', 'url' => '#{page_url}', 'text' => 'Look my Comparison Table!', 'image' => '#{document.location.hostname + image_url}'}")
##    else
##      button.data('social', "{'type' => 'facebook', 'url' => '#{page_url}', 'text' => 'Look my Comparison Table!')
#
#    console.log @$(button).data('social')
##    new_data = "{\"type\":\"#{type}\", \"url\":\"#{page_url}\", \"text\":\"Look my Comparison Table!\", \"image\":\"http://#{document.location.hostname + image_url}\"}"
##    @$(button).attr('data-social', new_data)
#    console.log @$(button).data('social')



  generateImageByHTML: (html_url, type='little', e) ->
    MyApp.vent.trigger 'notify:success', I18n.t('wait_message', scope: 'notification.comparison')
    if type is 'little'
      veh1_pair_obj = @getVehiclePairObject(@vehicles.get(@vehicle_1_id), @change_set_1_id)
      veh2_pair_obj = @getVehiclePairObject(@vehicles.get(@vehicle_2_id), @change_set_2_id, 2)
      data_little = {
        'id': @comparisonsTable.get('id'),
        'property_type': I18n.t(@selected_attr, scope: 'data_sheets_new.properties'),
        'property_unit': veh1_pair_obj.unit,
        'vehicle1': {
          'side_view': veh1_pair_obj.side_view_url,
          'avatar': veh1_pair_obj.user_avatar_url,
          'veh_value': veh1_pair_obj.property_value,
          'username': veh1_pair_obj.username,
          'brand': veh1_pair_obj.vehicle_brand,
          'model': veh1_pair_obj.vehicle_model
        },
        'vehicle2': {
          'side_view': veh2_pair_obj.side_view_url,
          'avatar': veh2_pair_obj.user_avatar_url,
          'veh_value': veh2_pair_obj.property_value,
          'username': veh2_pair_obj.username,
          'brand': veh2_pair_obj.vehicle_brand,
          'model': veh2_pair_obj.vehicle_model
        }
      }
      $.ajax(type: 'POST', url:  "/api/comparison_tables/#{@comparisonsTable.id}/generate_image", data: data_little)
        .success (data)=>
          $('.thumbnails-view-container').hide()
          MyApp.vent.trigger 'notify:success', I18n.t('done_message', scope: 'notification.comparison')
          @$('#thumbnails-view-container').append('<div id="generated_image"><img src="' + data.image + '"/></div>')
          @$('#copy-image-url').hide()
          @$('input#fe_image_url').val('http://cardrive.com' + data.image)
          @$('#generated-image-url-container').show()
        .error (data) =>
          MyApp.vent.trigger 'notify:error', I18n.t('image_generate_error', scope: 'notification.comparison')
    else
      veh1_top_speed_pair_obj = @getVehiclePairObjectBig(@vehicles.get(@vehicle_1_id), @change_set_1_id, 'top_speed', 2)
      veh1_max_power_pair_obj = @getVehiclePairObjectBig(@vehicles.get(@vehicle_1_id), @change_set_1_id, 'max_power', 2)
      veh2_top_speed_pair_obj = @getVehiclePairObjectBig(@vehicles.get(@vehicle_2_id), @change_set_2_id, 'top_speed', 2)
      veh2_max_power_pair_obj = @getVehiclePairObjectBig(@vehicles.get(@vehicle_2_id), @change_set_2_id, 'max_power', 2)
      data_big = {
        'id': @comparisonsTable.get('id'),
        'property_type_1': I18n.t('top_speed', scope: 'data_sheets_new.properties'),
        'property_type_2': I18n.t('max_power', scope: 'data_sheets_new.properties'),
        'property_unit_1': veh1_top_speed_pair_obj.unit,
        'property_unit_2': veh1_max_power_pair_obj.unit,
        'vehicle1': {
          'change_set_id': @change_set_1_id,
          'side_view': veh1_top_speed_pair_obj.side_view_url,
          'avatar': veh1_top_speed_pair_obj.user_avatar_url,
          'veh_value_1': veh1_top_speed_pair_obj.property_value,
          'veh_value_2': veh1_max_power_pair_obj.property_value,
          'username': veh1_top_speed_pair_obj.username,
          'brand': veh1_top_speed_pair_obj.vehicle_brand,
          'model': veh1_top_speed_pair_obj.vehicle_model,
          'year': veh1_top_speed_pair_obj.vehicle_year,
          'second_name': veh1_top_speed_pair_obj.vehicle_second_name
        },
        'vehicle2': {
          'change_set_id': @change_set_2_id,
          'side_view': veh2_top_speed_pair_obj.side_view_url,
          'avatar': veh2_top_speed_pair_obj.user_avatar_url,
          'veh_value_1': veh2_top_speed_pair_obj.property_value,
          'veh_value_2': veh2_max_power_pair_obj.property_value,
          'username': veh2_top_speed_pair_obj.username,
          'brand': veh2_top_speed_pair_obj.vehicle_brand,
          'model': veh2_top_speed_pair_obj.vehicle_model,
          'year': veh2_top_speed_pair_obj.vehicle_year,
          'second_name': veh2_top_speed_pair_obj.vehicle_second_name
        }
      }
      $.ajax(type: 'POST', url:  "/api/comparison_tables/#{@comparisonsTable.id}/generate_image_big", data: data_big)
        .success (data)=>
          @openShare(data.share_url, data.image, e)
        .error (data) =>
          MyApp.vent.trigger 'notify:error', I18n.t('image_generate_error', scope: 'notification.comparison')

  serializeData: ->
    change_set_list:  @change_set_list
    vehicle_1_id: @vehicle_1_id
    vehicle_2_id: @vehicle_2_id
    change_set_1_id: @change_set_1_id
    change_set_2_id: @change_set_2_id
    comparison_attributes: @comparison_attributes
    selected_attr: @selected_attr
    is_thumbnail_view_mode: @is_thumbnail_view_mode