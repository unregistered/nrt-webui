"use strict"

angular.module("nrtWebuiApp").controller "PrototypesCtrl", ($scope, ServerService) ->

    treeify = (modules) ->
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

            currCategory['children'].push
              name: categories[categories.length-1]
              icondata: module.icondata
              icontype: 'image/' + module.iconext[1..]

        return tree

    tree = treeify(ServerService.prototypes.message.modules)

    console.log ServerService.prototypes.message
    console.log tree

    $scope.prototypes = tree
  
