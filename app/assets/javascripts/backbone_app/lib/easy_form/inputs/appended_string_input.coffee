#= require ./string_input

class Lib.EasyForm.Inputs.AppendedStringInput extends Lib.EasyForm.Inputs.StringInput
  tagName: 'input'
  persistedAttributes: { type: 'text' }

  constructor: ({@object, @fieldName, @inputHtmlOptions, @wrapperHtmlOptions, @labelHtmlOptions})->
    super
    @inputHtmlOptions['appendedString'] ||= ''

  tagHtml: ->
    Lib.EasyForm.Components.Tag.make('div', {class: 'input-append'}, super().toString() + Lib.EasyForm.Components.Tag.make('span', {class: 'add-on'}, @inputHtmlOptions['appendedString']).toString())