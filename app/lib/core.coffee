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
            port: 8080
        ),
        App.Server.create(
            name: 'iLab'
            host: '55.221.13.240'
            port: 9000
        )
    ]
)
