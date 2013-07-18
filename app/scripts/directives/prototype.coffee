"use strict"

angular.module("nrtWebuiApp").directive "prototype", ($compile) ->
    restrict: "E"
    scope:
      model: "="

    template: """
    <span>
        <img width="20px" ng-show="!model.children" src="data:{{model.iconext | ext2mime}};base64,{{model.icondata}}">
        {{ model.name }}
    </span>
    """

    link: (scope, iElement, iAttrs, controller) ->
        iElement.draggable(
            opacity: 0.7
            cursor: "crosshair"
            cursorAt: { top: 5, left: 0 } # Offset of the helper
            helper: (event) =>
                # The helper floats beneath the mouse as the user drags
                img = iElement.find('img')
                e = $("<span class='ui-widget-helper'>'#{scope.model.name}'</span>")
                $(img[0]).clone().prependTo(e)
                return e
            revert: "invalid" # If dropped on an invalid location, show animation
            start: (event, ui) ->
                # Put the prototype in the context var of the event, to be consumed by the receiver
                $(this).data('context', scope.model)
        )
