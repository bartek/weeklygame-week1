import graphics from love

-- mixins in lua.
export mixin_object = (object, methods) =>
  for name in *methods
      self[name] = (parent, ...) ->
            object[name](object, ...)
