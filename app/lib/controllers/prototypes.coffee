require "nrt-webui/core"

App.PrototypesController = Ember.ArrayController.extend(
    content: []
    filter: ""

    tree: (->
        tree = {}
        constraint = @get('filter')

        @get('content').filter (item) =>
            ~item.get('name').toLowerCase().indexOf(constraint)
        .forEach (item) =>
            path = item.get('logicalPath')
            path = path.split('/')

            @treeify(path, tree, item)

        return tree
    ).property('content', 'content.@each', 'filter')

    # Recursively make truee
    # path: array of path components
    # tree: subtree to insert into
    # leaf: object to insert
    treeify: (path, tree, leaf) ->
        head = path.shift()

        if path.length == 0
            # We are the last node
            tree[head] = leaf
            return

        if typeof tree[head] == "undefined"
            tree[head] = {}

        @treeify(path, tree[head], leaf)
)
