    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000                   ; defines the origin of the ROM at $F000

START:
    CLEAN_START       ; Macro to safely clear the memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NextFrame:
    lda #2                                             ; same as binary value %0000010
    sta VBLANK                                         ; turn on VBLANK
    sta VSYNC                                          ; turn on VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC                                          ; first scanline
    sta WSYNC                                          ; second scanline
    sta WSYNC                                          ; three scanline

    lda #0
    sta VSYNC                                          ; turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the TIA output the recommended 37 scanlines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37                                            ; X = 37 (to count 37 scanlines)
LoopVBlank:
    sta WSYNC                                          ; hit WSYNC and wait for the next scanline
    dex                                                ; X--
    bne LoopVBlank                                     ; Loop while X != 0

    lda #0
    sta VBLANK                                         ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines (kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #192                                           ; counter 192 visible scanlines
LoopScanline:
    stx COLUBK                                         ; set color background to X
    sta WSYNC                                          ; wait for the next scanline
    dex
    bne LoopScanline

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output 30 more VBLANK lines (overscan) to complete our frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK

    ldx #30                                            ; counter for 30 scanlines
LoopOverscan:
    sta WSYNC                                          ; wait for next scanline
    dex                                                ; X--
    bne LoopOverscan

    jmp NextFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC                   ; Defines origin to $FFFC
    .word START                 ; Reset vector at $FFFC (where the program starts)
    .word START                 ; Interrupt vector at $FFFE (not used)
