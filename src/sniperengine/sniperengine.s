
; stuff from llvm-mos' mmc3 libraries. 
.importzp __bank_select_hi,__in_progress,__prg_8000,__prg_a000
__prg_c000 = __prg_8000
__rc0 = $00
__rc1 = $01
__rc2 = $02
__rc3 = $03
__rc4 = $04
__rc5 = $05
__rc6 = $06
__rc7 = $07
__rc8 = $08
__rc9 = $09
__rc10 = $0a
__rc11 = $0b
__rc12 = $0c
__rc13 = $0d
__rc14 = $0e
__rc15 = $0f
__rc16 = $10
__rc17 = $11
__rc18 = $12
__rc19 = $13
__rc20 = $14
__rc21 = $15



.macpack longbranch


.segment "ZEROPAGE"
se_palette_buffer:  .res 32
se_palette_pointer_bg:  .res 2
se_palette_pointer_spr: .res 2

se_name_upd_adr:    .res 1
se_name_upd_enable: .res 1
se_vram_index:      .res 1
se_vram_tmp_stack_pointer:  .res 1

;se_rle_pointer:     .res 2 ;__rc2 is used instead

.segment "BSS"
se_frame_count:     .res 1

se_ppu_mask_var:    .res 1
se_ppu_ctrl_var:    .res 1
.export se_ppu_ctrl_var, se_ppu_mask_var

se_scroll_x:        .res 2
se_scroll_y:        .res 2

se_vram_update:     .res 1
se_palette_update:  .res 1
.export se_palette_update

se_sprite_id:       .res 1

se_rle_tag:         .res 1
se_rle_byte:        .res 1

se_vram_buffer = $140


.segment "_pprg__rom__fixed__lo"
;;
;; API, USEFUL FOR ROM HACKING
;; STARTS AT $8000
;;

;; init
jmp se_init

;; mmc3 functions
jmp set_prg_a000
jmp set_prg_c000
jmp banked_call_a000
jmp set_chr_bank

;; vram functions
;.align 32
jmp se_vram_donut_decompress
jmp se_vram_unrle


;; ppu functions
;.align 32
jmp se_wait_vsync
jmp se_turn_off_rendering
jmp se_turn_on_rendering

jmp se_set_palette_background
jmp se_set_palette_sprites
jmp se_set_palette_all
jmp se_set_palette_color
jmp se_set_palette_brightness_background
jmp se_set_palette_brightness_sprites
jmp se_set_palette_brightness_all
jmp se_fade_palette_to
jmp se_clear_palette

jmp se_clear_sprites
jmp se_draw_sprite
jmp se_draw_metasprite


;;  
;;  IDENTITY TABLE
;;  CAN BE USED TO SPEED UP SOME CALCULATIONS.
;;  STARTS AT $8100
;;
.align 256
.export se_identity_table
.proc se_identity_table
    .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
    .byte $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f
    .byte $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
    .byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
    .byte $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
    .byte $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5f
    .byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f
    .byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f
    .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$8f
    .byte $90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9a,$9b,$9c,$9d,$9e,$9f
    .byte $a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9,$aa,$ab,$ac,$ad,$ae,$af
    .byte $b0,$b1,$b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9,$ba,$bb,$bc,$bd,$be,$bf
    .byte $c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7,$c8,$c9,$ca,$cb,$cc,$cd,$ce,$cf
    .byte $d0,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$da,$db,$dc,$dd,$de,$df
    .byte $e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7,$e8,$e9,$ea,$eb,$ec,$ed,$ee,$ef
    .byte $f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff
.endproc

;;  
;;  PALETTE BRIGHTNESS TABLE
;;  CAN BE USED TO SPEED UP SOME CALCULATIONS.
;;  STARTS AT $8200
;;
.align 256
.proc se_palette_brightness_table
    .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f ;0
    .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f ;1
    .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f ;2
    .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f ;3
    
    .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f ;4

    .byte $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f ;5

    .byte $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f ;6

    .byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3f,$3f ;7

    .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30 ;8
    .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
    .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
    .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
.endproc



