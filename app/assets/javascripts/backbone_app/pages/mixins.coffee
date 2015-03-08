class Pages.Mixins
  @cancelEditing: ->
    $('.mods-actions').removeClass 'disable-mods-actions'
    MyApp.vent.trigger 'modification:mode_edit:deactive'
    if @model.isNew()
      @model.destroy()
    else
      @editMode = false
      @render()

    false

  @destroyModel: ->
    bootbox.confirm I18n.t('delete', scope: "bootbox.#{@model.constructorName}"), (submit) =>
      if submit
        @model.destroy
          wait: true
          success: =>
            $('.mods-actions').removeClass 'disable-mods-actions'
            MyApp.vent.trigger "#{@model.constructorName}:removed"
            MyApp.vent.trigger 'notify:success', I18n.t('destroyed', scope: "notification.#{@model.constructorName}")
    false

  @enableSaveButton: ->
    @$('.save').removeClass 'disabled'

  @isEditMode: ->
    @model.isNew() || @editMode

  @saveModel: (e)->
    target = @$(e.target)
    target.addClass('disabled')
    saveContinue = true
#    if @model.constructorName is 'part_purchase'
#      $('.vendor-name-input').each (i, e) ->
#        saveContinue = if $(e).attr('data-id')? then true else false
    MyApp.vent.trigger 'notify:error', I18n.t('error_vendors', scope: "notification.#{@model.constructorName}") if !saveContinue
    return false if !saveContinue
    @model.set @collectData()
    @model.save null,
      success: =>
        if @model.isServerValid()
          @editMode = false
          MyApp.vent.trigger "#{@model.constructorName}:created"
          MyApp.vent.trigger 'modification:mode_edit:deactive'
          $('.mods-actions').removeClass 'disable-mods-actions'
          @render()
          MyApp.vent.trigger 'notify:success', I18n.t('saved', scope: "notification.#{@model.constructorName}")
        else
          target.removeClass('disabled')
          @render()
      error: =>
        target.removeClass('disabled')
        @render()
    false

  @switchToEditMode: ->
    MyApp.vent.trigger 'modification:mode_edit:active'
    @editMode = true
    @render()
    false

  @focusInput: (input)->
    length = input.val().length
    input.focus()
    input[0].setSelectionRange 0, length