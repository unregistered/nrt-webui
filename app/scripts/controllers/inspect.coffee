"use strict"

angular.module("nrtWebuiApp").controller "InspectCtrl", ($scope, ServerService, SelectionService) ->
    $scope.selectedTypes = ->
        _.map SelectionService.content, (value, key) ->
            _.map value, (obj) -> obj.$$hashKey

    $scope.module = null

    # Try to set a parameter to the given value
    $scope.setParameter = (parameter, new_value) ->
        ServerService.setParameter $scope.module, parameter, new_value

    # Watch to see when the selected objects have changed and set the
    # appropriate variables in the scope
    $scope.SelectionService = SelectionService
    $scope.$watch("selectedTypes()", ->
        selected = SelectionService.content
        if selected.module
            $scope.module = selected.module[0]
        else
            $scope.module = null
    , true)