;;
;;  INIT
;;  SETS UP THE ENGINE FOR YOU
;;
.export se_init
.proc se_init
    jsr se_clear_palette
    jsr se_clear_sprites

    lda #0
    ldx #0
    jsr set_chr_bank
    lda #1
    inx
    inx
    jsr set_chr_bank
    lda #2
    inx
    inx
    jsr set_chr_bank
    lda #3
    inx
    jsr set_chr_bank
    lda #4
    inx
    jsr set_chr_bank
    lda #5
    inx
    jsr set_chr_bank

    jsr se_set_vram_buffer

    rts
.endproc



;;
;;  MMC3 BANKING FUNCTIONS
;;  CODE IS FROM THE LLVM-MOS-SDK (modified, of course)
;;  EVERYTHING FROM THIS POINT FORWARD IS AT $8300
;;
.export set_prg_c000
.proc set_prg_c000
set_prg_c000:
	sta __prg_c000
	tax
	lda #%00000110
	ora __bank_select_hi
	jmp __set_reg_retry
.endproc

.export set_prg_a000
.proc set_prg_a000
set_prg_a000:
	sta __prg_a000
	tax
	lda #%00000111
	ora __bank_select_hi
	;jmp __set_reg_retry    ;; SNIPERENGINE MODIFICATION:
.endproc                    ;; why not just fall through here?

.proc __set_reg_retry
	dec __in_progress
	sta $8000
	stx $8001
	bit __in_progress
	bpl __set_reg_retry
	lda #0
	sta __in_progress
	rts
.endproc

.export banked_call_a000
.proc banked_call_a000
banked_call_a000:
.import __call_indir
	tay
	lda __prg_a000
	pha
	tya
	jsr set_prg_a000
	lda __rc2
	sta __rc18
	lda __rc3
	sta __rc19
	jsr __call_indir
	pla
	jsr set_prg_a000
	rts
.endproc

.export set_chr_bank
.proc set_chr_bank
set_chr_bank:
	ora __bank_select_hi
	sta $8000
	stx $8001
	lda #0
	sta __in_progress
	rts
.endproc

.proc set_chr_bank_retry
	ora __bank_select_hi
	jmp __set_reg_retry
.endproc



;;
;; DONUT CODE, MODIFIED TO USE LLVM-MOS' SYNTAX:
;;

; "Donut", NES CHR codec decompressor,
; Copyright (c) 2018  Johnathan Roatch
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.
;
; Version History:
; 2019-02-15: Swapped the M and L bits, for conceptual consistency.
;             Also rearranged branches for speed.
; 2019-02-07: Removed "Duplicate" block type, and moved
;             Uncompressed block to below 0xc0 to make room
;             for block handling commands in the 0xc0~0xff space
; 2018-09-29: Removed block option of XORing with existing block
;             for extra speed in decoding.
; 2018-08-13: Changed the format of raw blocks to not be reversed.
;             Register X is now an argument for the buffer offset.
; 2018-04-30: Initial release.
;

.export donut_decompress_block, donut_block ;, donut_block_ayx, donut_block_x
.export donut_block_buffer
.exportzp donut_stream_ptr
; .exportzp donut_block_count

; jroweboy: We alias these with __rc5 - __rc20
; since we only call donut from the main thread its fine
temp = $05  ; 15 bytes are used

; jroweboy - donut starts at this addr + 64 because ???? but it works out just fine anyway
donut_block_buffer = $0100  ; 64 bytes

; .segment "_pzp":zeropage
; donut_stream_ptr:       .res 2
; donut_block_count:      .res 1

;;
; helper subroutine for passing parameters with registers
; decompress X*64 bytes starting at AAYY to PPU_DATA
; .proc donut_block_ayx
;   sty donut_stream_ptr+0
;   sta donut_stream_ptr+1
;   stx donut_block_count
; ;,; jmp donut_block_x
; .endproc

donut_stream_ptr = $02
; donut_block_count = $00

.proc donut_block
PPU_DATA = $2007
  ; lda $02
  ; sta donut_stream_ptr
  ; lda $03
  ; sta donut_stream_ptr+1
  block_loop:
    ldx #0
    jsr .loword(donut_decompress_block)
    cpx #64
    bne end_block_upload
      ; bail if donut_decompress_block does not
      ; advance X by 64 bytes, indicating a header error.

    ldx #256 - 64
    upload_loop:
      lda a:donut_block_buffer - (256 - 64), x
      sta PPU_DATA
      inx
      bmi upload_loop
    bpl block_loop
    ; ldx donut_block_count
    ; bne block_loop
end_block_upload:
rts
.endproc

