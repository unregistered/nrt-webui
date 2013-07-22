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

            <form ng-submit="setParameter(parameter)" class="form-inline" ng-controller="ParameterCtrl">
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
    link: (scope, iElement, iAttr) ->
        console.log 'Linking', scope
        scope.localparameter = _.clone scope.parameter

        valid_values = scope.parameter.validvalues.split /[:\[\]\|]+/

        # Determine the type of parameter
        if valid_values[0] == 'None'
            if _(["short", "unsigned short", "int", "unsigned int", "long int", "unsigned long int", "unsigned long"]).contains(scope.parameter.valuetype)
                scope.type = "int"
            else if _(["float", "double", "long double"]).contains(scope.parameter.valuetype)
                scope.type = "float"
            else if "bool" == scope.parameter.valuetype
                scope.type = "list"
                scope.list = ['true', 'false']
            else
                scope.type = "text"
        else if valid_values[0] == 'List'
            scope.type = "list"
            scope.list = valid_values[1 .. valid_values.length-2]

        scope.isDirty = ->
            scope.localparameter.value != scope.parameter.value

