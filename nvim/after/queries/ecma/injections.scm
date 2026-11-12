;; extends

; SQL in Prisma's raw queries. javascript, typescript and tsx inherit ecma, so this covers all
; three; the generic form ($queryRaw<T>`...`) is in typescript/injections.scm. Upstream already
; injects sql`...` and Prisma.sql`...` (the tag names the language).
;
; include-children: without it the string's own text node is dropped and only the quotes reach
; the SQL parser.

; prisma.$queryRaw`...`, tx.$executeRaw`...`
(call_expression
  function: (member_expression
    property: (property_identifier) @_fn)
  arguments: (template_string) @injection.content
  (#any-of? @_fn "$queryRaw" "$executeRaw")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "sql"))

; prisma.$queryRawUnsafe('...', ...), with a string or template literal
(call_expression
  function: (member_expression
    property: (property_identifier) @_fn)
  arguments: (arguments
    .
    [(string) (template_string)] @injection.content)
  (#any-of? @_fn "$queryRawUnsafe" "$executeRawUnsafe")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "sql"))