;;
; Decompresses a single variable sized block pointed to by donut_stream_ptr
; Outputing 64 bytes to donut_block_buffer offsetted by the X register.
; On success, 64 will be added to the X register, donut_block_count
; will be decremented, and Y will contain the number of bytes read.
;
; Block header:
; LMlmbbBR
; |||||||+-- Rotate plane bits (135° reflection)
; ||||000--- All planes: 0x00
; ||||010--- L planes: 0x00, M planes:  pb8
; ||||100--- L planes:  pb8, M planes: 0x00
; ||||110--- All planes: pb8
; ||||001--- In another header byte, For each bit starting from MSB
; ||||         0: 0x00 plane
; ||||         1: pb8 plane
; ||||011--- In another header byte, Decode only 1 pb8 plane and
; ||||       duplicate it for each bit starting from MSB
; ||||         0: 0x00 plane
; ||||         1: duplicated plane
; ||||       If extra header byte = 0x00, no pb8 plane is decoded.
; ||||1x1--- Reserved for Uncompressed block bit pattern
; |||+------ M planes predict from 0xff
; ||+------- L planes predict from 0xff
; |+-------- M = M XOR L
; +--------- L = M XOR L
; 00101010-- Uncompressed block of 64 bytes (bit pattern is ascii '*' )
; Header >= 0xc0: Error, avaliable for outside processing.
; X >= 192: Also returns in Error, the buffer would of unexpectedly page warp.
;
; Trashes Y, A, temp 0 ~ temp 15.
; bytes: 253, cycles: 1269 ~ 7238.
.proc donut_decompress_block
    plane_buffer        = temp+0 ; 8 bytes
    pb8_ctrl            = temp+8
    temp_y              = pb8_ctrl
    even_odd            = temp+9
    block_offset        = temp+10
    plane_def           = temp+11
    block_offset_end    = temp+12
    block_header        = temp+13
    is_rotated          = temp+14
    ;_donut_unused_temp  = temp+15
    ldy #$00
    txa
    clc
    adc #64
    bcs exit_error
    sta block_offset_end

    lda (donut_stream_ptr), y
    iny  ; Reading input bytes are now post-increment.
    sta block_header

    cmp #$2a
    beq do_raw_block
    ;,; bne do_normal_block
    do_normal_block:
    cmp #$c0
    bcc continue_normal_block
    ;,; bcs exit_error
    exit_error:
    rts
    ; If we don't exit here, xor_l_onto_m can underflow into zeropage.

    ; I'm inserting these things here instead of above the donut_decompress_block
    ; at the cost of 1 cycle with the continue_normal_block branch for these reasons:
    ; The start of the main routine remains at the start of the .proc scope
    ; and I can save 1 byte with 'bcs end_block'

    read_plane_def_from_stream:
    ror
    lda (donut_stream_ptr), y
    iny
    bne plane_def_ready  ;,; jmp plane_def_ready

    do_raw_block:
    ;,; ldx block_offset
    raw_block_loop:
        lda (donut_stream_ptr), y
        iny
        sta a:donut_block_buffer, x
        inx
        cpy #65  ; size of a raw block
    bcc raw_block_loop
    bcs end_block  ;,; jmp end_block

    continue_normal_block:
    stx block_offset

    ;,; lda block_header
    and #%11011111
        ; The 0 are bits selected for the even ("lower") planes
        ; The 1 are bits selected for the odd planes
        ; bits 0~3 should be set to allow the mask after this to work.
    sta even_odd
        ; even_odd toggles between the 2 fields selected above for each plane.

    ;,; lda block_header
    lsr
    ror is_rotated
    lsr
    bcs read_plane_def_from_stream
    ;,; bcc unpack_shorthand_plane_def
    unpack_shorthand_plane_def:
        and #$03
        tax
        lda .loword(shorthand_plane_def_table), x
    plane_def_ready:
    ror is_rotated
    sta plane_def
    sty temp_y

    clc
    lda block_offset
    plane_loop:
        adc #8
        sta block_offset

        lda even_odd
        eor block_header
        sta even_odd

        ;,; lda even_odd
        and #$30
        beq not_predicted_from_ff
        lda #$ff
        not_predicted_from_ff:
        ; else A = 0x00

        asl plane_def
        bcc do_zero_plane
        ;,; bcs do_pb8_plane
    do_pb8_plane:
        ldy temp_y
        bit is_rotated
        bpl no_rewind_input_pointer
        ldy #$02
        no_rewind_input_pointer:
        tax
        lda (donut_stream_ptr), y
        iny
        sta pb8_ctrl
        txa

        ;,; bit is_rotated
    bvs do_rotated_pb8_plane
    ;,; bvc do_normal_pb8_plane
    do_normal_pb8_plane:
        ldx block_offset
        ;,; sec  ; C is set from 'asl plane_def' above
        rol pb8_ctrl
        pb8_loop:
        bcc pb8_use_prev
            lda (donut_stream_ptr), y
            iny
        pb8_use_prev:
        dex
        sta a:donut_block_buffer, x
        asl pb8_ctrl
        bne pb8_loop
        sty temp_y
    ;,; beq end_plane  ;,; jmp end_plane
    end_plane:
        bit even_odd
        bpl not_xor_m_onto_l
        xor_m_onto_l:
        ldy #8
        xor_m_onto_l_loop:
            dex
            lda a:donut_block_buffer, x
            eor a:donut_block_buffer+8, x
            sta a:donut_block_buffer, x
            dey
        bne xor_m_onto_l_loop
        not_xor_m_onto_l:

        bvc not_xor_l_onto_m
        xor_l_onto_m:
        ldy #8
        xor_l_onto_m_loop:
            dex
            lda a:donut_block_buffer, x
            eor a:donut_block_buffer+8, x
            sta a:donut_block_buffer+8, x
            dey
        bne xor_l_onto_m_loop
        not_xor_l_onto_m:

        lda block_offset
        cmp block_offset_end
    bcc plane_loop
    ldy temp_y
    end_block:
    ;,; sec
    clc
    tya
    adc donut_stream_ptr+0
    sta donut_stream_ptr+0
    bcc add_stream_ptr_no_inc_high_byte
        inc donut_stream_ptr+1
    add_stream_ptr_no_inc_high_byte:
    ldx block_offset_end
    ; dec donut_block_count
    rts

    do_zero_plane:
    ldx block_offset
    ldy #8
    fill_plane_loop:
        dex
        sta a:donut_block_buffer, x
        dey
    bne fill_plane_loop
    beq end_plane  ;,; jmp end_plane

    do_rotated_pb8_plane:
    ldx #8
    buffered_pb8_loop:
        asl pb8_ctrl
        bcc buffered_pb8_use_prev
        lda (donut_stream_ptr), y
        iny
        buffered_pb8_use_prev:
        dex
        sta plane_buffer, x
    bne buffered_pb8_loop
    sty temp_y
    ldy #8
    ldx block_offset
    flip_bits_loop:
        asl plane_buffer+0
        ror
        asl plane_buffer+1
        ror
        asl plane_buffer+2
        ror
        asl plane_buffer+3
        ror
        asl plane_buffer+4
        ror
        asl plane_buffer+5
        ror
        asl plane_buffer+6
        ror
        asl plane_buffer+7
        ror
        dex
        sta a:donut_block_buffer, x
        dey
    bne flip_bits_loop
    beq end_plane  ;,; jmp end_plane

    shorthand_plane_def_table:
    .byte $00, $55, $aa, $ff
