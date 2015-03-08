#= require ./domain_modification_item

class Pages.Vehicles.Modifications.DomainModificationItems extends Backbone.Marionette.CollectionView
  itemView: Pages.Vehicles.Modifications.DomainModificationItem

  initialize: ({@versionProperties})->

  itemViewOptions: ->
    versionProperties: @versionProperties

  buildItemView: (item, ItemView)->
    itemViewOptions = _.result @, "itemViewOptions"
    options = _.extend {model: item}, itemViewOptions, indexNumber: @collection.indexOf(item)

    new ItemView(options)