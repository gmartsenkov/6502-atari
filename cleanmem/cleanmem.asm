    processor 6502

    seg code
    org $F000                   ; Define the code origin at $F000

Start:
    sei                         ; Disable interrupts
    cld                         ; Disable the BCD decimal math mode
    ldx #$FF                    ; Loads the X regist with #$FF
    txs                         ; Transfer the x register to the stack pointer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Page Zero region ($00 to $FF)
; Meaning the entire RAM and also the TIA register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0                      ; A = 0
    ldx #$FF                    ; X = #$FF
MemLoop:
    sta $0,X                    ; Store the value of A inside MEM address  $0 + X
    dex                         ; X--
    bne MemLoop                 ; Loop until X is 0 (until Z flag is set)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start                 ; Reset vector at $FFFC (wheere the program starts)
    .word Start                 ; Interrupt vector at $FFFE (unused in the VCS)