.endproc



;; END OF DONUT CODE


;; see the header
;.export se_vram_address
;.proc se_vram_address
;    stx $2006
;    sta $2006
;    rts
;.endproc

.export se_vram_unrle
.proc se_vram_unrle

    se_rle_pointer = __rc2

    ldy se_rle_pointer+0
    lda #0
    sta se_rle_pointer+0

    lda (se_rle_pointer),y
    sta se_rle_tag
    iny
    bne @1
    inc se_rle_pointer+1

    @1:
        lda (se_rle_pointer+0),y
        iny
        bne @11
        inc se_rle_pointer+1

    @11:
        cmp se_rle_tag
        beq @2
        sta $2007
        sta se_rle_byte
        bne @1

    @2:
        lda (se_rle_pointer+0),y
        beq @4
        iny
        bne @21
        inc se_rle_pointer+1

    @21:
        tax
        lda se_rle_byte

    @3:
        sta $2007
        dex
        bne @3
        beq @1

    @4:
    rts
.endproc

.export se_vram_donut_decompress
.proc se_vram_donut_decompress
    ;     A = bank number
    ; __rc2 = ptr (lo)
    ; __rc3 = ptr (hi)

    ; inlined for extra SPEED
    tax
    lda __prg_a000
    pha
    txa

    jsr set_prg_a000

    jsr donut_block

    pla
    jsr set_prg_a000
    rts
