"use strict"

###
Provides application global settings, which includes constants an user configurable settings.
Allows settings to be serialized and saved, or loaded.
###
angular.module('nrtWebuiApp').factory('ConfigService', ->
    self = {};

    ###
    Constants
    ###

    # GUI appearance settings constants
    self.UI_PORT_BORDER_RADIUS = 4
    self.UI_PORT_WIDTH = 20
    self.UI_PORT_HEIGHT = 10
    self.UI_PORT_INITIAL_OFFSET = 20
    self.UI_PORT_SPACING = 8

    self.UI_CANVAS_WIDTH = 1000
    self.UI_CANVAS_HEIGHT = 1000

    self.UI_MODULE_IMAGE_WIDTH = 25

    self.UI_CONNECTION_INACTIVE_COLOR = "#ccc"
    self.UI_CONNECTION_ACTIVE_COLOR = "#000"

    # Controls whether dragging on the canvas will drag the canvas or allow for multiple selection
    self.SETTING_CANVAS_MOUSEMODE_DRAG = 'drag'
    self.SETTING_CANVAS_MOUSEMODE_SELECT = 'select'

    # Toggles visibility of nrt's internal modules
    self.SETTING_SHOW_INTERNAL_MODULES = 'masochism'
    self.SETTING_HIDE_INTERNAL_MODULES = 'hidemodules'

    ###
    Variables in settings will be serialized
    ###
    self.settings = {
        'version': 0.1
        'canvas_mousemode': self.SETTING_CANVAS_MOUSEMODE_DRAG
        'module_visibility': self.SETTING_SHOW_INTERNAL_MODULES
    }

    return self
)
