

############################################################################################################
njs_util                  = require 'util'
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'Xmap'
# log                       = CND.get_logger 'plain',     badge
# info                      = CND.get_logger 'info',      badge
# whisper                   = CND.get_logger 'whisper',   badge
# alert                     = CND.get_logger 'alert',     badge
# debug                     = CND.get_logger 'debug',     badge
# warn                      = CND.get_logger 'warn',      badge
# help                      = CND.get_logger 'help',      badge
# urge                      = CND.get_logger 'urge',      badge
# echo                      = CND.echo.bind CND
CODEC                     = require 'hollerith-codec'

### inspired by
https://www.reddit.com/r/javascript/comments/4hy2cc/what_is_this_and_is_it_worth_it/
https://www.npmjs.com/package/hasharray
###

# SELF = Symbol.for '%self'
SELF = '%self'

#-----------------------------------------------------------------------------------------------------------
class Xmap # extends Map

  #.........................................................................................................
  constructor: ( iterable ) ->
    @[ SELF ] = new Map iterable
    Object.defineProperty @, 'size', {
      # value: 37,
      # writable: true,
      # enumerable: true,
      # configurable: true
      get:        => @[ SELF ].size
      set: ( n )  => @[ SELF ].size = n
    }
    return @

  # #.........................................................................................................
  # toString: ->
  #   return rpr @[ SELF ]

  #.........................................................................................................
  encode: ( key )         -> ( CODEC.encode [ key, ] ).toString 'binary'
  decode: ( key )         -> ( CODEC.decode new Buffer key, 'binary' )[ 0 ]

  #.........................................................................................................
  set:    ( key, value )  -> @[ SELF ].set  ( @encode key ), value
  get:    ( key )         -> @[ SELF ].get    @encode key
  has:    ( key )         -> @[ SELF ].has    @encode key
  delete: ( key )         -> @[ SELF ].delete @encode key
  clear:                  -> @[ SELF ].clear()

  #.........................................................................................................
  forEach: ( handler, self ) ->
    self ?= @
    return @[ SELF ].forEach ( ( value, key, self ) => handler value, ( @decode key ), self ), self

  #.........................................................................................................
  keys: -> do =>
    keys = @[ SELF ].keys()
    loop
      { value, done } = keys.next()
      break if done
      yield @decode value
    return null

  #.........................................................................................................
  values: -> do =>
    values = @[ SELF ].values()
    loop
      { value, done } = values.next()
      break if done
      yield value
    return null

  #.........................................................................................................
  entries: -> do =>
    entries = @[ SELF ].entries()
    loop
      { value, done } = entries.next()
      break if done
      yield [ ( @decode value[ 0 ] ), value[ 1 ], ]
    return null

#-----------------------------------------------------------------------------------------------------------
module.exports = Xmap

