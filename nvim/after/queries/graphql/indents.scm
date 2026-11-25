;; extends

; An empty block isn't valid GraphQL, so while it's being typed (`type X {` plus the `}` autopairs
; adds) its braces parse as an ERROR outside the definition, and the first line inside stayed at
; column 0: indent inside them anyway
(ERROR "{") @indent.begin
