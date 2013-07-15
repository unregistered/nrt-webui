"use strict"

###
Tracks the currently hovered object
###
angular.module('nrtWebuiApp').factory('HoverService', ($rootScope) ->
    self = {};

    self.hovered = null

    self.set = (obj) ->
        self.hovered._hovered = false if self.hovered # Clear old

        obj._hovered = true
        self.hovered = obj

    self.clear = ->
        self.hovered._hovered = false if self.hovered
        self.hovered = null

    return self
)
