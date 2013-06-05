define [
  'handlebars'
],(Handlebars) ->
  Handlebars.registerHelper "debug",(value) ->
    console.log("Context")
    console.log("=========")
    console.log(this)

    if value?
      console.log("Value")
      console.log("=========")
      console.log(value)

  Handlebars.registerHelper 'assign',() ->
    args = []
    for ar in arguments
      if typeof(ar) == 'string'
        args.push(ar)
    Handlebars.registerHelper arguments[0], args.join( '' )
    return ''

  Handlebars.registerHelper 'compare', (lvalue, rvalue, options) ->

    if arguments.length < 3
        throw new Error("Handlerbars Helper 'compare' needs 2 parameters");

    operator = options.hash.operator || "==";

    operators = 
      '==':       (l,r) ->  l == r
      '!=':       (l,r) ->  l != r
      '<':        (l,r) ->  l < r
      '>':        (l,r) ->  l > r
      '<=':       (l,r) ->  l <= r
      '>=':       (l,r) ->  l >= r
      'typeof':   (l,r) ->  typeof l == r
      'isNull':   (l,r) ->  l is null
    

    if !operators[operator]
        throw new Error("Handlerbars Helper 'compare' doesn't know the operator "+operator);

    result = operators[operator](lvalue,rvalue);

    if result
        options.fn(this);
    else 
        options.inverse(this);
    
  Handlebars.registerHelper 'eq',(r,v,options) ->
    console.log([r,v])
    if r == v 
      options.fn(this)
    else
      options.inverse(this)

  Handlebars.registerHelper 'iter',(context,options) ->
    ret = ""
    if context? && context.length > 0
      for a,i in context
        ret = ret + options.fn(_.extend({},a,{i:i,iPlus1:i + 1}))
    else
      ret = options.inverse(this)
    return ret

  Handlebars.registerHelper 'iterTo', (start,end,options) ->
    ret = ""
    a = [start..end]
    for i in a 
      ret = ret + options.fn( _.extend({},a,{i:i,iPlus1:i + 1}) )
    return ret

  Handlebars.registerHelper 'iterTorev', (start,end,options) ->
    ret = ""
    a = [start..end]
    for i in a by -1
      ret = ret + options.fn( _.extend({},a,{i:i,iPlus1:i - 1}) )
    return ret




