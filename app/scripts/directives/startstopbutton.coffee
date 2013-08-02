angular.module("nrtWebuiApp").directive 'startstopbutton', ->
    scope: {
        model: "=model"
    } # Isolate scope
    restrict: "E"
    template: """
    <a style="width:100px" ng-click="toggleState()" class="btn btn-small" ng-class="getStatusClass(status)">{{getStatusText(status)}}</a>
    """

    replace: true
    transclude: true

    controller: ($scope, ServerService, AlertRegistryService) ->
        $scope.RUNNING  = 'running'
        $scope.STOPPED  = 'stopped'
        $scope.STARTING = 'starting'
        $scope.STOPPING = 'stopping'
        $scope.status = $scope.STOPPED

        $scope.ServerService = ServerService
        $scope.$on('ServerService.federation_update', (event, federation) ->
            if federation.running
                $scope.status = $scope.RUNNING
            else
                $scope.status = $scope.STOPPED
        )

        $scope.toggleState = ->
            if $scope.status == $scope.STOPPED
                $scope.status = $scope.STARTING
                ServerService.startStop('start').then( (res) ->
                    $scope.status = $scope.STARTED
                , (error) ->
                    console.error 'Failed to start', error
                    AlertRegistryService.registerError "Failed to start", error.desc, false, (->)
                )

            else if $scope.status == $scope.RUNNING
                $scope.status = $scope.STOPPING
                ServerService.startStop('stop').then((res) ->
                    $scope.status = $scope.STOPPED
                , (error) ->
                    console.error 'Failed to stop', error
                    AlertRegistryService.registerError "Failed to stop", error.desc, false, (->)
                )

    link: (scope, iElement, iAttr, controller) ->

        scope.getStatusClass = (status) ->
            switch status
                when scope.RUNNING  then 'btn-danger'
                when scope.STOPPED  then 'btn-success'
                when scope.STARTING then 'btn-success disabled'
                when scope.STOPPING then 'btn-danger disabled'

        scope.getStatusText = (status) ->
            switch status
                when scope.RUNNING  then 'Stop'
                when scope.STOPPED  then 'Start'
                when scope.STARTING then 'Start'
                when scope.STOPPING then 'Stop'

