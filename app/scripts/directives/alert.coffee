"use strict"

angular.module("nrtWebuiApp").directive "alert", ->
    restrict: "E"
    scope:
      model: "="
      dismiss: "&"

    template: """
    <div class="alert" ng-class="{'alert-error': model.level == 'error', 'alert-success': model.level == 'success'}">
        <button type="button" class="close" ng-click="dismiss(alert)">&times;</button>
        <strong>{{model.title}}</strong>
        <p>{{model.desc}}</p>
    </div>
    """

    link: (scope, iElement, iAttrs, controller) ->
        console.log "Link alert", scope.model
