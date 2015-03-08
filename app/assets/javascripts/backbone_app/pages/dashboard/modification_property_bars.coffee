class Pages.Dashboard.ModificationPropertyBars extends Backbone.Marionette.CollectionView
  itemView: Pages.Dashboard.ModificationPropertyBar

  initialize: ({@versionProperties})->

  buildItemView: (item, ItemView)->
    itemViewOptions = _.result @, "itemViewOptions"
    options = _.extend {model: item}, itemViewOptions, stockProperty: @findByName(@versionProperties, item.get('name'))

    new ItemView(options)

  findByName: (properties, name) ->
    desired_property = ''
    properties.each (property, i) ->
      if property.name is name
        return desired_property = property

    desired_property