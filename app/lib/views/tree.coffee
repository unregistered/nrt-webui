###
Displays a node in the module prototype tree. Renders itself
and any sub-trees it must render. This implementation
relies on Ember.typeOf for determining if it's a leaf node.
###
App.TreeNodeView = Ember.View.extend(
    className: "folder"
    tagName: "li"
    classNameBindings: ["isDirectory", "isPrototype"]
    template: Ember.Handlebars.compile """
    {{view.label}}
    <ul>
        {{#each view.branches}}
            {{view App.TreeNodeView treeBinding="view.subtree" branchBinding="this"}}
        {{/each}}
    </ul>
    """

    didInsertElement: ->
        if @get('isPrototype')
            prototype = @get('subtree')

            @.$().draggable(
                opacity: 0.7
                cursor: "crosshair"
                cursorAt: { top: 5, left: 0 }
                helper: (event) ->
                  return $("<span class='ui-widget-helper'>New '#{prototype.name}'</span>")
                revert: "invalid"
                start: (event, ui) ->
                    $(this).data('context', prototype)
            )

    isDirectory: (->
        subtree = @get('subtree')
        Ember.typeOf(subtree) == 'object'
    ).property("subtree")

    isPrototype: (->
        subtree = @get('subtree')
        Ember.typeOf(subtree) == 'instance'
    ).property('subtree')

    label: (->
        branch = @get('branch')

        if @get('isDirectory')
            return "root" if branch == ''
            return branch
        else
            obj = @get('subtree')
            return "Loading..." unless obj # During initial load, we have root pointing to null
            return obj.get('readableName')

    ).property("branch", "isDirectory")

    subtree: (->
        @get('tree')[@get('branch')]
    ).property("tree", "branch")

    branches: (->
        return [] unless @get('isDirectory')
        Object.keys(@get('subtree'))
    ).property("subtree", "isDirectory")
)

App.TreeView = Ember.View.extend(
    tagName: "div"
    classNames: ["tree-view"]
    rootNodeBinding: "controller.tree"
    template: Ember.Handlebars.compile """
    <ul>
        {{view App.TreeNodeView treeBinding="view.rootNode" branch=""}}
    </ul>
    """

)
