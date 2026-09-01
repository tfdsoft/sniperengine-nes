.extern se_irq_table, se_irq_table_position


.section .text.custom_irq_that_updates_scroll,"ax",@progbits
.global custom_irq_that_updates_scroll
custom_irq_that_updates_scroll:
    ; +3 = X (lo)
    ; +4 = X (hi)
    ; +5 = Y (lo)
    ; +6 = Y (hi)
    
    txa
    pha
    tya
    pha

    ldy se_irq_table_position

    ; The first two PPU writes can come anytime during the scanline:
    ; Nametable number << 2 to $2006.
    lda se_irq_table + 4, y ; hi byte of new X value
    lsr 
    lda se_irq_table + 6, y
    rol 
    asl 
    asl 
    sta $2006

    ; Y position to $2005
    lda se_irq_table + 5, y
    sta $2005

    ; Prepare for the 2 later writes:
    ; We reuse new_x to hold (Y & $F8) << 2.
    and #%11111000
    asl
    asl
    ldx se_irq_table + 3, y
    sta se_irq_table + 3, y

    ; ((Y & $F8) << 2) | (X >> 3) in A for $2006 later.
    txa
    lsr
    lsr
    lsr
    ora se_irq_table + 3, y

    php
    plp
    php
    plp

    ; The last two PPU writes must happen during hblank:
    stx $2005
    sta $2006

    ; Restore new_x.
    txa
    sta se_irq_table + 3, y

    
    
    ; increment irq table position
    tya
    clc
    adc #7
    sta se_irq_table_position

    ; restore Y
    pla
    tay
    jmp irq_exit_no_preserve_x




.section .text.custom_irq_that_does_sine_scroll,"ax",@progbits
.global custom_irq_that_does_sine_scroll
custom_irq_that_does_sine_scroll:
    ; +3 = start position
    ; +4 = intensity
    ; +5 = times run thus far
    txa
    pha


    ldx se_irq_table_position

    ; increment times run by intensity
    lda se_irq_table + 5, x
    clc
    adc se_irq_table + 4, x 
    sta se_irq_table + 5, x

    adc se_irq_table + 3, x
    ;lda se_irq_table + 5, x
    tax

    lda se_sine_table, x
    lsr
    lsr
    lsr
    lsr

    sta $2005
    sta $2005



    ;lda se_irq_table_position
    ;clc
    ;adc #5
    ;sta se_irq_table_position

    jmp irq_exit_no_preserve_x