#= require ./base_model

class Models.User extends Models.BaseModel
  constructorName: 'user'

  validations: [
    attr: 'username'
    validator: (userName)=> typeof userName isnt 'undefined' && userName isnt null
    message: "can't be blank"
  ,
    attr: 'username'
    validator: (userName)=> typeof userName isnt 'undefined' && userName.length >= 3 && userName.length < 40
    message: "should be 3-40 characters long"
  ,
    attr: 'email'
    validator: (email)=> typeof email isnt 'undefined' && email isnt null
    message: "can't be blank"
  ,
    attr: 'email'
    validator: (email)=>
      re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      re.test email
    message: "has wrong format"
  ,
    attr: 'terms_of_service'
    validator: (termsOfService)=> typeof termsOfService is 'undefined' || termsOfService
    message: "can't be blank"
  ]

  urlRoot: '/api/users'

  blackListJsonAtrributes: ->
    super.concat ['vehicles']


  toJSON: ->
    json = super

    # Note: not sure that we even need it to be pushed
    delete json['comparisonTables'] if isNaN parseInt json['comparisonTables']
    delete json['bookmarkedVehicles'] if isNaN parseInt json['bookmarkedVehicles']

    delete json['pictures_attributes'] if json['pictures_attributes'] is null or typeof json['pictures_attributes'] is 'undefined'

    delete json['email'] unless @isNew()

    if json['email'] isnt undefined
      json['user_account_attributes'] = {email: json['email']}
      delete json['email']

    if json['terms_of_service'] isnt undefined && json['terms_of_service']
      json['terms_of_service'] = '1'

    json

  parse: (attrs)->
    if typeof attrs['_errors'] isnt 'undefined'

      attrs['_errors']['email'] = attrs['_errors']['user_account.email'] if typeof attrs['_errors']['user_account.email'] isnt 'undefined'

    attrs