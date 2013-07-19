angular.module("nrtWebuiApp").directive 'parameter', ->
    scope: {
        model: "=model"
    } # Isolate scope
    restrict: "E"

    # Note, angular cannot handle tables in directives, so we hack around it for now
    template: """
        <div style="display:table-row">

            <div style="display:table-cell">{{model.name}}</div>

            <div style="display:table-cell">
                <span ng-switch="model.valuetype">
                    <span ng-switch-when="bool">
                        <input type="checkbox" id="{{model.name}}" ng-checked="model.value == 'true'">
                    </span>

                    <span ng-switch-default>
                        <input type="text" id="{{model.name}}" value="{{model.value}}">
                    </span>
                </span>
            </div>

            <div style="display:table-cell">
                <i class="icon-comment" data-toggle="tooltip" title="{{model.description}}"></i>
            </div>

        </div>
    """
    replace: true
    transclude: true
    link: (scope, iElement, iAttrs) ->

