"use strict"

angular.module("nrtWebuiApp").controller "LeftPaneCtrl", ($scope, LoaderManagerService) ->

    $scope.MODULES_TAB = 0
    $scope.INSPECT_TAB = 1
    $scope.LOADERS_TAB = 2

    $scope.selected_pane = $scope.INSPECT_TAB
