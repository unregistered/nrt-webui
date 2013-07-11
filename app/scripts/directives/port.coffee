angular.module("nrtWebuiApp").directive 'port', ->
    controller: 'raphael'
    restrict: "E"
    template: """
    <div></div>
    """
    replace: true
    transclude: true

    link: (scope, iElement, iAttrs, controller) ->
        console.log "Port directive"
