class Pages.Modifications.ModificationItemLayout extends Backbone.Marionette.Layout
  template: 'pages/modifications/layout'

  events:
    'click .remove-like' : 'removeLike'
    'click .remove-save' : 'removeSave'
    'change .filter-item select' : 'addFilter'

  regions:
    modsContainer: '.mods-list'

  initialize: ({ @modifications, @user, @activeTab, @filters })->
    @applied_filters = new Object()

  removeLike: (e) ->
    modId = $(e.currentTarget).data('modification-id')
    modificationUnlike = new Models.ModificationUnlike(modification_id: modId)
    modificationUnlike.save null, success: =>
      modifications = new Collections.UserModifications
      modifications.fetch data: {user_id: @user.id, type: @activeTab}, success: (modifications) =>
        @modifications = modifications
        @render()
    false

  removeSave: (e) ->
    modId = $(e.currentTarget).data('modification-id')
    modificationDelete = new Models.ModificationDelete
      modification_id: modId
    modificationDelete.save null, success: =>
      modifications = new Collections.UserModifications
      modifications.fetch data: {user_id: @user.id, type: @activeTab}, success: (modifications) =>
        @modifications = modifications
        @render()
    false

  addFilter: (e) ->
    filters = new Object()
    @$('.filter-item select').each (i, e) ->
      name = $(e).data('name')
      val = $(e).val()
      if val isnt ''
        filters[name] = val

    @applied_filters = filters
    @renderWithFilters()
    false

  renderWithFilters: ->
    @modsContainer.show new Pages.Dashboard.NewsFeeds
      collection: if Object.keys(@applied_filters).length > 0 then (new Collections.UserModifications(@modifications.where(@applied_filters))) else @modifications

  onRender: ->
    _.defer => @$('select').chosen({include_empty: true, allow_single_deselect: true})
    @modsContainer.show new Pages.Dashboard.NewsFeeds
      collection: if Object.keys(@applied_filters).length > 0 then (new Collections.UserModifications(@modifications.where(@applied_filters))) else @modifications

  serializeData: ->
    modifications: @modifications
    filters: @filters