.endproc






;;
;;  NESLIB-ESQUE FUNCTIONS
;;
.export se_wait_vsync
.proc se_wait_vsync
    lda #1
    sta se_vram_update
    lda se_frame_count
    @wait:
        cmp se_frame_count
        beq @wait
    rts
.endproc


;   enable/disable rendering

.export se_turn_off_rendering
.proc se_turn_off_rendering
    lda se_ppu_mask_var
    and #%11100111
    sta se_ppu_mask_var
    rts
.endproc

.export se_turn_on_rendering
.proc se_turn_on_rendering
    lda se_ppu_mask_var
    ora #%00011000
    sta se_ppu_mask_var
    rts
.endproc


;
.export se_set_palette_background
.proc se_set_palette_background
    ldx #0
    lda #$10
    bne __se_pal_copy ; bra
.endproc

.export se_set_palette_sprites
.proc se_set_palette_sprites
    ldx #$10
    txa 
    bne __se_pal_copy ; bra
.endproc

.export se_set_palette_all
.proc se_set_palette_all
    ldx #0
    lda #$20
    ;bne __se_pal_copy ; bra ; fall through
.endproc

.proc __se_pal_copy
    sta __rc4
    ldy #0
    @loop:
        lda (__rc2), y
        sta se_palette_buffer, x
        inx
        iny
        dec __rc4
        bne @loop
    inc se_palette_update
    rts
.endproc

.export se_set_palette_color
.proc se_set_palette_color
    and #$1f
    stx __rc2 ; swap a and x
    tax
    lda __rc2
    sta se_palette_buffer, x
    inc se_palette_update
    rts
.endproc

.export se_set_palette_brightness_background
.proc se_set_palette_brightness_background
    asl
    asl
    asl
    asl
    sta     __rc2
    lda     #<se_palette_brightness_table
    clc
    adc     __rc2
    tax
    lda     #>se_palette_brightness_table
    adc     #0
    stx     se_palette_pointer_bg+0
    sta     se_palette_pointer_bg+1
    inc     se_palette_update
    rts
.endproc

.export se_set_palette_brightness_sprites
.proc se_set_palette_brightness_sprites
    asl
    asl
    asl
    asl
    sta     __rc2
    lda     #<se_palette_brightness_table
    clc
    adc     __rc2
    tax
    lda     #>se_palette_brightness_table
    adc     #0
    stx     se_palette_pointer_spr+0
    sta     se_palette_pointer_spr+1
    inc     se_palette_update
    rts
.endproc

.export se_set_palette_brightness_all
.proc se_set_palette_brightness_all
    pha
    jsr se_set_palette_brightness_background
    pla
    jmp se_set_palette_brightness_sprites
.endproc

.export se_fade_palette_to
.proc se_fade_palette_to
    tay
	lda __rc20
	pha
	lda __rc21
	pha
	stx __rc20 ;to
	sty __rc21 ;from
	jmp @check_equal

    @fade_loop:
        ldx #4
        :
        jsr se_wait_vsync ;wait 4 frames
        dex
        bne :-

        lda __rc21 ;from
        cmp __rc20 ;to
        bcs @more

    @less:
        clc
        adc #1
        sta __rc21 ;from
        jsr se_set_palette_brightness_all
        jmp @check_equal

    @more:
        sec
        sbc #1
        sta __rc21 ;from
        jsr se_set_palette_brightness_all

    @check_equal:
        lda __rc21
        cmp __rc20
        bne @fade_loop

    @done:
	jsr se_wait_vsync ;do 1 final, make sure the last change goes
	pla
	sta __rc21
	pla
	sta __rc20
	rts
.endproc


.export se_clear_palette
.proc se_clear_palette
    ldx #$20
    lda #0
    @loop:
        sta se_palette_buffer, x
        dex
        bne @loop
    inc se_palette_update
    rts
.endproc

;.export
;.proc
;
;.endproc


;.export
;.proc
;
;.endproc


;.export
;.proc
;
;.endproc



