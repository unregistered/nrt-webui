"use strict"

angular.module("nrtWebuiApp").controller "WorkspaceCtrl", ($scope) ->
    $scope.zoom = 1

    $scope.zoomIn = ->
        $scope.$broadcast("RequestZoomIn") # Serviced by raphael directive

    $scope.zoomOut = ->
        $scope.$broadcast("RequestZoomOut") # Serviced by raphael directive

    $scope.panToHome = ->
        $scope.$broadcast("RequestPanHome") # Serviced by raphael directive

    # Allows us to explicitly call WorkspaceCtrl.method() in the view
    $scope.WorkspaceCtrl = $scope
