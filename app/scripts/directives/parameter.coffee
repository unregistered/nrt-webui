angular.module("nrtWebuiApp").directive 'parameter', ->
    scope: {
        parameter: "=model"
    } # Isolate scope
    restrict: "E"

    # Note, angular cannot handle tables in directives, so we hack around it for now
    template: """
        <div style="display:table-row">

            <div style="display:table-cell">
                <abbr title="{{parameter.description}}">
                    {{parameter.name}}
                </abbr>
            </div>

            <form ng-submit="setParameter(localparameter)" class="form-inline" >
                <div style="display:table-cell">
                    <span ng-switch="type">

                        <input ng-switch-when="int" type="number" ng-model="localparameter.value">

                        <input ng-switch-when="float" type="number" ng-model="localparameter.value">

                        <input ng-switch-when="text" type="text"  ng-model="localparameter.value">

                        <select ng-switch-when="list" ng-model="localparameter.value">
                            <option ng-repeat="item in list" ng-selected="parameter.value == item">{{item}}</option>
                        </select>

                    </span>
                </div>

                <div style="display:table-cell">
                    <button ng-show="isDirty()" type="submit" class="btn btn-small btn-success">Save</button>
                </div>
            </form>

        </div>
    """
    replace: true
    transclude: true

    controller: ($scope, ServerService, AlertRegistryService) ->
        $scope.getParameter = (p) ->
            ServerService.getParameter p.module, p

        $scope.setParameter = (p)->
            ServerService.setParameter(p.module, p, p.value).then(((res) ->)
            , (err) ->
                error = err.desc.replace 'Wrapped NRT Exception:', ''
                AlertRegistryService.registerError "Failed to set parameter", error, false, ->
                p.value = $scope.parameter.value
            )

    link: (scope, iElement, iAttr, controller) ->

        if typeof scope.parameter.value == 'undefined'
            scope.getParameter(scope.parameter)

        scope.$watch('parameter.value', ->
            scope.localparameter = _.clone scope.parameter

            valid_values = scope.parameter.validvalues.split /[:\[\]\|]+/

            # Determine the type of parameter
            if valid_values[0] == 'None'
                if "bool" == scope.parameter.valuetype
                    scope.type = "list"
                    scope.list = ['true', 'false']
                else
                    scope.type = "text"
            else if valid_values[0] == 'List'
                scope.type = "list"
                scope.list = valid_values[1 .. valid_values.length-2]
        )

        scope.isDirty = ->
            return false unless scope.localparameter
            scope.localparameter.value != scope.parameter.value