.export se_clear_sprites
.proc se_clear_sprites
    .import OAM_BUF
    ldx #0
    stx se_sprite_id
    lda #$ff
    @loop:
        sta OAM_BUF,x
        inx
        inx
        inx
        inx
        bne @loop
    rts
.endproc 

.export se_draw_sprite
.proc se_draw_sprite
    .import OAM_BUF
    ;   A:  x
    ;   X:  y
    ;__rc2: tile
    ;__rc3: attributes
    ldy se_sprite_id
    sta OAM_BUF+3,y

    txa
    sta OAM_BUF+0,y

    lda __rc2
    sta OAM_BUF+1,y 

    lda __rc3
    sta OAM_BUF+2,y 

    tya
    clc
    adc #4
    sta se_sprite_id
    rts
.endproc

.export se_draw_metasprite
.proc se_draw_metasprite
    .import OAM_BUF
    ;   A:  x
    ;   X:  y
    ;__rc2: pointer (lo)
    ;__rc3: pointer (hi)
    sta __rc4
	stx __rc5
	ldx se_sprite_id
	ldy #0
    @loop:
        lda (__rc2),y		;x offset
        cmp #$80
        beq @exit
        iny
        clc
        adc __rc4
        sta OAM_BUF+3,x
        lda (__rc2),y		;y offset
        iny
        clc
        adc __rc5
        sta OAM_BUF+0,x
        lda (__rc2),y		;tile
        iny
        sta OAM_BUF+1,x
        lda (__rc2),y		;attribute
        iny
        sta OAM_BUF+2,x
        inx
        inx
        inx
        inx
        jmp @loop
    @exit:
    stx se_sprite_id
    rts
.endproc

;;
;;  VRAM BUFFER STUFF
;;  easily write to the screen with these several cool tricks!
;;
.proc __post_vram_update
    ldx #255
    stx se_vram_buffer
    inx
    stx se_vram_index
    ldx $2002
    rts
.endproc

.export se_set_vram_update
.proc se_set_vram_update
    sta se_name_upd_adr+0
    stx se_name_upd_adr+1
    inc se_name_upd_enable
    rts
.endproc

.export se_set_vram_buffer
.proc se_set_vram_buffer
    lda #<se_vram_buffer
    ldx #>se_vram_buffer
    jsr se_set_vram_update
    jsr __post_vram_update
    rts
.endproc

.export se_one_vram_buffer
.proc se_one_vram_buffer
    ldy se_vram_index

    pha
    lda __rc2
    sta se_vram_buffer,y
    txa
    iny
    sta se_vram_buffer,y
    pla
    iny
    sta se_vram_buffer,y
    lda #$ff
    iny
    sta se_vram_buffer,y
    sty se_vram_index

    rts
.endproc

.export se_string_vram_buffer
.proc se_string_vram_buffer
    pha

    ; write high byte of address
    txa
    ora #$40
    ldx se_vram_index
    sta se_vram_buffer,x

    ; write low byte of address
    pla
    inx
    sta se_vram_buffer,x

    ; save index for later
    inx
    txa
    pha
    inx

    ;ldx se_identity_table,y ;tyx
    ldy #0

    @copy_string:
        lda (__rc2),y
        beq :+
        sta se_vram_buffer,x
        inx
        iny
        bne @copy_string
    :
    lda #$ff
    sta se_vram_buffer,x

    ; length of string is in y, put that at index 2
    pla
    tax
    tya
    sta se_vram_buffer,x

    rts
.endproc

