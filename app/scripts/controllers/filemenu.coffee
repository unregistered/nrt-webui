"use strict"

angular.module("nrtWebuiApp").controller "FileMenuCtrl", ($scope) ->
    $scope.exportPython = ->
        console.log 'Exporting Python!'

        script = """
        #!/usr/bin/env python

        import nrtlib
        """

        blob = new Blob [script], {type: "text/plain;charset=utf-8"}
        saveAs(blob, "network.py")
