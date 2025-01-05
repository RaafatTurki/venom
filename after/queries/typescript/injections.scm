;; extends

; (template_string
;   (string_fragment) @injection.content
;   (#set! injection.language "typescript")
; )

; (script_element
;   (raw_text) @injection.content
;   (#set! injection.language "javascript")) ; set the parser language for @injection.content region to javascript

; (
;    (call_expression
;       (property) @asd (#eq? @asd "validateIf"))
;      ; (function) @member_expression (#eq? @member_expression "validateIf")
;      ; (arrow_function) @lambda (#set! @lambda conceal "…")
;    )
;  )

; (string_fragment)

; ((pair
;    (property_identifier) @property_name (#eq? @property_name "validateIf")
;    (arrow_function) @lambda (#set! @lambda conceal "…")))
