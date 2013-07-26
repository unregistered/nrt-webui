###
Triggers element on keypress

Focuses text inputs
Clicks buttons and submits
###
angular.module("nrtWebuiApp").directive 'keyboardShortcut', (KeyboardShortcutService) ->
        restrict: "A"
        replace: false

        link: (scope, iElement, iAttrs, controller) ->
            shortcut = iAttrs.keyboardShortcut

            if shortcut[0] == '[' and shortcut.slice(-1) == ']'
                console.log "We are given an array"
                shortcut = JSON.parse(shortcut)

            KeyboardShortcutService.bind shortcut, (e) ->
                console.log "Trigg"
                if iElement.is('input')
                    iElement.focus()

                e.preventDefault()