.export flush_vram_update2
.proc flush_vram_update2
    tsx
    stx se_vram_tmp_stack_pointer

    ; push new stack value
    ldx #$3f
    txs

    @1:
    ; ldy #0
    __get_next_instruction:
        pla
        cmp #$40
        bcc @update_single_tile

        ;not horizontal? save upper address byte for arithmetic
        tax
        lda se_ppu_ctrl_var
        cpx #$80
        bmi @update_horizontal_sequence
        cpx #$ff
        beq @exit

    @update_vertical_sequence:
        ora #$04
        bne @update_common_sequence

    @update_single_tile:
        sta $2006
        pla
        sta $2006
        pla
        sta $2007
        clc
        bcc __get_next_instruction

    @update_horizontal_sequence:
        and #$fb

    @update_common_sequence:
        sta $2000

        txa
        and #$3f

        sta $2006
        pla
        sta $2006
        pla

        bmi @update_repeated_byte

        ;tax
    @update_common_sequence_loop:
        ;pla
        ;sta $2007
        ;dex
        ;bne @update_common_sequence_loop

        ;; larger overhead, but the fastest possible writes
        tax
        lda the_funny_fours_table_lmao,x
        tay
        lda #<pla_sta_2007_table_end ; low byte
        ldx #>pla_sta_2007_table_end ; high byte
        sec
        sbc se_identity_table,y
        bcs:+   ;; TODO: align to a page boundary
        dex     ;; so i don't have to decrement x
        :
        sta __rc18
        stx __rc19
        
        jmp (__rc18)

    @update_repeated_byte:
        and #$7f
        tax
        pla
    @update_repeated_byte_loop:
        sta $2007
        dex
        bne @update_repeated_byte_loop

        lda se_ppu_ctrl_var
        sta $2000

        bne __get_next_instruction

    @exit:
    ldx se_vram_tmp_stack_pointer
    txs
    jmp __post_vram_update

    return_to_flush_vram_update:
        lda se_ppu_ctrl_var
        sta $2000

        bne __get_next_instruction


;.align 256
the_funny_pla_sta_2007_table_lmao:
    .repeat 32,i
        pla
        sta $2727
    .endrepeat
    pla_sta_2007_table_end:
    jmp return_to_flush_vram_update
.endproc

the_funny_fours_table_lmao:
    .byte $00,$04,$08,$0c
    .byte $10,$14,$18,$1c
    .byte $20,$24,$28,$2c
    .byte $30,$34,$38,$3c
    .byte $40,$44,$48,$4c
    .byte $50,$54,$58,$5c
    .byte $60,$64,$68,$6c
    .byte $70,$74,$78,$7c








.export nmi
.proc nmi
    pha
    txa
    pha
    tya
    pha

    ;; is rendering enabled?
    lda se_ppu_mask_var
    and #%00011000
    cmp #%00011000
    jne @skip_all_updates  ; if not, skip vram updates
        ;; START OF VRAM UPDATES
        ldy se_palette_update
        jeq @skip_palette   ; skip palette if not needed

            ldy #0
            sty $2001
            sty se_palette_update

            ldy $2002
            lda #$3f
            ldx #$00

            sta $2006
            stx $2006

            ; background
            .repeat 16,i
                ldy se_palette_buffer+i
                lda (se_palette_pointer_bg), y
                sta $2007
            .endrepeat

            ; sprites
            ldy se_palette_buffer+0
            lda (se_palette_pointer_bg), y
            sta $2007
            .repeat 3,i
                ldy se_palette_buffer+i+17
                lda (se_palette_pointer_bg), y
                sta $2007
            .endrepeat
            ldy se_palette_buffer+4
            lda (se_palette_pointer_bg), y
            sta $2007
            .repeat 3,i
                ldy se_palette_buffer+i+21
                lda (se_palette_pointer_bg), y
                sta $2007
            .endrepeat
            ldy se_palette_buffer+8
            lda (se_palette_pointer_bg), y
            sta $2007
            .repeat 3,i
                ldy se_palette_buffer+i+25
                lda (se_palette_pointer_bg), y
                sta $2007
            .endrepeat
            ldy se_palette_buffer+12
            lda (se_palette_pointer_bg), y
            sta $2007
            .repeat 3,i
                ldy se_palette_buffer+i+29
                lda (se_palette_pointer_bg), y
                sta $2007
            .endrepeat
            
        @skip_palette:
        ldy se_vram_update
        beq @skip_vram_updates
            ldy se_name_upd_enable
            beq @skip_nametable_updates
                ldy #0
                sty se_vram_update
                jsr flush_vram_update2
            @skip_nametable_updates:
            ldy $2002

            lda se_scroll_x
            ldx se_scroll_y
            sta se_scroll_x
            stx se_scroll_y

            lda se_ppu_ctrl_var
            sta $2000

        @skip_vram_updates:

    @skip_all_updates:
    lda se_scroll_x
    ldx se_scroll_y
    sta $2005
    stx $2005

    lda se_ppu_ctrl_var
    sta $2000
    lda se_ppu_mask_var
    sta $2001
    lda #2
    sta $4014

    inc se_frame_count

    pla
    tay
    pla
    tax
    pla
    rti
.endproc






