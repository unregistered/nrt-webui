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

            $scope.module.parameters = [
                {
                    descriptor: 'my:parameter:cool-parameter'
                    name: 'cool-parameter'
                    description: 'This is one cool parameter!'
                    valuetype: 'string'
                    validvalues: ''
                    category: 'coolcategory'
                },
                {
                    descriptor: 'my:parameter:other-param'
                    name: 'other-parameter'
                    description: 'This is another really awesome parameter'
                    valuetype: 'float'
                    validvalues: ''
                    category: 'coolcategory'
                },
            ]

            console.log "Selected Module: ", $scope.module
        else
            $scope.module = null
    , true)

