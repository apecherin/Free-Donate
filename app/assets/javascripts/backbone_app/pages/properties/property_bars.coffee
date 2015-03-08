class Pages.Properties.PropertyBars extends Backbone.Marionette.CollectionView
  itemView: Pages.Dashboard.ModificationPropertyBar

  initialize: ({@versionProperties})->

  buildItemView: (item, ItemView)->
    itemViewOptions = _.result @, "itemViewOptions"
    options = _.extend {model: item}, itemViewOptions, stockProperty: @versionProperties.findByName(item.get('name'))

    new ItemView(options)