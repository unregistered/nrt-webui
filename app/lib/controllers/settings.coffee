require "nrt-webui/core"

App.SettingsController = Ember.Controller.extend(
    content: {
        'version': 0.1
        'canvas_mousemode': 'drag'
    }

    initialize: ->
        console.log "Do stuff"
)
