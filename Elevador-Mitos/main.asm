.org 0x000
	jmp reset
.org 0x0006 
	jmp handle_INT0
.org 0x000A
	jmp handle_INT2
.org OC1Aaddr
	jmp OC1A_Interrupt
.def contagem = r17
.def temp = r16
.def oldINT0 = r0
.def oldINT2 = r2

	ldi temp, 1
	reti


delay20ms:
	push r22
	push r21
	push r20

	ldi r22, byte3(16*1000*20 / 5)
	ldi r21, high(16*1000*20 / 5)
	ldi r20, low(16*1000*20 / 5)

	subi r20,1
	sbci r21,0
	sbci r22,0
	brcc pc-3

	pop r20
	pop r21
	pop r22
	ret



handle_INT0:
	.def temp2 = r18;
	cli ; TODO: Só desligar essa interrupção
	push temp2
	; Fechar do Elevador = PB0; PCINT0
	; Chamar 0 = PB2; PCINT2
	; Chamar 1 = PB3; PCINT3 
	; Chamar 2  = PB4; PCINT4
	in temp2, PINB
	call delay20ms;Debouncing
	sbrc temp2,0
	jmp botao_fechar_pressionado
	sbrc temp2,2
	jmp botao_chamar0_ext_pressionado
	sbrc temp2,3
	jmp botao_chamar1_ext_pressionado
	sbrc temp2,4
	jmp botao_chamar2_ext_pressionado
	jmp end_handle_int0
	botao_chamar0_ext_pressionado:

		jmp end_handle_int0
	botao_chamar1_ext_pressionado:

		jmp end_handle_int0
	botao_chamar2_ext_pressionado:

		jmp end_handle_int0
	botao_fechar_pressionado:

		jmp end_handle_int0

	end_handle_int0:
	pop temp2
	.undef temp2
	sei; TODO: Só religar essa interrupção
	reti


handle_INT2:
	.def temp2 = r18;
	cli ; TODO: Só desligar essa interrupção
	push temp2
	;0 do Elevador = PD4 ; PCINT20
	;1 do Elevador = PD5 ; PCINT21
	;2 do Elevador = PD6 ; PCINT22
	;Abrir do Elevador = PD7; PCINT23
	in temp2, PIND
	call delay20ms;Debouncing
	sbrc temp2,4
	jmp botao_chamar0_in_pressionado
	sbrc temp2,5
	jmp botao_chamar1_in_pressionado
	sbrc temp2,6
	jmp botao_chamar2_in_pressionado
	sbrc temp2,7
	jmp botao_abrir_pressionado
	jmp end_handle_int1
	botao_chamar0_in_pressionado:

		jmp end_handle_int1
	botao_chamar1_in_pressionado:

		jmp end_handle_int1
	botao_chamar2_in_pressionado:

		jmp end_handle_int1
	botao_abrir_pressionado:

		jmp end_handle_int1

	end_handle_int1:
	pop temp2
	.undef temp2
	sei; TODO: Só religar essa interrupção
	reti


OC1A_Interrupt:
	ldi temp, 1
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
;Pin change Interrupt (23:16) and (0:7)
ldi temp, 0b00000101;
sts PCICR, temp
 
; Enables PCINT 4 TO 0, but 1 (the buzzer).
ldi temp, 0b00011101;
;out PCMSK0, temp
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

;getInts current values
;in 

sei ;Enable Interrupts
rjmp pc; Infinite Loop