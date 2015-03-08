class Lib.EasyForm.Inputs.RadioInput extends Lib.EasyForm.Inputs.Abstract
  tagName: 'input'
  persistedAttributes: { type: 'radio' }

  constructor: ({@object, @fieldName, @inputHtmlOptions, @wrapperHtmloptions, @labelHtmlOptions})->
    super