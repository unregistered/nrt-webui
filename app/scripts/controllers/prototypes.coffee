"use strict"

angular.module("nrtWebuiApp").controller "PrototypesCtrl", ($scope) ->

    $scope.prototypes =
      name: "Parent"
      expanded: true
      children: [
        name: "Child1"
        expanded: false
        children: [
          name: "Grandchild1"
        ,
          name: "Grandchild2"
        ,
          name: "Grandchild3"
        ]
      ,
        name: "Child2"
      ]
