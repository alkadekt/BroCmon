*-----------------------------------------------------------
* Title      :  7seg
* Written by :  Andrew Keehan
* Date       :  9/16/21
* Description:  These subroutines handle drawing a 7segment LED
*-----------------------------------------------------------
CONSOLE_COLOR               EQU $00296112
*-----------------------------------------------------------
updateHealth:
* update the health 7segs for ally and wild BroCmon
* Registers:

        * save off address registers a2 and a3
        lea     addSave,a1
        movem.l a2-a3,(a1)
               
        * load in wild health
        lea     wHealth,a1
        move.l  (a1),d5        
        * input the console segment tables and draw the LED
        lea     WsegL,a2
        lea     WsegR,a3
        jsr     updateLEDs
        
        * load in player health
        lea     pHealth,a1
        move.l  (a1),d5 
        * input the console segment tables and draw the LED
        lea     PsegL,a2
        lea     PsegR,a3
        jsr     updateLEDs

        * put saved registers back
        lea     addSave,a1
        movem.l (a1),a2-a3         
        rts
*-----------------------------------------------------------
updateConsole:        
* updates the leds on the console to match the damage value
* Registers:
* d5 = value to display (0-9)

        * save off address registers a2 and a3
        lea     addSave,a1
        movem.l a2-a3,(a1)
        
        * input the console segment tables and draw the LED
        lea     segTabL,a2
        lea     segTabR,a3
        jsr     updateLEDs
        
        * put saved registers back
        lea     addSave,a1
        movem.l (a1),a2-a3        
        rts
*-----------------------------------------------------------
redrawConsole:
* redraws the console behind the damage leds

        * save off registers
        lea     ledSave,a1
        movem.l d1-d7,(a1)

        * set pen color
        move.l  #CONSOLE_COLOR,d1
        move.l  #PEN_COLOR,d0
        trap    #15
        
        * set fill color
        move.l  #CONSOLE_COLOR,d1
        move.l  #FILL_COLOR,d0
        trap    #15
        
        * move in the coordinates
        move.l  #272,d1
        move.l  #382,d2
        move.l  #368,d3
        move.l  #478,d4
        
        * draw the rectangle                
        move.l  #RECT,d0
        trap    #15
        
        * move saved registers back in
        lea     ledSave,a1
        movem.l (a1),d1-d7 
        
        rts
*-----------------------------------------------------------
updateLEDs:
* updates the damage leds
* Registers:
* d5 = value to display (0-9)
* a2 = left digit segment table
* a3 = right digit segment table

        * save off registers
        lea     ledSave,a1
        movem.l d1-d7,(a1)
        
        * set pen color
        move.l  #LED_COLOR,d1
        move.l  #PEN_COLOR,d0
        trap    #15
        
        * set fill color
        move.l  #LED_COLOR,d1
        move.l  #FILL_COLOR,d0
        trap    #15
        
        * check if we need to split the damage into 10s and 1s places
        clr.l   d6              ; clear out 10s place counter
        cmp.l   #10,d5          ; check if >10 so if we need to split
        blt     nosplit

* split damage into tens and ones place
splitLoop:
        subi.l  #10,d5          ; subtract 10 from damage
        add.l   #1,d6           ; increase 10s place counter
        cmp.l   #10,d5
        bge     splitLoop       ; keep going if still over 10               
        
nosplit:
        
        * 10s digit
        move.l  a2,a1
        move.l  d6,d4           ; move digit to display in
        jsr     draw7seg
        * 1s digit
        move.l  a3,a1
        move.l  d5,d4           ; move digit to display in
        jsr     draw7seg
        
        * move saved registers back in
        lea     ledSave,a1
        movem.l (a1),d1-d7  
        
        jsr     swapBuffers
        rts
*-----------------------------------------------------------
draw7seg:
* draws a 7 segment led to the screen
* Registers:
* a1 = mem address to particular segment table
* d4 = value to display (0-9)

        * save off d5
        lea     inSave,a2
        movem.l d5,(a2)
        
        * get proper bitmask
        lea     maskTab,a0
        add.l   d4,a0           ; move mask pointer to proper digit
        
        move.b  (a0),d6
        move.l  #6,d5           ; set bit counter at 6
        move.l  #7,d7           ; set loop counter at 8
loopin:

        btst    d5,d6           ; test the bit to see if it's 1
        beq     nope            ; branch ahead if no segment needed

        * draw appropriate segments
        move.l  (a1)+,d1
        move.l  (a1)+,d2
        move.l  (a1)+,d3
        move.l  (a1)+,d4
        
        move.l  #RECT,d0
        trap    #15

        subi.l  #1,d5           ; decrement bit counter
        subi.l  #1,d7           ; decrement loop counter
        bne     loopin    

        * get saved mem back
        move.l  (a2),d5   
        rts

nope:
        add.l   #16,a1          ; skip over unused segment data
        subi.l  #1,d5           ; decrement bit counter
        subi.l  #1,d7           ; decrement loop counter
        bne     loopin
        
        * get saved mem back
        move.l  (a2),d5         
        rts
*-----------------------------------------------------------










































































































*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
