class Lib.EasyForm.Inputs.SelectInput extends Lib.EasyForm.Inputs.Abstract
  tagName: 'select'
  validAttributeNames: ['autofocus', 'class', 'disabled', 'form', 'id', 'multiple', 'name', 'required', 'size']

  constructor: ({@object, @fieldName, @inputHtmlOptions, @wrapperHtmloptions, @labelHtmlOptions})->
    super

    @inputHtmlOptions['selected'] ||= @object.get(@fieldName) if typeof @object.get(@fieldName) isnt 'undefined' && @object.get(@fieldName)


  inputHtml: ->
    if @tagName is ''
      throw 'Invalid @tagName for input'

    Lib.EasyForm.Components.Tag.make('div', {class: 'controls'}, Lib.EasyForm.Components.Tag.make(@tagName, @collectAttributes(), @optionsHtml()).toString() + @errorsHtml()).toString()


  optionsHtml: ->
    valueMethod = @inputHtmlOptions['valueMethod'] || 'toString'
    labelMethod = @inputHtmlOptions['labelMethod'] || 'toString'
    additionalOption = @inputHtmlOptions['additionalOption'] || false

    res = @inputHtmlOptions['collection'].reduce (acc, element)=>
      options = value: if _.isFunction(valueMethod) then valueMethod(element) else _.result(element, valueMethod)

      if options['value'] is @inputHtmlOptions['selected']
        options['selected'] = 'selected'

      acc + Lib.EasyForm.Components.Tag.make('option', options, if _.isFunction(labelMethod) then labelMethod(element) else _.result(element, labelMethod))
    , ''

    if additionalOption
      option = '<option class=' + additionalOption['class'] + ' id="' + additionalOption['id'] + '">' + additionalOption['name'] + '</option>'
      if additionalOption['new_to_end']
        res = res + option
      else
        res = option + res
    res