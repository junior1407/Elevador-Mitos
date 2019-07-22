.org 0x000
	jmp reset
.org INT0addr ; INT0addr is the address of EXT_INT0
;	jmp handle_pb0
.org INT1addr ; INT1addr is the address of EXT_INT1
;	jmp handle_pb1

.def temp = r16

;A do BCD = PD2 ; PCINT18
;B do BCD = PD3 ; PCINT19
;0 do Elevador = PD4 ; PCINT20
;1 do Elevador = PD5 ; PCINT21
;2 do Elevador = PD6 ; PCINT22
;Abrir do Elevador = PD7; PCINT23
; Fechar do Elevador = PB0; PCINT0
; Buzzer = PB1;  PCINT1
; Chamar 0 = PB2; PCINT2
; Chamar 1 = PB3; PCINT3 
; Chamar 2  = PB4; PCINT4


;sbi PORTD, 2
;cbi PORTD, 2

reset: 

; Enables PCINT 4 TO 0, but 1 (the buzzer).
ldi temp, 0b00011101;
sts PCMSK0, temp 


; Enables PCINT 23 TO 20
ldi temp, 0b11110000
sts PCMSK2, temp 

; Setar interrupções botoes



;Stack initialization
ldi temp, low(RAMEND)
out SPL, temp
ldi temp, high(RAMEND)
out SPH, temp

sei ;Enable Interrupts
rjmp pc; Infinite Loop