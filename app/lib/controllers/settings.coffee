require "nrt-webui/core"

# Constants
App.SETTING_CANVAS_MOUSEMODE_DRAG = 'drag'
App.SETTING_CANVAS_MOUSEMODE_SELECT = 'select'

App.SettingsController = Ember.Controller.extend(
    content: {
        'version': 0.1
        'canvas_mousemode': App.SETTING_CANVAS_MOUSEMODE_DRAG
    }

    initialize: ->
        console.log "Do stuff"
)
