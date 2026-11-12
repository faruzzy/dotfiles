;; extends

; tsx inherits this file. Kept out of ecma/: javascript has no such node types, and one unknown
; node type makes the whole query fail to parse

; With type arguments, tree-sitter-typescript parses `prisma.$queryRaw<T>`...`` as a
; non_null_expression wrapping (prisma.$queryRaw)<T>, or (await prisma.$queryRaw)<T>
(call_expression
  function: (non_null_expression
    (instantiation_expression
      [
        (member_expression
          property: (property_identifier) @_fn)
        (await_expression
          (member_expression
            property: (property_identifier) @_fn))
      ]))
  arguments: (template_string) @injection.content
  (#any-of? @_fn "$queryRaw" "$executeRaw")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "sql"))
