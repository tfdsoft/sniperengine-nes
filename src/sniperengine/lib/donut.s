;;
;;  ADDITIONS BY UserSniper:
;;  I needed a quick way to call this from C;
;;  this sniperengine function does exactly that
;;

;; example function for troubleshooting (donut.s)
.section .text.se_donut_decompress_vram,"ax",@progbits
.globl se_donut_decompress_vram
se_donut_decompress_vram:
    ;     A = bank number
    ; __rc2 = ptr (lo)
    ; __rc3 = ptr (hi)

    ; inlined for extra SPEED
    tax
    lda __prg_a000
    pha
    txa

    jsr donut_block

    pla
    jsr set_prg_a000
    rts



;; ORIGINAL DONUT CODE, MODIFIED TO USE LLVM-MOS' SYNTAX:

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

.include "imag.inc"

.global donut_decompress_block, donut_block ;, donut_block_ayx, donut_block_x
.global donut_block_buffer
.global donut_stream_ptr
; .exportzp donut_block_count

; jroweboy: We alias these with __rc5 - __rc20
; since we only call donut from the main thread its fine
temp = __rc5  ; 15 bytes are used

; jroweboy - donut starts at this addr + 64 because ???? but it works out just fine anyway
donut_block_buffer = $0100  ; 64 bytes

;.section .zp.bss
;donut_stream_ptr:       .fill 2
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

donut_stream_ptr = __rc2
; donut_block_count = $00

.section .text.donut_block,"ax",@progbits
.globl donut_block
donut_block:
  PPU_DATA = $2007
  lda __rc2
  sta donut_stream_ptr
  lda __rc3
  sta donut_stream_ptr+1
  .Lblock_loop:
    ldx #0
    jsr donut_decompress_block
    cpx #64
    bne .Lend_block_upload
      ; bail if donut_decompress_block does not
      ; advance X by 64 bytes, indicating a header error.

    ldx #256 - 64
    .Lupload_loop:
      lda donut_block_buffer - (256 - 64), x
      sta PPU_DATA
      inx
      bmi .Lupload_loop
    bpl .Lblock_loop
    ; ldx donut_block_count
    ; bne block_loop
  .Lend_block_upload:
  rts

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
.section .text.donut_decompress_block,"ax",@progbits
donut_decompress_block:
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
  bcs .Lexit_error
  sta block_offset_end

  lda (donut_stream_ptr), y
  iny  ; Reading input bytes are now post-increment.
  sta block_header

  cmp #$2a
  beq .Ldo_raw_block
  ;,; bne do_normal_block
.Ldo_normal_block:
  cmp #$c0
  bcc .Lcontinue_normal_block
  ;,; bcs exit_error
.Lexit_error:
rts
; If we don't exit here, xor_l_onto_m can underflow into zeropage.

; I'm inserting these things here instead of above the donut_decompress_block
; at the cost of 1 cycle with the continue_normal_block branch for these reasons:
; The start of the main routine remains at the start of the .proc scope
; and I can save 1 byte with 'bcs end_block'

.Lread_plane_def_from_stream:
  ror
  lda (donut_stream_ptr), y
  iny
bne .Lplane_def_ready  ;,; jmp plane_def_ready

.Ldo_raw_block:
  ;,; ldx block_offset
  .Lraw_block_loop:
    lda (donut_stream_ptr), y
    iny
    sta donut_block_buffer, x
    inx
    cpy #65  ; size of a raw block
  bcc .Lraw_block_loop
bcs .Lend_block  ;,; jmp end_block

.Lcontinue_normal_block:
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
  bcs .Lread_plane_def_from_stream
  ;,; bcc unpack_shorthand_plane_def
  .Lunpack_shorthand_plane_def:
    and #$03
    tax
    lda shorthand_plane_def_table, x
  .Lplane_def_ready:
  ror is_rotated
  sta plane_def
  sty temp_y

  clc
  lda block_offset
  .Lplane_loop:
    adc #8
    sta block_offset

    lda even_odd
    eor block_header
    sta even_odd

    ;,; lda even_odd
    and #$30
    beq .Lnot_predicted_from_ff
      lda #$ff
    .Lnot_predicted_from_ff:
      ; else A = 0x00

    asl plane_def
    bcc .Ldo_zero_plane
    ;,; bcs do_pb8_plane
  .Ldo_pb8_plane:
    ldy temp_y
    bit is_rotated
    bpl .Lno_rewind_input_pointer
      ldy #$02
    .Lno_rewind_input_pointer:
    tax
    lda (donut_stream_ptr), y
    iny
    sta pb8_ctrl
    txa

    ;,; bit is_rotated
  bvs .Ldo_rotated_pb8_plane
  ;,; bvc do_normal_pb8_plane
  .Ldo_normal_pb8_plane:
    ldx block_offset
    ;,; sec  ; C is set from 'asl plane_def' above
    rol pb8_ctrl
    .Lpb8_loop:
      bcc .Lpb8_use_prev
        lda (donut_stream_ptr), y
        iny
      .Lpb8_use_prev:
      dex
      sta donut_block_buffer, x
      asl pb8_ctrl
    bne .Lpb8_loop
    sty temp_y
  ;,; beq end_plane  ;,; jmp end_plane
  .Lend_plane:
    bit even_odd
    bpl .Lnot_xor_m_onto_l
    .Lxor_m_onto_l:
      ldy #8
      .Lxor_m_onto_l_loop:
        dex
        lda donut_block_buffer, x
        eor donut_block_buffer+8, x
        sta donut_block_buffer, x
        dey
      bne .Lxor_m_onto_l_loop
    .Lnot_xor_m_onto_l:

    bvc .Lnot_xor_l_onto_m
    .Lxor_l_onto_m:
      ldy #8
      .Lxor_l_onto_m_loop:
        dex
        lda donut_block_buffer, x
        eor donut_block_buffer+8, x
        sta donut_block_buffer+8, x
        dey
      bne .Lxor_l_onto_m_loop
    .Lnot_xor_l_onto_m:

    lda block_offset
    cmp block_offset_end
  bcc .Lplane_loop
  ldy temp_y
.Lend_block:
  ;,; sec
  clc
  tya
  adc donut_stream_ptr+0
  sta donut_stream_ptr+0
  bcc .Ladd_stream_ptr_no_inc_high_byte
    inc donut_stream_ptr+1
  .Ladd_stream_ptr_no_inc_high_byte:
  ldx block_offset_end
  ; dec donut_block_count
rts

.Ldo_zero_plane:
  ldx block_offset
  ldy #8
  .Lfill_plane_loop:
    dex
    sta donut_block_buffer, x
    dey
  bne .Lfill_plane_loop
beq .Lend_plane  ;,; jmp end_plane

.Ldo_rotated_pb8_plane:
  ldx #8
  .Lbuffered_pb8_loop:
    asl pb8_ctrl
    bcc .Lbuffered_pb8_use_prev
      lda (donut_stream_ptr), y
      iny
    .Lbuffered_pb8_use_prev:
    dex
    sta plane_buffer, x
  bne .Lbuffered_pb8_loop
  sty temp_y
  ldy #8
  ldx block_offset
  .Lflip_bits_loop:
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
    sta donut_block_buffer, x
    dey
  bne .Lflip_bits_loop
beq .Lend_plane  ;,; jmp end_plane

shorthand_plane_def_table:
  .byte $00, $55, $aa, $ff
