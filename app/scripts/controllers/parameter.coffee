"use strict"

angular.module("nrtWebuiApp").controller "ParameterCtrl", ($scope, ServerService) ->

    $scope.setParameter = (p)->
        console.log "SETTING PARAMETER", p
        ServerService.setParameter p.module, p, p.value
