class Models.BaseModel extends Backbone.RelationalModel

  validations: []
  validationErrors: {}

#  validations: [
#    attr: 'name'
#    validator: (name)=> name isnt ''
#    message: "can't be blank"
#  ,
#    attr: 'gender'
#    validator: (gender)=> gender in ['male', 'female']
#    message: 'should be male or female'
#  ]

  blackListJsonAtrributes: ->
    ['_errors']

  validate: ->
    @validationErrors = {}
    @runValidations()
    @populateRecievedErrors()

    false

  # NOTE: sorry for this trick. Until we have backbone 0.9.10 we need redefine save for validation and have custom isValid method.
  isCustomValid: ->
    @validate()
    Object.keys(@validationErrors).length is 0

  isServerValid: ->
    @validationErrors = {}
    @populateRecievedErrors()
    Object.keys(@validationErrors).length is 0


  runValidations: ->
    for validation in @validations
      throw 'InvalidValidation' if typeof (validation['attr']) is 'undefined' && !validation['attrs']? || typeof (validation['validator']) is 'undefined'

      if validation['attrs']?
        unless validation.validator @.attributes
          @addError validation.attrs[0], validation.message
      else
        unless validation.validator @get(validation.attr)
          @addError validation.attr, validation.message


  save: (key, value, options)->
    @unset('_errors', silent: true)
    if @isCustomValid()
      super
    else
      if _.isObject(key) || key is null
        error_callback = (value || {})['error']
      else
        error_callback = (options || {})['error']

      error_callback(@) if typeof error_callback isnt 'undefined'

  addError: (attr, error)->
    @validationErrors[attr] = [] if typeof @validationErrors[attr] is 'undefined'

    @validationErrors[attr].push error

  populateRecievedErrors: ->
    for attr, error of @get('_errors')
      @addError attr, error

  toJSON: ->
    json = super()

    for attr in @blackListJsonAtrributes()
      delete json[attr]
      delete json[attr]

    json