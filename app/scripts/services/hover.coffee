"use strict"

###
Tracks the currently hovered object
###
angular.module('nrtWebuiApp').factory('HoverService', ($rootScope) ->
    self = {};

    self.hovered = null
    self.hovered_type = null

    self.getType = ->
        return self.hovered_type

    self.getHovered = (type) ->
        return null unless self.hovered_type == type
        return self.hovered

    self.set = (type, obj) ->
        self.hovered._hovered = false if self.hovered # Clear old

        obj._hovered = true
        self.hovered = obj
        self.hovered_type = type

        $rootScope.$broadcast("HoverService.hover_changed")

    self.clear = ->
        self.hovered._hovered = false if self.hovered
        self.hovered = null
        self.hovered_type = null

        $rootScope.$broadcast("HoverService.hover_changed")

    return self
)
