angular.module("nrtWebuiApp").directive 'tray', ->
    scope: {
        name: "@name"
    } # Isolate scope
    restrict: "E"
    template: """
    <table class="table table-bordered tray">
        <thead>
            <tr>
                <td class="h1">
                    {{name}}
                </td>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>
                    <div class="variable-height" ng-transclude>

                    </div>
                </td>
            </tr>
        </tbody>
    </table>
    """
    replace: true
    transclude: true
    link: (scope, iElement, iAttrs) ->

