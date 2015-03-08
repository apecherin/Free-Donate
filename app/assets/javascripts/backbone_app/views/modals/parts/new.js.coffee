# FIXME: When we focus a text field an hit Enter, the modal hides.
class Modals.Parts.New extends Backbone.Marionette.ItemView
  template: 'modals/parts/new'

  events:
    'submit form' : 'createPart'

    'change #label'     : 'changeLabel'
    'change #reference' : 'changeReference'
    'change #category'  : 'changeCategory'

    'click tr.new-supplier button' : 'addSupplierReference'
    'click .add-supplier'          : 'showSupplierReferenceForm'
    'click .remove-reference'      : 'removeSupplierReference'


  initialize: (attributes)->
    @vehicle = attributes.vehicle
    @part    = attributes.part
    @part.set 'brand', @vehicle.get 'brand'


  changeLabel: (event)->
    @part.set(label: event.target.value)


  changeReference: (event)->
    @part.set(manufacturer_reference: event.target.value)


  changeCategory: (event)->
    id       = event.target.value
    text     = $(event.target).find('option:selected').text().trim()
    category = new parts.Category()

    @part.set(category: category)


  # Display the form row to add new supplier.
  showSupplierReferenceForm: ->
    if @$('tr.new-supplier').length == 0
      $row = $(JST['modals/parts/new_supplier']())
      @$('table tbody').append($row)

    false


  # Add the row in the DOM and in the array.
  addSupplierReference: ->
    $row      = @$('tr.new-supplier')
    name      = $row.find('.name').val().trim()
    reference = $row.find('.reference').val().trim()
    obsolete  = $row.find('.obsolete').prop('checked')

    if 0 < name.length && 0 < reference.length
      supplier = { name, reference, obsolete }
      viewData = { supplier, showControls: true }
      $newRow  = $(JST['modals/parts/supplier'](viewData))

      $row.replaceWith($newRow)
      @part.get('supplierReferences').push(supplier)

    false


  # Remove the row from the DOM and the array element.
  removeSupplierReference: (event)->
    $row      = $(event.target).parents('tr:first')
    name      = $row.find('.name').text().trim()
    reference = $row.find('.reference').text().trim()

    suppliers = @part.get('supplierReferences')
    remaining = _.reject suppliers, (supplier)->
      supplier.name == name && supplier.reference == reference

    @part.set(supplierReferences: remaining)
    $row.remove()
    false


  createPart: (event)->
    label = @part.get('label') || ''

    if 0 < label.length
      @trigger('part:created', @part)
      @part.save()
      @close()

    false


  serializeData: ->
    part:      @part
    brand:     @vehicle.get('brand')
    countries: @countries


  onRender: ->
    callback = => @$('select').chosen(no_results_text: ' ')
    setTimeout(callback, 0)
