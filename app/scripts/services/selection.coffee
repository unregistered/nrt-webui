"use strict"

###
SelectionService
Tracks selected objects and selected types. Supports multiple selection.
@broadcasts SelectionService.selection_changed
###
angular.module('nrtWebuiApp').factory('SelectionService', ($rootScope) ->
    self = {};

    self.content = {}

    ###
    Get selected objects of type
    ###
    self.get = (type) ->
        ret = self.content[type]
        return [] unless ret
        return ret

    ###
    Append obj of string type "type" into the selection database.
    obj can be an array of objs to append
    ###
    # Private append - does not broadcast event
    self._append = (type, obj) ->
        self.content[type] = [] unless self.content[type]

        if obj instanceof Array
            _.each obj, (it) ->
                obj._selected = true
                self.content[type].push obj
        else
            obj._selected = true
            self.content[type].push obj

    # Public append - broadcasts event
    self.append = (type, obj) ->
        self._append(type, obj)
        $rootScope.$broadcast("SelectionService.selection_changed")

    ###
    Replace current selection with objects in 'obj' of type 'type'
    ###
    self.set = (type, obj) ->
        self._clear()

        if obj instanceof Array
            _.each obj, (it) ->
                self._append(type, obj)
        else
            self._append(type, obj)

        $rootScope.$broadcast("SelectionService.selection_changed")

    ###
    Clear selection
    ###
    # Private clear - does not broadcast event
    self._clear = ->
        _.each self.content, (it, key) ->
            _.each it, (obj) ->
                obj._selected = false

        self.content = {}

    # Public clear - broadcasts event
    self.clear = ->
        self._clear()
        $rootScope.$broadcast("SelectionService.selection_changed")

    return self
)
