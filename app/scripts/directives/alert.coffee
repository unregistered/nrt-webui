"use strict"

angular.module("nrtWebuiApp").directive "alert", (AlertRegistryService) ->
    restrict: "E"
    scope:
      model: "="
      dismiss: "&"

    template: """
    <div ng-show="false" class="alert" ng-class="{'alert-error': model.level == 'error', 'alert-success': model.level == 'success'}">
        <button type="button" class="close" ng-click="dismiss(alert)">&times;</button>
        <strong>{{model.title}}</strong>
        <p>{{model.desc}}</p>
    </div>
    """

    link: (scope, iElement, iAttrs, controller) ->
        if scope.model.is_pinned
            extra_opts = {
                timeOut: 1000000
                positionClass: 'toast-bottom-full-width'
            }
        else
            extra_opts = {}

        # Map alert type to toastr function
        fns = {}
        fns[AlertRegistryService.ALERTLEVEL_INFO] = toastr.info
        fns[AlertRegistryService.ALERTLEVEL_WARN] = toastr.warn
        fns[AlertRegistryService.ALERTLEVEL_SUCCESS] = toastr.success
        fns[AlertRegistryService.ALERTLEVEL_ERROR] = toastr.error

        # Call appropriate toastr function with options
        fns[scope.model.level](scope.model.desc, scope.model.title, _.extend {
            debug: false
            positionClass: 'toast-bottom-right'
            onFadeOut: ->
                scope.dismiss(scope.alert)
            fadeIn: 300
            fadeOut: 500
            timeOut: 3000
            extendedTimeOut: 1000
            }, extra_opts)

