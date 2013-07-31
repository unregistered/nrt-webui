"use strict"

angular.module("nrtWebuiApp").controller "ExportMenuCtrl", ($scope, ModuleManagerService, LoaderManagerService) ->
    $scope.exportPython = ->

        script = """
        #!/usr/bin/env python

        import nrtlib


        """

        script += "def loaders():\n"
        console.log LoaderManagerService.loaders
        for loader in _(LoaderManagerService.loaders).values()
            script += "  nrtlib.addLoader(name='#{loader.bbnick}', host='#{loader.hostname}')\n"

        script += "\n"

        script += "def modules():\n"
        for module in _(ModuleManagerService.modules).values()

            # Track down the prototype for this module
            loader = LoaderManagerService.loaders[module.bbuid]
            prototype = _(loader.prototypes).findWhere({name: module.classname})
            continue unless prototype

            # Metadata
            script += "  # Load #{module.classname} (#{module.instance})\n"
            script += "  nrtlib.addModule(\n"
            script += "    path         = '#{prototype.logicalPath},\n"
            script += "    instancename = '#{module.instance},\n"
            script += "    bbnick       = '#{loader.bbnick},\n"
            script += "    position     = (#{module.x}, #{module.y}),\n"

            # Parameters
            script += "    parameters   = {\n"
            for parameter in module.parameters
                value = parameter.value
                comment = ""
                unless value
                    console.error 'Found undefined module parameter: ', parameter.name
                    value = parameter.defaultvalue
                    comment = "# WARNING: This parameter value may not be correct!"
                script += "      '#{parameter.name}' : '#{value}', #{comment}\n"
            script += "    },\n"

            # Subscribers
            script += "    subscribertopicfilters = {\n"
            for port in module.subscribers
                script += "      '#{port.portname}' : '#{port.topi}',\n"
            script += "    },\n"

            # Checkers
            script += "    checkertopicfilters = {\n"
            for port in module.checkers
                script += "      '#{port.portname}' : '#{port.topi}',\n"
            script += "    },\n"

            # Posters
            script += "    postertopics = {\n"
            for port in module.posters
                script += "      '#{port.portname}' : '#{port.topi}',\n"
            script += "    }\n"

            script += "  )\n\n"

        blob = new Blob [script], {type: "text/plain;charset=utf-8"}
        saveAs(blob, "network.py")
