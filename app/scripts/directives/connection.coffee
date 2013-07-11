angular.module("nrtWebuiApp").directive 'connection', ->
    controller: 'raphael'
    restrict: "E"
    template: """
    <div></div>
    <div ng-transclude></div>
    """
    replace: true
    transclude: true

    link: (scope, iElement, iAttrs, controller) ->
        console.log "Connection directive"
