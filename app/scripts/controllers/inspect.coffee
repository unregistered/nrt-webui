"use strict"

angular.module("nrtWebuiApp").controller "InspectCtrl", ($scope, ServerService, SelectionService) ->
    $scope.module = null
    $scope.connection = null

    # Watch to see when the selected objects have changed and set the
    # appropriate variables in the scope
    $scope.SelectionService = SelectionService
    $scope.$on("SelectionService.selection_changed", ->
        $scope.module = null
        $scope.connection = null

        types = SelectionService.getTypes()

        if _(types).contains 'module'
            $scope.module = SelectionService.get('module')[0]
        else if _(types).contains 'connection'
            $scope.connection = SelectionService.get('connection')[0]
    , true)

