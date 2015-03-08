class Modals.ImportModifications extends Backbone.Marionette.Layout
  template: 'modals/import_modifications'

  events:
    'click .import' : 'importMod'

  initialize: ({@user, @vehicle, @change_set_id, @domain, @modifications}) ->

  onRender: ->

  importMod: (e) ->
    id = $(e.currentTarget).data('id')
    $.ajax(type: 'POST', url:  "/api/modification_import", data: { modification_id: id, vehicle_id: @vehicle.id, change_set_id: @change_set_id, domain: @domain })
      .success (data)=>
        if data.error?
          if data.options?
            message = "#{I18n.t('missing_data_first', scope: 'notification.modification')}"
            data.options.each (option) =>
              message = "#{message}<br>" + "<b style='font-size: 17px;'>#{I18n.t(option, scope: 'data_sheets_new.properties')}</b>"

            MyApp.vent.trigger 'notify:error', "#{message}<br>" + I18n.t('missing_data_end', scope: "notification.modification")
          else
            MyApp.vent.trigger 'notify:error', I18n.t(data.error, scope: "notification.modification")
        else
          MyApp.vent.trigger 'modification:imported'
          MyApp.vent.trigger 'notify:success', I18n.t('imported', scope: "notification.modification")
      .error (data) =>
        MyApp.vent.trigger 'notify:error', I18n.t('error', scope: "notification.modification")
    false

  serializeData: ->
    modifications: @modifications