"use strict"

angular.module("nrtWebuiApp").controller "InspectCtrl", ($scope, ServerService, SelectionService) ->
    $scope.module = null
    $scope.modules = null
    $scope.connection = null
    $scope.connections = null
    $scope.port = null
    $scope.ports = null

    # Watch to see when the selected objects have changed and set the
    # appropriate variables in the scope
    $scope.SelectionService = SelectionService
    $scope.$on("SelectionService.selection_changed", ->
        $scope.module = null
        $scope.modules = null
        $scope.connection = null
        $scope.connections = null
        $scope.port = null
        $scope.ports = null

        types = SelectionService.getTypes()

        if _(types).contains 'module'
            modules = SelectionService.get('module')
            if modules.length > 1
                $scope.modules = modules
            else
                $scope.module = modules[0]
        else if _(types).contains 'connection'
            connections = SelectionService.get('connection')
            if connections.length > 1
                $scope.connections = connections
            else
                $scope.connection = connections[0]
        else if _(types).contains 'port'
            ports = SelectionService.get('port')
            if ports.length > 1
                $scope.ports = ports
            else
                $scope.port = ports[0]
    , true)

