"use strict"

angular.module("nrtWebuiApp").controller "ServerCtrl", ($scope, $routeParams, ServerService, $location) ->
    $scope.$on('$routeChangeSuccess', (next, current) ->
        ServerService.host = $routeParams.host_and_port.split(':')[0]
        ServerService.port = $routeParams.host_and_port.split(':')[1]

        ServerService.name = 'QuickConnect'

        ServerService.connect()

        console.log "Change server", ServerService.name
    )
