"use strict"

###
SelectionService
Tracks selected objects and selected types. Supports multiple selection.
@broadcasts SelectionService.selection_changed
###
angular.module('nrtWebuiApp').factory('SelectionService', ($rootScope) ->
    self = {};

    self._content = {}

    ###
    Get selected objects of type
    @argument type: a string of type, such as 'module' or 'port'
    ###
    self.get = (type) ->
        ret = self._content[type]
        return [] unless ret
        return ret

    ###
    Get all the types selected as an array
    ###
    self.getTypes = ->
        return _(self._content).keys()

    ###
    Append obj of string type "type" into the selection database.
    obj can be an array of objs to append
    ###
    # Private append - does not broadcast event
    self._append = (type, obj) ->
        self._content[type] = [] unless self._content[type]

        if obj instanceof Array
            _.each obj, (it) ->
                obj._selected = true
                self._content[type].push obj
        else
            obj._selected = true
            self._content[type].push obj

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
        _.each self._content, (it, key) ->
            _.each it, (obj) ->
                obj._selected = false

        self._content = {}

    # Public clear - broadcasts event
    self.clear = ->
        self._clear()
        $rootScope.$broadcast("SelectionService.selection_changed")

    return self
)
