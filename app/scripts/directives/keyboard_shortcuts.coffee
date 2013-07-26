###
Triggers element on keypress

Behavior is element dependent:
- Focuses text inputs
- Clicks anchor elements
###
angular.module("nrtWebuiApp").directive 'keyboardShortcut', (KeyboardShortcutService) ->
        restrict: "A"
        replace: false

        link: (scope, iElement, iAttrs, controller) ->
            shortcut = iAttrs.keyboardShortcut

            if shortcut[0] == '[' and shortcut.slice(-1) == ']'
                shortcut = JSON.parse(shortcut)

            KeyboardShortcutService.bind shortcut, (e) ->
                if iElement.is('input')
                    iElement.focus()

                if iElement.is('a')
                    iElement.click()

                e.preventDefault()
