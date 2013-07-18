"use strict"

angular.module("nrtWebuiApp").controller "PrototypesCtrl", ($scope, ServerService, LoaderParserService) ->

    $scope.lastSearch = ''
    $scope.lastTree = null

    # Treeify a flat list of modules, inserting them into a hierarchy based on their categories
    $scope._treeify = (modules) ->
        tree = {name: "Modules", expanded: true, children: []}
        for module in modules

            currCategory = tree

            categories = module.logicalPath.split '/'
            for category in categories[1..categories.length-2]

                result = currCategory['children'].filter (x) -> x['name'] == category
                if result.length == 0
                    currCategory['children'].push
                        name: category
                        expanded: true
                        children: []
                    currCategory = currCategory['children'][currCategory['children'].length-1]
                else
                    result = currCategory['children'].filter (x) -> x['name'] == category
                    currCategory = result[0]

            currCategory['children'].push module
            
            #name: categories[categories.length-1]
            #icondata: module.icondata
            #icontype: 'image/' + module.iconext[1..]
            #logicalPath: module.logicalPath # consumed during module creation

        return tree

    $scope.currentLoader = 'ubuntu1204[7f0101]:4470:8bcdc0'
    $scope.search = ''

    # Get the filtered prototype tree
    #   Make sure to memoize the result based on the search so that we don't keep returning brand new objects (angular hates that)
    $scope.getFilterPrototypes = ->
        if $scope.search == $scope.lastSearch && $scope.lastTree
            return $scope.lastTree

        filteredPrototypes = _.filter LoaderParserService.loaders[$scope.currentLoader]['prototypes'], (it) ->
            return ~it.name.toLowerCase().indexOf($scope.search.toLowerCase())

        $scope.lastTree = $scope._treeify filteredPrototypes

        $scope.lastSearch = $scope.search

        return $scope.lastTree

    $scope.LoaderParserService = LoaderParserService
    $scope.$watch "LoaderParserService", ->
        d = new Date()


        start = window.performance.now()
        $scope.prototypes = $scope._treeify LoaderParserService.loaders[$scope.currentLoader]['prototypes']
        end = window.performance.now()
        console.log "TREEIFY TOOK: " + (end - start) + "ms"
