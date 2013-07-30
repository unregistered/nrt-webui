###
This file contains text links for modules, ports, connections, etc.
When clicked, they will update the SelectionService to select the appropriate entity.
###

"use strict"

angular.module("nrtWebuiApp").directive "modal", () ->
    restrict: "E"

    scope: {
        title: "@"
    }

    transclude: true

    template: """
        <a data-toggle="modal" href="#myModal">
        {{title}}

        </a>

        <!-- Modal -->
        <div class="modal" id="myModal">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">{{title}}</h4>
              </div>

              <div class="modal-body">
                <div ng-transclude></div>
              </div>

              <div class="modal-footer">
                <a class="btn btn-danger" data-dismiss="modal">Close</a>
                <a href="#" class="btn btn-primary">Save changes</a>
              </div>
            </div><!-- /.modal-content -->
          </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->
    """

    link: (scope, iElement, iAttrs, controller) ->
        console.log "Link"
