"use strict"

angular.module("nrtWebuiApp").controller "WorkspaceCtrl", ($scope, ConfigService) ->
    $scope.zoom = 1

    $scope.zoomIn = ->
        $scope.$broadcast("RequestZoomIn") # Serviced by raphael directive

    $scope.zoomOut = ->
        $scope.$broadcast("RequestZoomOut") # Serviced by raphael directive

    $scope.panToHome = ->
        $scope.$broadcast("RequestPanHome") # Serviced by raphael directive

    $scope.setMousemodeDrag = ->
        ConfigService.settings.canvas_mousemode = ConfigService.SETTING_CANVAS_MOUSEMODE_DRAG

    $scope.setMousemodeSelect = ->
        ConfigService.settings.canvas_mousemode = ConfigService.SETTING_CANVAS_MOUSEMODE_SELECT

    $scope.isDragMode = ->
        ConfigService.settings.canvas_mousemode == ConfigService.SETTING_CANVAS_MOUSEMODE_DRAG

    $scope.isSelectMode = ->
        ConfigService.settings.canvas_mousemode == ConfigService.SETTING_CANVAS_MOUSEMODE_SELECT

    # Allows us to explicitly call WorkspaceCtrl.method() in the view
    $scope.WorkspaceCtrl = $scope
