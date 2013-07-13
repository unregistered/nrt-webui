"use strict"

angular.module('nrtWebuiApp').factory('SelectionService', ->
    self = {};

    self.content = {}

    ###
    Get selected objects of type
    ###
    self.get = (type) ->
        return self.content[type]

    ###
    Append obj of string type "type" into the selection database.
    obj can be an array of objs to append
    ###
    self.append = (type, obj) ->
        console.log "Append selection", type, obj
        self.content[type] = [] unless self.content[type]

        if obj instanceof Array
            _.each obj, (it) ->
                obj._selected = true
                self.content[type].push obj
        else
            obj._selected = true
            self.content[type].push obj

    ###
    Replace current selection with objects in 'obj' of type 'type'
    ###
    self.set = (type, obj) ->
        self.clear()

        if obj instanceof Array
            _.each obj, (it) ->
                self.append(type, obj)
        else
            self.append(type, obj)

    ###
    Clear selection
    ###
    self.clear = ->
        _.each self.content, (it, key) ->
            console.log "Clear", key
            _.each it, (obj) ->
                console.log "->", obj
                obj._selected = false

        self.content = {}

    return self
)
