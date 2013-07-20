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

            <span ng-bind-html-unsafe="inputArea"></span>

            </div>

            <div style="display:table-cell">
                <i class="icon-comment" data-toggle="tooltip" title="{{model.description}}"></i>
            </div>

        </div>
    """
    replace: true
    transclude: true
    compile: (element, attr, transclude) -> (scope, iElement, iAttr) ->
        console.log 'Compiling parameter', scope.model

        parameter = scope.model
        valid_values = parameter.validvalues.split /[:\[\]\|]+/

        boilerplate = """ value="#{parameter.value}" name="#{parameter.descriptor}" """

        # Create the input area for the various types of parameters
        if valid_values[0] == 'None'

            if _(["short", "unsigned short", "int", "unsigned int", "long int", "unsigned long int", "unsigned long"]).contains(parameter.valuetype)
                scope.inputArea = """<input type="number" #{boilerplate}>"""

            else if _(["float", "double", "long double"]).contains(parameter.valuetype)
                scope.inputArea = """<input type="number" #{boilerplate}>"""

            else if "bool" == parameter.valuetype
                scope.inputArea = """<input type="number" #{boilerplate}>"""

            else
                scope.inputArea = """<input type="text" #{boilerplate}>"""

        else if valid_values[0] == 'List'
            scope.inputArea = """<select #{boilerplate}>"""
            for value in valid_values[1 .. valid_values.length-2]
                scope.inputArea += """  <option value="#{value}" #{'selected' if value == parameter.value}>#{value}</option>"""
            scope.inputArea += """</select>"""

        else
            console.error "Unknown parameter valid_values specification", parameter
            scope.inputArea = """<input type="text" #{boilerplate}>"""


