"use strict"

angular.module("nrtWebuiApp").controller "PrototypesCtrl", ($scope, ServerService, LoaderParserService) ->

    $scope.currentLoader = 'ubuntu1204[7f0101]:4470:8bcdc0'

    $scope.LoaderParserService = LoaderParserService
    $scope.$watch "LoaderParserService", ->
        $scope.prototypes = LoaderParserService.loaders[$scope.currentLoader]['prototypes']
