"use strict"

angular.module("nrtWebuiApp").controller "LoadersCtrl", ($scope, LoaderParserService) ->

    $scope.loaders = []
    $scope.selected_bbnick = ""

    $scope.$on("LoaderParserService.loaders_changed", (event, loaders) ->
        $scope.loaders = []
        console.log 'Got loaders: ', loaders
        for bbuid in _.keys loaders
            $scope.loaders.push
              bbuid: bbuid
              bbnick: loaders[bbuid]['bbnick']

         if $scope.selected_bbnick == ""
             $scope.selected_bbnick = $scope.loaders[0].bbnick
    )
