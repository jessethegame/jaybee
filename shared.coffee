# Collections
#
@PlaylistTracks = new Meteor.Collection("playlist_tracks")
@PlayedTracks = new Meteor.Collection("played_tracks")
@Masters = new Meteor.Collection("masters")

# Subscribes
if Meteor.isClient
  @accessTokenDep = new Deps.Dependency

  # Init custom classes
  @player = new Player
  @search = new Search

  Meteor.subscribe 'SC.OAuth', ->
    if Meteor.user()
      # Set Access Token
      accessToken = Meteor.user().services.soundcloud.accessToken
      if accessToken
        accessTokenDep.changed()
        SC.accessToken accessToken

        # Get and set favorites
        player.getFavorites()

  Meteor.autosubscribe ->
    PlaylistTracks.find().observeChanges
      changed: (id, fields) ->
        # Update now playing
        Meteor.call "nowPlaying", (error, track) ->
          Session.set "now_playing", track

        if fields.now_playing and fields.now_playing == true
          player.play id

    Masters.find().observeChanges
      changed: (id, fields) ->
        player.setVolume fields.volume if fields.volume?


# Routes
Router.map () ->
  this.route 'home',
    path: '/'
