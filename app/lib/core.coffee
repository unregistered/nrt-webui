require('jquery')
require('handlebars')
require('ember')
require('ember-data')
require('nrt-webui/ext')
require('nrt-webui/env')

require 'bootstrap'
require 'when' # Deferreds for autobahn
require 'autobahn'
require 'raphael'
require 'raphael-zpd' # Zoom
require 'jquery-ui'

window.App = Ember.Application.create(
  VERSION: '0.1'
  ready: ->
    App.router.serversController.pushObjects [
        # App.Server.create(
        #     name: 'localhost'
        #     host: 'localhost'
        #     port: 9000
        # ),
        App.Server.create(
            name: 'UbuntuVM'
            host: 'ubuntu1204.local'
            port: '8080'
        ),
        App.Server.create(
            name: 'iLab'
            host: '55.221.13.240'
            port: '9000'
        )
    ]
)

App.str2color = (str) ->
    hashfunc = (str) ->
        hash = 0;
        i = 0;
        while i < str.length
            hash = str.charCodeAt(i) + ((hash << 5) - hash)
            i++
        return hash

    rgbfunc = (i) ->
        r = ((i>>24)&0xFF).toString(16)
        r = '0' + r if r.length == 1
        g = ((i>>16)&0xFF).toString(16)
        g = '0' + g if g.length == 1
        b = ((i>>8)&0xFF).toString(16)
        b = '0' + b if b.length == 1
        return '#'+r+g+b;

    return rgbfunc(hashfunc(str))
