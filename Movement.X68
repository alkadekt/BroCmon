*-----------------------------------------------------------
* Title      :  Movement
* Written by :  Andrew Keehan
* Date       :  9/16/21
* Description:  These subroutines help with moving the player
*               sprite as well as the BroCmon sprites
*-----------------------------------------------------------
* registers
ALL_REG                 REG     d0-d7/a0-a6
ISLAND_L_EDGE           EQU     100
ISLAND_R_EDGE           EQU     540
ISLAND_T_EDGE           EQU     100
ISLAND_B_EDGE           EQU     380
*-----------------------------------------------------------
* Player X position: d6
* Player Y position: d7

updatePlayer:
* updates the player's direction of movement and position 
        jsr     checkKeyPress
        btst.l  #24,d1
        bne     left
        btst.l  #16,d1
        bne     right
        btst.l  #8,d1
        bne     up
        btst.l  #0,d1
        bne     down
        rts
     
* check if there's room , if there is then move   
left:
        cmp.l   #ISLAND_L_EDGE+PLAYER_VELOCITY,d6
        ble     dontMove         
        subi.l  #PLAYER_VELOCITY,d6
        rts
right:
        cmp.l   #ISLAND_R_EDGE-PLAYER_WIDTH-PLAYER_VELOCITY,d6
        bge     dontMove
        add.l   #PLAYER_VELOCITY,d6
        rts
up:
        cmp.l   #ISLAND_T_EDGE+PLAYER_HEIGHT+PLAYER_VELOCITY,d7
        ble     dontMove
        subi.l  #PLAYER_VELOCITY,d7
        rts
down:
        cmp.l   #ISLAND_B_EDGE-PLAYER_VELOCITY,d7
        bge     dontMove
        add.l   #PLAYER_VELOCITY,d7
        rts
dontMove:
        rts     

redrawIslandChunk:
* draws a chunk of the island where player current sits
        
        lea     island,a0
        move.l  #PLAYER_WIDTH,d4
        move.l  #PLAYER_HEIGHT,d5
        jsr     drawBMPchunk        
        rts
*-----------------------------------------------------------



































*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
