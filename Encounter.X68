*-----------------------------------------------------------
* Title      :  Encounter
* Written by :  Andrew Keehan
* Date       :  9/16/21
* Description:  These subroutines help with handling player
*               encounters with wild BroCmon in the grass
*-----------------------------------------------------------
* trap codes
GET_TIME                EQU     8

* registers
GRASS_L_EDGE            EQU     150
GRASS_R_EDGE            EQU     350
GRASS_T_EDGE            EQU     130
GRASS_B_EDGE            EQU     250
*-----------------------------------------------------------
* Player X position: d6
* Player Y position: d7
*-----------------------------------------------------------
encounter:
* checks for collision and handles encounter

        * check if player is within the grass edges
        cmp.l   #GRASS_L_EDGE,d6
        blt     notInGrass
        cmp.l   #GRASS_R_EDGE,d6
        bgt     notInGrass
        cmp.l   #GRASS_T_EDGE,d7
        blt     notInGrass
        cmp.l   #GRASS_B_EDGE,d7
        bgt     notInGrass
        
        * if they are, do a random check
        * use the timer to check for encounter every 20 frames
        lea     tmr,a0
        move.l  (a0),d0
        subi.l  #1,d0       ; decrement the timer
        beq     itsTime
        move.l  d0,(a0)
        rts
        
itsTime:
        move.l  #20,(a0)    ; reset the timer
        
        * if the random number is less than a specific val, branch
        jsr     getRandom
        cmp.l   #85,d5
        blt     FE
        cmp.l   #170,d5
        blt     GE
        cmp.l   #255,d5
        blt     WE
        
notInGrass:
* return if the player isn't in the grass        
        rts

FE:
* encounter a wild fire BroCmon
        * set info for wild BroCmon for fight input
        move.l  #1,d7
        * display encounter screen
        lea     f_encount,a1
        lea     fire,a2
        jsr     encounterScreen
        jsr     fight
        rts
GE:
* encounter a wild grass BroCmon
        * set info for wild BroCmon for fight input
        move.l  #2,d7
        * display encounter screen        
        lea     g_encount,a1
        lea     grass,a2
        jsr     encounterScreen
        jsr     fight
        rts
WE:
* encounter a wild water BroCmon
        * set info for wild BroCmon for fight input
        move.l  #3,d7
        * display encounter screen        
        lea     w_encount,a1
        lea     water,a2
        jsr     encounterScreen
        jsr     fight
        rts                
*-----------------------------------------------------------                
getRandom:
* gets a random number and puts it in d5
        * get time in hundreths of a second since midnight in d1        
        move.l  #GET_TIME,d0
        trap    #15
        * shift data back and forth to get higher place digits of time
        lsl.l   #8,d1
        lsl.l   #8,d1
        lsl.l   #4,d1
        lsr.l   #8,d1
        lsr.l   #8,d1
        lsr.l   #8,d1
        move.l  d1,d5
        rts
*-----------------------------------------------------------                        
encounterFire:
* shows an encounter message with the fire BroCmon underneath
        jsr     clearScreen
        lea     f_encount,a0
        move.l  #200,d3     ; bottom left X on screen
        move.l  #190,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        lea     fire,a0
        move.l  #270,d3     ; bottom left X on screen
        move.l  #290,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image

        lea     r_arrow,a0
        move.l  #280,d3     ; bottom left X on screen
        move.l  #320,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        jsr     swapBuffers

        jsr     enterLoop        
        rts
*-----------------------------------------------------------        
encounterGrass:
* shows an encounter message with the grass BroCmon underneath
        jsr     clearScreen
        lea     g_encount,a0
        move.l  #200,d3     ; bottom left X on screen
        move.l  #190,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        lea     grass,a0
        move.l  #270,d3     ; bottom left X on screen
        move.l  #290,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image

        lea     r_arrow,a0
        move.l  #280,d3     ; bottom left X on screen
        move.l  #320,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        jsr     swapBuffers

        jsr     enterLoop        
        rts        
*-----------------------------------------------------------        
encounterWater:
* shows an encounter message with the grass BroCmon underneath
        jsr     clearScreen
        lea     w_encount,a0
        move.l  #200,d3     ; bottom left X on screen
        move.l  #190,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        lea     water,a0
        move.l  #270,d3     ; bottom left X on screen
        move.l  #290,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image

        lea     r_arrow,a0
        move.l  #280,d3     ; bottom left X on screen
        move.l  #320,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        jsr     swapBuffers

        jsr     enterLoop        
        rts
*-----------------------------------------------------------
encounterScreen:
* shows the BroCmon encountered with an enterloop
* Registers:
* a1 = message image pointer    (input)
* a2 = BroCmon image pointer    (input)
        jsr     clearScreen
        move.l  a1,a0
        move.l  #200,d3     ; bottom left X on screen
        move.l  #190,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        move.l  a2,a0
        move.l  #270,d3     ; bottom left X on screen
        move.l  #290,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image

        lea     r_arrow,a0
        move.l  #280,d3     ; bottom left X on screen
        move.l  #320,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        jsr     swapBuffers

        jsr     enterLoop        
        rts         
*-----------------------------------------------------------












































































*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
