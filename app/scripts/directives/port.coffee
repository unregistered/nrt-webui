angular.module("nrtWebuiApp").directive 'port', ->
    require: ['^raphael', '^module']
    restrict: "E"
    template: """
    <div>Port</div>
    """
    replace: true

    link: (scope, iElement, iAttrs, controller) ->
        console.log "Port directive", controller[1].getContainer()

