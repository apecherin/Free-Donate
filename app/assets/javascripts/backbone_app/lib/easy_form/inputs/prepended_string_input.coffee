#= require ./string_input

class Lib.EasyForm.Inputs.PrependedStringInput extends Lib.EasyForm.Inputs.StringInput
  tagName: 'input'
  persistedAttributes: { type: 'text' }

  constructor: ({@object, @fieldName, @inputHtmlOptions, @wrapperHtmlOptions, @labelHtmlOptions})->
    super
    @inputHtmlOptions['prependedString'] ||= '$'

  tagHtml: ->
    Lib.EasyForm.Components.Tag.make('div', {class: 'input-prepend'}, Lib.EasyForm.Components.Tag.make('span', {class: 'add-on'}, @inputHtmlOptions['prependedString']).toString() + super().toString())