class Lib.EasyForm.Inputs.Abstract
  tagName: ''
  persistedAttributes: {}
  validAttributeNames: ['accept', 'align', 'alt', 'autocomplete', 'autofocus', 'checked', 'class', 'disabled',
                        'form', 'formaction', 'formenctype', 'formmethod', 'formnovalidate', 'formtarget', 'height', 'id', 'list',
                        'max', 'maxlength', 'min', 'multiple', 'name', 'pattern', 'placeholder', 'readonly', 'required',
                        'size', 'src', 'step', 'value', 'width']
  inputWrapper: true
  components: []

  constructor: ({@object, @fieldName, @inputHtmlOptions, @wrapperHtmlOptions, @labelHtmlOptions})->
    throw 'Invalid object for input' if typeof @object is 'undefined' or @object is null

    @inputHtmlOptions ||= {}
    @inputHtmlOptions['name'] ||= "#{@object.constructorName}[#{@fieldName}]"
    @inputHtmlOptions['id'] ||= "#{HAML.globals()['domId'](@object)}_#{@fieldName}"
    @inputHtmlOptions['value'] ||= @object.get(@fieldName)
    unless @inputHtmlOptions['value']?
      @inputHtmlOptions['value'] = ''

    @wrapperHtmlOptions = {} if typeof @wrapperHtmlOptions is 'undefined'
    @labelHtmlOptions = {} if typeof @labelHtmlOptions is 'undefined'
    @labelHtmlOptions['label'] ||= @fieldName.humanize() if typeof @labelHtmlOptions['label'] is 'undefined'

  input: ->
    if @wrapperHtmlOptions
      @wrapperHtml()
    else
      @labelHtml() + @inputHtml()

  labelHtml: ->
    if @labelHtmlOptions['label'].length
      Lib.EasyForm.Components.Tag.make('label', {class: 'control-label', for: @inputHtmlOptions['id']}, @labelHtmlOptions['label']).toString()
    else
      ''

  wrapperHtml: ->
    inputClasses = ['control-group', @inputHtmlOptions['id']]
    inputClasses.push @wrapperHtmlOptions['class'] if typeof @wrapperHtmlOptions['class'] isnt 'undefined'
    inputClasses.push 'error' if @isErrorsExists()

    Lib.EasyForm.Components.Tag.make('div', {class: inputClasses.join(' ')}, @labelHtml() + @inputHtml()).toString()

  inputHtml: ->
    if @tagName is ''
      throw 'Invalid @tagName for input'

    Lib.EasyForm.Components.Tag.make('div', {class: 'controls'}, @tagHtml().toString() + @errorsHtml()).toString()

  tagHtml: ->
    Lib.EasyForm.Components.Tag.make @tagName, @collectAttributes()

  isErrorsExists: ->
    typeof @object.validationErrors isnt 'undefined' && typeof @object.validationErrors[@fieldName] isnt 'undefined'

  errorsHtml: ->
    errors = ''

    if @isErrorsExists()
      for error in @object.validationErrors[@fieldName]
        errors += Lib.EasyForm.Components.Tag.make('span', {class: 'help-inline'}, error).toString()

    errors

  collectAttributes: ->
    validAttributes = Lib.Helpers.reject @inputHtmlOptions, (attr, value)=>
      attr not in @validAttributeNames || !value

    Lib.Helpers.merge(validAttributes, @persistedAttributes)