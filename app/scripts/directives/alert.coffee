"use strict"

angular.module("nrtWebuiApp").directive "alert", (AlertRegistryService) ->
    restrict: "E"
    scope:
      model: "="
      dismiss: "&"

    template: """
    <div ng-show="model.is_pinned" class="alert" ng-class="{'alert-error': model.level == 'error', 'alert-success': model.level == 'success'}">
        <button type="button" class="close" ng-click="dismiss(alert)">&times;</button>
        <strong>{{model.title}}</strong>
        <p>{{model.desc}}</p>
    </div>
    """

    link: (scope, iElement, iAttrs, controller) ->
        if scope.model.is_pinned
            # We will use the template
        else
            # We will display a transient alert

            # Map alert type to toastr function
            fns = {}
            fns[AlertRegistryService.ALERTLEVEL_INFO] = toastr.info
            fns[AlertRegistryService.ALERTLEVEL_WARN] = toastr.warn
            fns[AlertRegistryService.ALERTLEVEL_SUCCESS] = toastr.success
            fns[AlertRegistryService.ALERTLEVEL_ERROR] = toastr.error

            # Call appropriate toastr function with options
            fns[scope.model.level](scope.model.desc, scope.model.title, {
                debug: false
                positionClass: 'toast-top-right'
                onFadeOut: ->
                    scope.dismiss(scope.alert)
                fadeIn: 300
                fadeOut: 500
                timeOut: 5000
                extendedTimeOut: 1000
                })

