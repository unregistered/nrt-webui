"use strict"

angular.module("nrtWebuiApp").controller "InspectCtrl", ($scope, ServerService, SelectionService) ->
    $scope.selectedTypes = ->
        _.map SelectionService.content, (value, key) ->
            _.map value, (obj) -> obj.$$hashKey

    $scope.module = null

    $scope.SelectionService = SelectionService
    $scope.$watch("selectedTypes()", ->
        selected = SelectionService.content
        if selected.module
            $scope.module = selected.module[0]

            console.log 'Parameters ', $scope.module.parameters

            console.log "Selected Module: ", $scope.module
        else
            $scope.module = null
    , true)

