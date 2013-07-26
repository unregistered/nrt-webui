"use strict"

###
Uses mousetrap.js to get keyboard events
###
angular.module('nrtWebuiApp').factory('KeyboardShortcutService', ->
    self = {}

    ###
    Call the callback when the keys are pressed (outside of text input)
    sequence: string, like "command+shift+k", or array of strings
    callback: function (event, combo)
    ###
    self.bind = (sequence, callback) -> Mousetrap.bind(sequence, callback)

    return self
)
