{Game} = require './src/core'
game = new Game
game.start()

config = require './config'
nstore = require('nstore')
Users = nstore.new("savedata.db")
{create_new} = require './src/char'
util = require './src/Util'


require('zappa') config.port, ->
  @io.configure =>
    @io.set( "log level", 1 )
    # @io.set "authorization", (handshakeData, callback) ->
    #   cookie = handshakeData.headers.cookie;
    #   handshakeData.foo = cookie
    #   console.log cookie
    #   callback(null, true)


  @app.use @express.bodyParser()
  @app.use @express.methodOverride()
  @app.use @express.cookieParser()
  @app.use @express.session
    secret: config.session_secret
    cookie: { maxAge: 86400 * 1000 }
  @app.use @app.router
  @app.use @express.static __dirname+'/public'
  @app.set 'views', __dirname + '/views'
  @app.use @express.favicon()

  @set 'views', __dirname + '/views'
  @enable 'serve jquery'

  @shared "/shared.js":->
    r = window ? global
    r.d = (e)->
      console.log e

    r.getkey = (keyCode) ->
      switch keyCode
        when 68,39 then return 'right'
        when 65,37 then return 'left'
        when 87,38 then return 'up'
        when 83,40 then return 'down'
        when 32 then return 'space'
        when 17 then return 'ctrl'
        when 48 then return 'zero'
        when 49 then return 'one'
        when 50 then return 'two'
        when 51 then return 'three'
        when 52 then return 'four'
        when 53 then return 'five'
        when 54 then return 'sixe'
        when 55 then return 'seven'
        when 56 then return 'eight'
        when 57 then return 'nine'
      return String.fromCharCode(keyCode).toLowerCase()

  game.sockets = @io.sockets
  # Rooting
  @get '/logout': ->
    @session.destroy ()=>
      @redirect '/'

  @get '/api/id': ->
    @send @session.name or ''

  @get '/': ->
    console.log @session.name
    @session.name = "mizchi"  # for debug
    if @session.name
      @render index:
        id : @session.name
    else
      @render login:{layout:false}

  twoauth = require('./twitter_oauth')
  @get '/verify' : ->
    twoauth.verify @request,@response,(token,token_secret,results)=>
      @session.name = results.screen_name
      console.log "[login] #{results.screen_name}"
      @redirect '/'

  @client '/bootstrap.js': ->
    window.view =
      ObjectInfo : ko.observable []
      CharInfo : ko.observable null
      CoolTime : ko.observable []
      use_battle_point: (e)->
        at = $(e.target).attr('target')
        soc.emit 'use_battle_point', at:at

  save = (char,fn=->)->
    return fn(true,null) unless char?.name
    Users.get char.name, (e,item)->
      console.log "save : ", char.name
      Users.save char.name , char.toData() ,(e)->
        if e
          console.log e
        fn()

  # emitter for client
  game.ws = =>
    objs = game.stages.f1.objects.concat (v for k,v of game.stages.f1.players)
    ret = objs.map (i)->
      o:[i.x,i.y,i.id,i.group]
      s:
        n : i.name
        hp :~~(100*i.status.hp/i.status.HP)
        lv: i.status.lv
      a:[]

    @io.sockets.emit 'update',
      objs: ret

    for id,player of game.stages.f1.players
      seq = ['one','two','three','four','five','six','seven','eight','nine','zero']
      buff = []
      for i in seq 
        if s = player.skills[i]
          buff.push ~~(100*s.ct/s.CT)
      @io.sockets.socket(id).emit 'update_ct',cooltime:buff

      if game.cnt%(15*120) is 0
        @io.sockets.socket(id).emit 'update_char',player.toData()

  # ==== clinet wewbsocket ====
  @client '/index.js': ->
    window.soc = @connect()

    @on connection: ->
      grr.map = @data.map
      grr.create_map @data.map
      grr.uid = @data.uid

    @on update: ->
      view.ObjectInfo @data.objs
      grr.render @data

    @on update_ct: ->
      view.CoolTime @data.cooltime

    @on update_char: ->
      view.CharInfo @data

  # ==== server wewbsocket ====

  @on connection: ->
    d "Connected: #{@id}"
    @emit 'connection',map:game.stages.f1._map,uid:@id

  @on disconnect: ->
    d "Disconnected: #{@id}"
    char = game.stages.f1.players[@id]
    save char,=>
      game.stages.f1.leave(@id)

  @on keydown: ->
    game.stages.f1.players[@id]?.keys[@data.code] = 1


  @on keyup: ->
    game.stages.f1.players[@id]?.keys[@data.code] = 0

  @on click_map: ->
    console.log @data.x , @data.y
    game.stages.f1.players[@id]?._wait = 0
    game.stages.f1.players[@id]?.destination =
      x:@data.x
      y:@data.y

  @on use_battle_point: ->
    game.stages.f1.players[@id]?.status.use_battle_point(@data.at)
    save game.stages.f1.players[@id],->d 'save done'
    @emit 'update_char', game.stages.f1.players[@id]?.toData()

  _io = @io
  @on login: ->
    name = @data.name
    Users.get name, (e,savedata)=>
      # if savedata
      if savedata
        d "[load] #{@data.name}"
        d savedata
        # game.stages.f1.join(@id,name,savedata)

      else
        savedata = create_new(name,'human','Lord')
        d "[create] #{@data.name}"
        Users.save name , savedata,(e)->
          console.log e if e

      # soc = _io.sockets.socket(id)
      game.stages.f1.join @id,name,savedata,@emit
      @emit 'update_char', savedata

  setInterval ->
    d "inteval save"
    for k,v of game.stages.f1.players
      save v,=>
  ,1000*60*15


  @view login:->
    doctype 5
    html ->
      head lang:'ja',->
        title 'Dia-Net'
        (link rel:"stylesheet",type:"text/css",href:i) for i in [
          "/bootstrap.min.css"
        ]
      body ->
        div class:"container-fluid",->
          h1 -> "Dia-Net"
          div class:"content",->
            a href:"/verify",-> "Twitterでログイン"

