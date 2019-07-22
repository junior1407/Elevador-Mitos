.org 0x000
	jmp reset
.org INT0addr ; INT0addr is the address of EXT_INT0
;	jmp handle_pb0
.org INT1addr ; INT1addr is the address of EXT_INT1
;	jmp handle_pb1
.org OC1Aaddr
	jmp OC1A_Interrupt

.def temp = r16

OC1A_Interrupt:
	nop
	nop
	reti
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
cli
; Enables PCINT 4 TO 0, but 1 (the buzzer).
ldi temp, 0b00011101;
sts PCMSK0, temp 


; Enables PCINT 23 TO 20
ldi temp, 0b11110000
sts PCMSK2, temp 

#define CLOCK 16.0e6 ;clock speed
.equ PRESCALE = 0b100 ;/256 prescale
.equ PRESCALE_DIV = 256

#define DELAY 1 ;seconds
.equ WGM = 0b0100 ;Waveform generation mode: CTC
;you must ensure this value is between 0 and 65535
.equ TOP = int(0.5 + ((CLOCK/PRESCALE_DIV)*DELAY))
.if TOP > 65535
.error "TOP is out of range"
.endif

;On MEGA series, write high byte of 16-bit timer registers first
ldi temp, high(TOP) ;initialize compare value (TOP)
sts OCR1AH, temp
ldi temp, low(TOP)
sts OCR1AL, temp
ldi temp, ((WGM&0b11) << WGM10) ;lower 2 bits of WGM 
sts TCCR1A, temp
;upper 2 bits of WGM and clock select
ldi temp, ((WGM>> 2) << WGM12)|(PRESCALE << CS10)
sts TCCR1B, temp ;start counter

lds r16, TIMSK1
sbr r16, 1 <<OCIE1A
sts TIMSK1, r16


;Stack initialization
ldi temp, low(RAMEND)
out SPL, temp
ldi temp, high(RAMEND)
out SPH, temp

sei ;Enable Interrupts
rjmp pc; Infinite Loop