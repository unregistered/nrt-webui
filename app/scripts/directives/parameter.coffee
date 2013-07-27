angular.module("nrtWebuiApp").directive 'parameter', ->
    scope: {
        parameter: "=model"
    } # Isolate scope
    restrict: "E"

    # Note, angular cannot handle tables in directives, so we hack around it for now
    template: """
        <div class="parameter-form">

            <div class="parameter-name">
                <abbr title="{{parameter.description}}">
                    {{parameter.name}}
                </abbr>
            </div>

            <form ng-submit="setParameter(localparameter)" class="form-inline" >
                <div class="parameter-value">
                    <span ng-switch="type">

                        <input id="{{id}}" ng-switch-when="int" type="number" ng-model="localparameter.value">

                        <input id="{{id}}" ng-switch-when="float" type="number" ng-model="localparameter.value">

                        <input id="{{id}}" ng-switch-when="text" type="text"  ng-model="localparameter.value">

                        <select id="{{id}}" ng-switch-when="list" ng-model="localparameter.value">
                            <option ng-repeat="item in list" ng-selected="parameter.value == item">{{item}}</option>
                        </select>

                    </span>
                </div>

                <div class="parameter-submit">
                    <button ng-show="isDirty()" type="submit" class="btn btn-small btn-success">Save</button>
                </div>
            </form>

        </div>
    """
    replace: true
    transclude: true

    controller: ($scope, ServerService, AlertRegistryService) ->
        $scope.getParameter = (p) ->
            ServerService.getParameter(p.module, p).then( (res) ->
                p.value = res
            , (err) ->
                console.error 'Failed to get parameter', p, err
                AlertRegistryService.registerError "Failed to get parameter \"#{p.name}\"", err.desc, false, (->)
                $("##{$scope.id}").stop().css("background-color", "#FFBBBB").animate({ backgroundColor: "FFFFFF"}, 1000)
            )

        $scope.setParameter = (p)->
            ServerService.setParameter(p.module, p, p.value).then(((res) ->
                $("##{$scope.id}").stop().css("background-color", "#BBFFBB").animate({ backgroundColor: "FFFFFF"}, 1000)
            )
            , (err) ->
                error = err.desc.replace 'Wrapped NRT Exception:', ''
                AlertRegistryService.registerError "Failed to set parameter \"#{p.name}\"", error, false, (->)
                p.value = $scope.parameter.value
                $("##{$scope.id}").stop().css("background-color", "#FFBBBB").animate({ backgroundColor: "FFFFFF"}, 1000)
            )

    link: (scope, iElement, iAttr, controller) ->

        scope.id = 'parameter_' + scope.parameter.$$hashKey

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

