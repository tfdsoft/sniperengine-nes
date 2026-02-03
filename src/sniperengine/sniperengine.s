.segment "ZEROPAGE"
__bank_select_hi: 	.res 1
__in_progress:		.res 1
__prg_c000:			.res 1
__prg_a000:			.res 1

se_palette_buffer:  .res 32
se_palette_pointer_bg:  .res 2
se_palette_pointer_spr: .res 2


.segment "BSS"
se_frame_count:     .res 1

se_ppu_mask_var:    .res 1
se_ppu_ctrl_var:    .res 1

se_scroll_x:        .res 2
se_scroll_y:        .res 2

se_vram_update:     .res 1
se_palette_update:  .res 1

se_sprite_id:       .res 1



.segment "CODE"
;;
;; SNIPERENGINE API
;; USEFUL FOR ROM HACKING
;; TABLE STARTS AT $E100
.align 128
;;

;; mmc3 functions
jmp set_prg_a000
jmp set_prg_c000
jmp banked_call_a000
jmp set_chr_bank

;; chr functions
.align 32
jmp se_donut_decompress_vram


;; ppu functions
.align 32
jmp se_wait_vsync




;;
;;  MMC3 BANKING FUNCTIONS
;;  CODE IS FROM THE LLVM-MOS-SDK (modified, of course)
;;


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
                            ;; why not just fall through here?
.endproc

__set_reg_retry:
	dec __in_progress
	sta $8000
	stx $8001
	bit __in_progress
	bpl __set_reg_retry
	lda #0
	sta __in_progress
	rts

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

set_chr_bank_retry:
	ora __bank_select_hi
	jmp __set_reg_retry







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


;;  ADDITIONS BY UserSniper:
;;  I needed a quick way to call this from C;
;;  this sniperengine function does exactly that

.export se_donut_decompress_vram
.proc se_donut_decompress_vram
se_donut_decompress_vram:
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


.export se_clear_palette
.proc se_clear_palette
    ldx #$20
    lda #0
    @loop:
        sta se_palette_buffer, x
        dex
        bne @loop
    inx
    stx se_palette_update
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














.export nmi
.proc nmi
    pha
    txa
    pha
    tya
    pha

    ldy se_vram_update
    bne :+
    jmp @exit

    :
    ldy $2002
    lda #$3f
    ldx #$00

    sta $2006
    sta $2006

    .repeat 16,i
    ldy se_palette_buffer+i
    lda (se_palette_pointer_bg), y
    sta $2007
    .endrepeat

    .repeat 16,i
    ldy se_palette_buffer+i+16
    lda (se_palette_pointer_spr), y
    sta $2007
    .endrepeat

    @exit:
    pla
    tay
    pla
    tax
    pla
    rti
.endproc







.align 256
.proc se_palette_brightness_table
    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f

    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
    
    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
    
    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
    
    .byte $00, $01, $02, $03, $04, $05, $06, $07
    .byte $08, $09, $0a, $0b, $0c, $0d, $0e, $0f

    .byte $10, $11, $12, $13, $14, $15, $16, $17
    .byte $18, $19, $1a, $1b, $1c, $0d, $00, $00

    .byte $20, $21, $22, $23, $24, $25, $26, $27
    .byte $28, $29, $2a, $2b, $2c, $2d, $10, $10

    .byte $30, $31, $32, $33, $34, $35, $36, $37
    .byte $38, $39, $3a, $3b, $3c, $3d, $30, $30

    .byte $30, $30, $30, $30, $30, $30, $30, $30
    .byte $30, $30, $30, $30, $30, $30, $30, $30
    .byte $30, $30, $30, $30, $30, $30, $30, $30
    .byte $30, $30, $30, $30, $30, $30, $30, $30
    .byte $30, $30, $30, $30, $30, $30, $30, $30
    .byte $30, $30, $30, $30, $30, $30, $30, $30
    .byte $30, $30, $30, $30, $30, $30, $30, $30
    .byte $30, $30, $30, $30, $30, $30, $30, $30
.endproc