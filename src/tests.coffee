

############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'Xmap/tests'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
Xmap                      = require './main'


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
show_keys_and_key_bfrs = ( keys, key_bfrs ) ->
  f = ( p ) -> ( t for t in ( p.toString 'hex' ).split /(..)/ when t isnt '' ).join ' '
  #.........................................................................................................
  columnify_settings =
    paddingChr: ' '
  #.........................................................................................................
  data      = []
  key_bfrs  = ( f p for p in key_bfrs )
  for key, idx in keys
    key_txt = ( rpr key ).replace /\\u0000/g, '∇'
    data.push { 'str': key_txt, 'bfr': key_bfrs[ idx ]}
  help '\n' + CND.columnify data, columnify_settings
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "test 1" ] = ( T ) ->
  d = new Xmap()
  d.set [ 1234, ], 'helo'
  d.set 12.8, 'helo 12.8'
  d.set true, 'helo true'
  d.set null, 'helo null'
  d.set Infinity, "truly huge"
  d.set [ 'abcäöüz', null, true, ], 'oops'
  T.eq d.size, 6
  T.eq ( d.get [ 1234, ]  ) , 'helo'
  T.eq ( d.get 12.8       ) , 'helo 12.8'
  T.eq ( d.get true       ) , 'helo true'
  T.eq ( d.get null       ) , 'helo null'
  T.eq ( d.get Infinity   ) , "truly huge"
  T.eq ( d.get [ 'abcäöüz', null, true, ] ), 'oops'
  # help '0713', d.get [ 1234, ]
  # help '0713', d.get [ 'abcäöüz', null, true, ]
  # urge d.decode 'ETabcÃ¤Ã¶Ã¼z\u0000BD\u0000'
  # help Array.from d.keys()
  # help Array.from d.values()
  # help Array.from d.entries()
  # help d.size
  # help d.size = 3
  # help d.size
  # urge '4432', d
  # d.forEach ( value, key, me ) ->
  #   urge ( rpr key ), ( rpr value ) #, ( rpr me )
  # CND.dir d

#-----------------------------------------------------------------------------------------------------------
demo = ->
  d = new Xmap()
  d.set [ 1234, ], 'helo'
  d.set 12.8, 'helo 12.8'
  d.set true, 'helo true'
  d.set null, 'helo null'
  d.set Infinity, "truly huge"
  d.set [ 'abcäöüz', null, true, ], 'oops'
  help '0713', d.get [ 1234, ]
  help '0713', d.get [ 'abcäöüz', null, true, ]
  help '0713', d.get [ 'abcäöüz', null, true, ]
  urge d.decode 'ETabcÃ¤Ã¶Ã¼z\u0000BD\u0000'
  help Array.from d.keys()
  help Array.from d.values()
  help Array.from d.entries()
  help d.size
  help d.size = 3
  help d.size
  urge '4432', d
  d.forEach ( value, key, me ) ->
    urge ( rpr key ), ( rpr value ) #, ( rpr me )
  # CND.dir d

#-----------------------------------------------------------------------------------------------------------
@_prune = ->
  for name, value of @
    continue if name.startsWith '_'
    delete @[ name ] unless name in include
  return null


############################################################################################################
unless module.parent?
  # debug '0980', JSON.stringify ( Object.keys @ ), null, '  '
  include = []
  # @_prune()
  test @






