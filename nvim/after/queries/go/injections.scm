;; extends

; #match? patterns are very magic (\v): groups are (a|b), word end is >

; SQL in Go strings, recognized by content rather than by the call that receives them: queries
; are usually assigned to a variable first (query := `SELECT ...`) and passed to db.GetContext
; later, so a call-based match (like Prisma's in ecma/injections.scm) would miss them.

; Raw strings starting with a statement keyword, any case
((raw_string_literal
  (raw_string_literal_content) @injection.content)
  (#match? @injection.content "^[[:space:]]*\\c(select|insert|update|delete|with|create|alter|drop|truncate|merge|upsert)>")
  (#set! injection.language "sql"))

; Interpreted strings only with an uppercase keyword, so messages like "update failed" stay text
((interpreted_string_literal
  (interpreted_string_literal_content) @injection.content)
  (#match? @injection.content "^\\s*(SELECT|INSERT|UPDATE|DELETE|WITH|CREATE|ALTER|DROP|TRUNCATE) ")
  (#set! injection.language "sql"))
