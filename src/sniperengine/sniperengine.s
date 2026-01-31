;.section .text

    ;; SNIPERENGINE API; USEFUL FOR ROM HACKING

    ;; mmc3 functions
    ;e000
    ;jmp __set_prg_a000

.section .text.sniperengine
    #include "./lib/mmc3.s"
    #include "./lib/donut.s" ; contains se_donut_decompress_vram

; alright, so here's the problem i'm having:
; i'm linking this file, sniperengine.s, at compile time,
; and calling a function from donut.s in C.
;
; i get the following:
;   ld.lld: error: undefined symbol: se_donut_decompress_vram
;
; do symbols from the included files not get... included???????