class Lib.EasyForm.Inputs.CheckboxInput extends Lib.EasyForm.Inputs.Abstract
  tagName: 'input'
  persistedAttributes: { type: 'checkbox' }

  constructor: ({@object, @fieldName, @inputHtmlOptions, @wrapperHtmloptions, @labelHtmlOptions})->
    super

    @inputHtmlOptions['checked'] = 'checked' if typeof @object.get(@fieldName) isnt 'undefined' && @object.get(@fieldName)