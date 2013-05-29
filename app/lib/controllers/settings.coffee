require "nrt-webui/core"

# Constants
App.SETTING_CANVAS_MOUSEMODE_DRAG = 'drag'
App.SETTING_CANVAS_MOUSEMODE_SELECT = 'select'

App.SETTING_SHOW_INTERNAL_MODULES = 'masochism'
App.SETTING_HIDE_INTERNAL_MODULES = 'hidemodules'

App.SettingsController = Ember.Controller.extend(
    content: {
        'version': 0.1
        'canvas_mousemode': App.SETTING_CANVAS_MOUSEMODE_DRAG
        'module_visibility': App.SETTING_HIDE_INTERNAL_MODULES
    }

    initialize: ->
        console.log "Do stuff"
)
