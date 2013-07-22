"use strict"

angular.module("nrtWebuiApp").controller "LeftPaneCtrl", ($scope, LoaderManagerService, SelectionService) ->

    $scope.MODULES_TAB = 0
    $scope.INSPECT_TAB = 1
    $scope.LOADERS_TAB = 2

    $scope.selected_pane = $scope.MODULES_TAB

    # Automatically change tab with appropriate selection
    $scope.$on("SelectionService.selection_changed", ->
        types = SelectionService.getTypes()

        if types.length == 0
            # No selection
            $scope.selected_pane = $scope.MODULES_TAB
        else
            $scope.selected_pane = $scope.INSPECT_TAB
    )
