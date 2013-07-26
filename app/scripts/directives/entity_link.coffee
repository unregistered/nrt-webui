###
This file contains text links for modules, ports, connections, etc.
When clicked, they will update the SelectionService to select the appropriate entity.
###

"use strict"

angular.module("nrtWebuiApp").directive "entityLink", (SelectionService, HoverService) ->
    restrict: "E"
    scope:
        model: "="

    template: """
    <a href="#" class="entity-link">{{getSymbol()}} {{getName()}}</a>
    """

    link: (scope, iElement, iAttrs, controller) ->
        scope.getSymbol = ->
            return "" unless scope.model
            if iAttrs.type is "port"
                return "ⓟ" if scope.model.orientation is "poster"
                return "ⓢ" if scope.model.orientation is "subscriber"
                return "ⓚ" if scope.model.orientation is "checker"

            return "ⓜ" if iAttrs.type is "module"
            return "ⓒ" if iAttrs.type is "connection"
            return ""

        scope.getName = ->
            return "" unless scope.model
            return scope.model.portname if iAttrs.type is "port"
            return scope.model.classname if iAttrs.type is "module"
            return "Unknown Entity"

        iElement.click(->
            SelectionService.set iAttrs.type, scope.model
            HoverService.clear()
            scope.$apply()
            return false # Prevents link from updating the browser's location
        ).mouseover(->
            HoverService.set iAttrs.type, scope.model
            scope.$apply()
        ).mouseout(->
            HoverService.clear()
            scope.$apply()
        )

