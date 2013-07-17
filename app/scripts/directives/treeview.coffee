"use strict"

angular.module("nrtWebuiApp").directive "tree", ($compile) ->
    restrict: "E"
    scope:
      model: "="

    template: """
        <span class="pointable">
        <p ng-click="model.expanded=!model.expanded">
            <span ng-show="model.children && !model.expanded"> <i class="icon-caret-right"></i> </span>
            <span ng-show="model.children &&  model.expanded"> <i class="icon-caret-down"></i> </span>
            <img width="20px" ng-show="!model.children" src="data:{{model.icontype}};base64,{{model.icondata}}">
            {{ model.name }}
        </p>
        <div style="padding-left:15px" ng-show="model.expanded" ng-repeat="child in model.children">
            <tree model="child"></tree>
        </div>
        </span>
        """

    compile: (tElement, tAttr) ->
      contents = tElement.contents().remove()
      compiledContents = undefined
      (scope, iElement, iAttr) ->
        compiledContents = $compile(contents)  unless compiledContents
        compiledContents scope, (clone, scope) ->
          iElement.append clone
