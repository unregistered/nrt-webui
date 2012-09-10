get = Ember.get

fmt = Ember.String.fmt

Ember.View.reopen templateForName: (name, type) ->
  return unless name
  templates = get(this, "templates")
  template = get(templates, name)
  unless template
    try
      template = require(name)
    catch e
      throw new Ember.Error(fmt("%@ - Unable to find %@ \"%@\".", [this, type, name]))
  template

Ember.RaphaelView = Ember.View.extend(
    paperBinding: "parentView.paper"
)