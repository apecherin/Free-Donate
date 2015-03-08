HAML.globals = ->
  domId: (object)->
    if typeof(object) is 'undefined'
      throw "Couldn't generate dom id for undefined object"

    "#{object.constructorName}_#{if object.isNew() then 'new' else object.id}"


  inputTag: (object, fieldName, {inputHtmlOptions, labelHtmlOptions, wrapperHtmlOptions})->
    new Lib.EasyForm.Inputs.StringInput(object: object, fieldName: fieldName, inputHtmlOptions: inputHtmlOptions, labelHtmlOptions: labelHtmlOptions, wrapperHtmlOptions: wrapperHtmlOptions).input()

  fileInputTag: (object, fieldName, {inputHtmlOptions, labelHtmlOptions, wrapperHtmlOptions})->
    new Lib.EasyForm.Inputs.FileInput(object: object, fieldName: fieldName, inputHtmlOptions: inputHtmlOptions, labelHtmlOptions: labelHtmlOptions, wrapperHtmlOptions: wrapperHtmlOptions).input()

  prependedInputTag: (object, fieldName, {inputHtmlOptions, labelHtmlOptions, wrapperHtmlOptions})->
    new Lib.EasyForm.Inputs.PrependedStringInput(object: object, fieldName: fieldName, inputHtmlOptions: inputHtmlOptions, labelHtmlOptions: labelHtmlOptions, wrapperHtmlOptions: wrapperHtmlOptions).input()

  appendedInputTag: (object, fieldName, {inputHtmlOptions, labelHtmlOptions, wrapperHtmlOptions})->
    new Lib.EasyForm.Inputs.AppendedStringInput(object: object, fieldName: fieldName, inputHtmlOptions: inputHtmlOptions, labelHtmlOptions: labelHtmlOptions, wrapperHtmlOptions: wrapperHtmlOptions).input()

  emailTag: (object, fieldName, {inputHtmlOptions, labelHtmlOptions, wrapperHtmlOptions})->
    new Lib.EasyForm.Inputs.EmailInput(object: object, fieldName: fieldName, inputHtmlOptions: inputHtmlOptions, labelHtmlOptions: labelHtmlOptions, wrapperHtmlOptions: wrapperHtmlOptions).input()

  checkboxTag: (object, fieldName, {inputHtmlOptions, labelHtmlOptions, wrapperHtmlOptions})->
    new Lib.EasyForm.Inputs.CheckboxInput(object: object, fieldName: fieldName, inputHtmlOptions: inputHtmlOptions, labelHtmlOptions: labelHtmlOptions, wrapperHtmlOptions: wrapperHtmlOptions).input()

  selectTag: (object, fieldName, {inputHtmlOptions, labelHtmlOptions, wrapperHtmlOptions})->
    new Lib.EasyForm.Inputs.SelectInput(object: object, fieldName: fieldName, inputHtmlOptions: inputHtmlOptions, labelHtmlOptions: labelHtmlOptions, wrapperHtmlOptions: wrapperHtmlOptions).input()

  radioTag: (object, fieldName, {inputHtmlOptions, labelHtmlOptions, wrapperHtmlOptions})->
    new Lib.EasyForm.Inputs.RadioInput(object: object, fieldName: fieldName, inputHtmlOptions: inputHtmlOptions, labelHtmlOptions: labelHtmlOptions, wrapperHtmlOptions: wrapperHtmlOptions).input()