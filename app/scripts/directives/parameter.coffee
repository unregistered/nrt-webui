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
    link: (scope, iElement, iAttr) ->
        parameter = scope.model

        # Parse the valid value specification (it looks like None:[], or List:[item1, item2])
        valid_values = parameter.validvalues.split /[:\[\]\|]+/

        id = 'parameter_input_' + parameter.$$hashKey

        boilerplate = """ id=#{id} value="#{parameter.value}" name="#{parameter.descriptor}" """

        setParameter = ->
            new_value = $("##{id}")[0].value
            return if new_value == parameter.value
            scope.$parent.$parent.setParameter parameter, new_value

        # Create the input area for the various types of parameters
        if valid_values[0] == 'None'

            if _(["short", "unsigned short", "int", "unsigned int", "long int", "unsigned long int", "unsigned long"]).contains(parameter.valuetype)
                scope.inputArea = """<input type="number" #{boilerplate}>"""
                $(iElement).on('blur', 'input', setParameter)

            else if _(["float", "double", "long double"]).contains(parameter.valuetype)
                scope.inputArea = """<input type="number" #{boilerplate}>"""
                $(iElement).on('blur', 'input', setParameter)

            else if "bool" == parameter.valuetype
                scope.inputArea = """<input type="number" #{boilerplate}>"""
                $(iElement).on('blur', 'input', setParameter)

            else
                scope.inputArea = """<input type="text" #{boilerplate}>"""
                $(iElement).on('blur', 'input', setParameter)

            # Send the parameter and unfocus on <enter> key
            $(iElement).on 'keydown', 'input', (e) ->
                if e.keyCode == 13
                    setParameter()
                    $(e.currentTarget).blur()

        else if valid_values[0] == 'List'
            scope.inputArea = """<select #{boilerplate}>"""
            for value in valid_values[1 .. valid_values.length-2]
                scope.inputArea += """  <option value="#{value}" #{'selected' if value == parameter.value}>#{value}</option>"""
            scope.inputArea += """</select>"""
            $(iElement).on('change', 'select', setParameter)

        else
            console.error "Unknown parameter valid_values specification", parameter
            scope.inputArea = """<input type="text" #{boilerplate}>"""
