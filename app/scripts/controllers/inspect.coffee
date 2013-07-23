"use strict"

angular.module("nrtWebuiApp").controller "InspectCtrl", ($scope, ServerService, SelectionService) ->
    $scope.module = null

    # Watch to see when the selected objects have changed and set the
    # appropriate variables in the scope
    $scope.SelectionService = SelectionService
    $scope.$on("SelectionService.selection_changed", ->
        modules = SelectionService.get('module')
        if modules.length
            $scope.module = modules[0]
        else
            $scope.module = null
    , true)

