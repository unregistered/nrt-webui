"use strict"

angular.module("nrtWebuiApp").controller "LoadersCtrl", ($scope, LoaderParserService) ->

    $scope.$watch "PrototypeParserService", ->
        $scope.loaders = []
        for bbuid in _.keys LoaderParserService.loaders
            $scope.loaders.push
              bbuid: bbuid
              bbnick: LoaderParserService.loaders[bbuid]['bbnick']
