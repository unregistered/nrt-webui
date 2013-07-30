angular.module("nrtWebuiApp").directive 'tray', ->
    scope: {
        name: "@name"
    } # Isolate scope
    restrict: "E"
    template: """
    <div class="panel">
        <div class="panel-heading">
          <h3 class="panel-title">{{name}}</h3>
        </div>
        <div ng-transclude></div>
    </div>
    """
    replace: true
    transclude: true
    link: (scope, iElement, iAttrs) ->

