#include <p18F45K50.inc>
    CONFIG WDTEN=OFF	    ;disable watchdog timer
    CONFIG MCLRE = ON	    ;MCLEAR Pin on
    CONFIG DEBUG = ON	    ;Enable Debug Mode
    CONFIG LVP = ON	    ;Low-Voltage programming
    CONFIG PBADEN = OFF
    CONFIG FOSC = INTOSCIO  ;Internal oscillator, port function on RA6
    org 0		    ;start code at 0
    
Start:
    CLRF    PORTA	    ;clear port A
    CLRF    LATA	    ;clear latch A
    CLRF    TRISA	    ;set port A to output
    BSF	    PORTA, RA6	    ;set RA6 on

    MOVLW   b'01110111'	    ;OSC set to 16MHz, =0x77
    MOVWF   OSCCON    
    MOVLW   0x03	    ;Timer0 set prescaler 16:1, =0x03
    MOVWF   T0CON
    
    MOVLW   0x0B	    ;fosc = 16MHz, fcy = 4Mhz, tCy = 2.5*10^-7s
    MOVWF   TMR0H	    ;Prescaler = 16, 0.25s = X*16*2.5*10^-7
    MOVLW   0xDC	    ;X = 62500
    MOVWF   TMR0L	    ;FFFF = 65536, 65536-62500 = 3035 = 0BDC
    
    GOTO INT1

Main:    
    BCF	    INTCON, TMR0IF  ;clear Timer0 interrupt flag
    CALL    Delay	    ;jump to Delay
    BRA	    Main	    ;loop Main
    
Delay: 
    BSF	    T0CON, TMR0ON   ;start Timer0
    BTG	    PORTA, RA7	    ;toggle RA7
    BTG	    PORTA, RA6	    ;toggle RA6 
    
Loop:
    BTFSS   INTCON, TMR0IF  ;monitor Timer0 interrupt flag
    BRA	    Loop	    ;loop
    BCF	    T0CON, TMR0ON   ;stop Timer0
    RETURN		    ;return to CALL
    
    end