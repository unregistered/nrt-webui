"use strict"

angular.module("nrtWebuiApp").controller "LoadersCtrl", ($scope, LoaderParserService) ->

    $scope.selected_bbnick = ""


    $scope.$watch "PrototypeParserService", ->
        $scope.loaders = []
        for bbuid in _.keys LoaderParserService.loaders
            $scope.loaders.push
              bbuid: bbuid
              bbnick: LoaderParserService.loaders[bbuid]['bbnick']

         if $scope.selected_bbnick == ""
             $scope.selected_bbnick = $scope.loaders[0].bbnick
