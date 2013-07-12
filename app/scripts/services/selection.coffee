"use strict"

angular.module('nrtWebuiApp').factory('SelectionService', ->
    self = {};

    self.content = []

    self.setSelection = (obj) ->
        self.clearSelection()

        if obj instanceof Array
            _.each obj, (item) ->
                item.selected = true
                self.content.push(item)
        else
            item.selected = true
            self.content.push item

    return self
)
