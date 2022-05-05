*-----------------------------------------------------------
* Title      :  Fight
* Written by :  Andrew Keehan
* Date       :  9/16/21
* Description:  These subroutines handle fighting.
*-----------------------------------------------------------
* trap codes
RECT                    EQU 87
FILL_COLOR              EQU 81

* misc
PROJ_COLOR              EQU $001515E6
PROJ_V                  EQU 8
PROJ_A                  EQU 1
LED_COLOR               EQU $002EDCFF
*-----------------------------------------------------------
fight:
* this subroutine guides the process of the fight
* it uses fixed point to move a projectile and deccelerate it
* it uses a 7 segment led for damage and health scores
* Registers:
* d6 = BroCmon player is using (1-3)
* d7 = Wild BroCmon (1-3)
        
        * first, player chooses which BroCmon they will use
        jsr     chooseFighter
        
        * adjust damage value based on BroCmon types
        jsr     assignDamage
        
        * next, get enemy and fighter choice        
        * check what BroCmon player is using
        * for user's and wild BroCmon, load the attack and defend
        * bitmaps into registers for use later on
        cmp.w   #1,d6
        bne     userNotF
        lea     fire,a1
        lea     d_cyn,a3
        lea     al_cyn,a4
userNotF:
        cmp.w   #2,d6
        bne     userNotG
        lea     grass,a1
        lea     d_chi,a3
        lea     al_chi,a4
userNotG:
        cmp.w   #3,d6
        bne     userNotW
        lea     water,a1
        lea     d_tot,a3
        lea     al_tot,a4
userNotW:      
        
        * check what wild BroCmon is fighting
        cmp.w   #1,d7
        bne     wildNotF
        lea     fire,a2
        lea     d_cyn,a5
        lea     ar_cyn,a6
wildNotF:
        cmp.w   #2,d7
        bne     wildNotG
        lea     grass,a2
        lea     d_chi,a5
        lea     ar_chi,a6
wildNotG:
        cmp.w   #3,d7
        bne     wildNotW
        lea     water,a2
        lea     d_tot,a5
        lea     ar_tot,a6
wildNotW:          
        
        * show versus screen and wait for enter
        jsr     VSscreen
        jsr     enterLoop
        
        * save off which BroCmon we're fighting for later
        lea     eSave,a1
        movem.l d7,(a1)
        
        * Now set some initial information before beginning        
        * set player BroCmon health
        lea     pHealth,a1
        move.l  #HEALTH,(a1)
        
        * set wild BroCmon health
        lea     wHealth,a1
        move.l  #HEALTH,(a1)
        
beginD:             
        * draw their turn screen
        jsr     drawTheirTurn
   
        * set initial wild BroCmon proj pos
        move.l  #100,d6
        move.l  #100,d7
        
        * load the defending battlefield
        jsr     d_Screen
        
        * clear out mash keeper
        clr.l   d1
        
        * clear frame counter
        clr.l   d2
    
        * set wild BroCmon movement at 0 and velocity at 1 pixel
        clr.l   d3
        move.l  #PROJ_V,d4
        
        * set wild BroCmon attack damage
        lea     dam,a1
        move.l  (a1),d5
        
* now begin the fighting loops
* moving BroCmon's proj pos is kept in d6,d7 (x,y)
* damage is kept in d5
* velocity is kept in d4
* movement is kept in d3
* frame counter is kept in d2
* mash keeper is kept in d1
defendLoop:
* shows the player's BroCmon getting attacked and handles input

        * redraw background chunks
        lea     d_field,a0
        jsr     drawFieldChunk
        jsr     redrawConsole
        
        * update wild BroCmon proj position and velocity
        jsr     deccelerate
        jsr     updateWild
        
        * draw wild BroCmon's projectile
        jsr     drawProj
        
        * get player input, then update 7 segments
        jsr     playDef      
        jsr     updateConsole
        
        * check for BroCmon collision, change scenes if needed
        cmp.l   #440,d6
        blt     defendLoop

        * update player health value using damage
        lea     pHealth,a1
        move.l  (a1),d0
        sub.l   d5,d0
        move.l  d0,(a1)        
        * if player's health is now 0 or below, quit to faint screen
        ble     dead       
        
beginA:     
        * draw your turn screen
        jsr     drawYourTurn
        
        * set initial ally BroCmon proj pos
        move.l  #510,d6
        move.l  #100,d7   
        
        * load the attacking battlefield
        jsr     a_Screen
        
        * clear out mash keeper
        clr.l   d1
        
        * clear frame counter
        clr.l   d2
    
        * set ally BroCmon movement at 0 and velocity at 1 pixel
        clr.l   d3
        move.l  #PROJ_V,d4
        
        * set ally BroCmon attack damage
        move.l  #0,d5        
        
attackLoop:
* shows the player's BroCmon attacking and handles input

        * redraw background chunks
        lea     a_field,a0
        jsr     drawFieldChunk
        jsr     redrawConsole
        
        * update ally BroCmon proj position and velocity
        jsr     deccelerate
        jsr     updateAlly
        
        * draw ally BroCmon's projectile
        jsr     drawProj
        
        * get player input, then update 7 segments
        jsr     playAtt      
        jsr     updateConsole
        
        * check for BroCmon collision, change scenes if needed
        cmp.l   #150,d6
        bgt     attackLoop      

        * update wild health value using damage
        lea     wHealth,a1
        move.l  (a1),d0
        sub.l   d5,d0
        move.l  d0,(a1)        
        * if wild health is still above 0, branch back up to their turn
        bgt     beginD  

capture:
* if the wild BroCmon is dead, add it to inventory then return to island
        
        * add wild BroCmon to the inventory
        lea     eSave,a1
        move.l  (a1),d7
        
        * check what wild BroCmon we got, then add it to inventory
        * also load in art for obtain screen
        cmp.w   #1,d7
        bne     capNotF
        jsr     Fstarter
capNotF:
        cmp.w   #2,d7
        bne     capNotG
        jsr     Gstarter 
capNotG:
        cmp.w   #3,d7
        bne     capNotW
        jsr     Wstarter
capNotW:                   
                                                 
        move.l  #1,d6       ; tell the main game loop we had a fight
        rts
        
dead:
* if the ally BroCmon is dead, show fainted screen and return to island
        jsr     drawFaint
        move.l  #1,d6       ; tell the main game loop we had a fight
        rts                
*-----------------------------------------------------------
assignDamage:
* sets the damage value in memory based on who is fighting who
* Fire beats Grass beats Water beats Fire

        lea     dam,a0
        
        * compare the types
        cmp.w   d6,d7
        beq     twins
        blt     wildlesst
        
wildgreatt:
        cmp.w   #2,d7   ; check if it's grass
        bne     wWater  ; if it's greater than but not grass, it's water
        * if it's grass and greater, then ally is fire
        move.l  #DAMAGE_D,(a0)   ; grass will disadvantage on fire ally
        rts
wWater:
        * if wild is water and greater, we need to check ally
        cmp.w   #1,d6
        bne     aGrass
        move.l  #DAMAGE_A,(a0)   ; water will have advantage on ally fire
        rts
aGrass:        
        move.l  #DAMAGE_D,(a0)   ; water will have dis on ally grass
        rts
        
wildlesst:             
        cmp.w   #2,d7   ; check if it's grass
        bne     wFire   ; if it's less than but not grass, it's fire
        * if it's grass and less, then ally is water
        move.l  #DAMAGE_A,(a0)   ; grass will have advantage on water ally
        rts
wFire:  
        * if wild is fire and less, we need to check ally
        cmp.w   #2,d6
        bne     aWater
        move.l  #DAMAGE_A,(a0)   ; fire will have advantage on ally grass
        rts
aWater:
        move.l  #DAMAGE_D,(a0)   ; fire will have dis on ally water
        rts
twins:
* if they're the same, the damage is normal
        move.l  #DAMAGE_N,(a0)    
        rts
*-----------------------------------------------------------
drawFieldChunk:
* draws a chunk of the field
* Registers:
* a0 = field image pointer
* d6 = bottom left X on screen
* d7 = bottom left Y on screen
        
        * save off d1,d2,d3,d4,d5
        lea     fSave,a1
        movem.l d1-d5,(a1)
        
        * chunk width and height are the proj dimensions plus some buffer
        move.l  #PROJ_WIDTH+1,d4
        move.l  #PROJ_HEIGHT+1,d5
        
        * d6 and d7 should already have moving proj position
        
        jsr     drawBMPchunk
        
        * move saved registers back in
        lea     fSave,a1
        movem.l (a1),d1-d5
        rts
*-----------------------------------------------------------
deccelerate:
* lowers the velocity by .125 pixels every 20 frames

        * increment frame counter
        add.l   #1,d2
        
        * check if deccel is needed, branch if not
        cmp.l   #35,d2
        bne     noDeccel
        * check if vel is already 0
        cmp.l   #0,d4
        beq     noDeccel
        * decrement velocity
        subi.l  #1,d4       ; lower the velocity 0.125 px
        clr.l   d2
        
noDeccel:        
        rts
*-----------------------------------------------------------
updateWild:
* updates the position of the attacking wild BroCmon's proj
* velocity begins at 1 pixel,
* but can be reduced essentially 0.125 pixels 

        * save off d2 and the others
        lea     fSave,a1
        movem.l d1-d5,(a1)
        
        * bring movement back to 0 if needed
        cmp.l   #8,d3       ; check that it isn't 1 before adding
        blt     cont
        clr.l   d3
cont:
        
        * add velocity to the movement
        add.l   d4,d3
        
        * copy movement to a new reg and shift
        move.l  d3,d2
        lsr.l   #3,d2      ; divide by 8
        
        * add shifted movement to positions
        add.l   d2,d6
        add.l   d2,d6
        add.l   d2,d6
        add.l   d2,d7
        add.l   d2,d7
        
        * move saved registers back in, but only d1 and d2
        * because the change in movement and vel need to carry through
        lea     fSave,a1
        movem.l (a1),d1-d2
        rts   
*-----------------------------------------------------------
updateAlly:
* updates the position of the attacking ally BroCmon's proj
* velocity begins at 1 pixel,
* but can be reduced essentially 0.125 pixels 

        * save off d2 and the others
        lea     fSave,a1
        movem.l d1-d5,(a1)
        
        * bring movement back to 0 if needed
        cmp.l   #8,d3       ; check that it isn't 1 before adding
        blt     conti
        clr.l   d3
conti:
        
        * add velocity to the movement
        add.l   d4,d3
        
        * copy movement to a new reg and shift
        move.l  d3,d2
        lsr.l   #3,d2      ; divide by 8
        
        * subtract/add shifted movement to positions
        sub.l   d2,d6
        sub.l   d2,d6
        sub.l   d2,d6
        add.l   d2,d7
        add.l   d2,d7
        
        * move saved registers back in, but only d1 and d2
        * because the change in movement and vel need to carry through
        lea     fSave,a1
        movem.l (a1),d1-d2
        rts 
        rts        
*-----------------------------------------------------------
drawProj:
* draws the projectile at a position
* Registers:
* d6 = left X of projectile
* d7 = bottom Y of projectile

        * save off registers
        lea     fSave,a1
        movem.l d1-d5,(a1)

        * set pen color
        move.l  #PROJ_COLOR,d1
        move.l  #PEN_COLOR,d0
        trap    #15
        
        * set fill color
        move.l  #PROJ_COLOR,d1
        move.l  #FILL_COLOR,d0
        trap    #15
        
        * draw the projectile
        move.l  d6,d1
        move.l  d6,d3
        add.l   #PROJ_WIDTH,d3
        move.l  d7,d4
        move.l  d7,d2
        subi.l  #PROJ_HEIGHT,d2
        move.l  #RECT,d0
        trap    #15
        
        * move saved registers back in
        lea     fSave,a1
        movem.l (a1),d1-d5      
          
        rts
*-----------------------------------------------------------
playDef:
* updates incoming damage as player hits down arrow

        * save off registers
        lea     fSave,a1
        movem.l d1-d5,(a1)
        
        jsr     checkKeyPress
        btst.l  #0,d1           ; check for down arrow
        beq     nopress         ; branch if not pressed
        
        * move saved registers back in
        lea     fSave,a1
        movem.l (a1),d1-d5  
        
        * check if button was just unpressed
        * this prevents player from just holding the button
        * to lower the damage score
        cmp.l   #0,d1
        bne     keepit
        
        * check if incoming damage is already 0
        cmp.l   #0,d5
        beq     keepit
        
        subi.l  #1,d5           ; subtract 1 from damage
        
keepit:        
        move.l  #1,d1           ; mark in mash keeper that it's pressed
        rts          
        
nopress:
        clr.l   d1              ; mark in mash keeper that it's unpressed
        rts              
*-----------------------------------------------------------
playAtt:
* updates damage toward wild as player hits up arrow

        * save off registers
        lea     fSave,a1
        movem.l d1-d5,(a1)
        
        jsr     checkKeyPress
        btst.l  #8,d1           ; check for down arrow
        beq     nopres         ; branch if not pressed
        
        * move saved registers back in
        lea     fSave,a1
        movem.l (a1),d1-d5  
        
        * check if button was just unpressed
        * this prevents player from just holding the button
        * to increase the damage score
        cmp.l   #0,d1
        bne     keep
        
        * check if incoming damage is already 99
        cmp.l   #99,d5
        beq     keep
        
        add.l   #1,d5           ; add 1 to damage
        
keep:        
        move.l  #1,d1           ; mark in mash keeper that it's pressed
        rts          
        
nopres:
        clr.l   d1              ; mark in mash keeper that it's unpressed
        rts 
*-----------------------------------------------------------
drawYourTurn:
* draws the "your turn" message to screen
        jsr     clearScreen
        lea     u_turn,a0
        move.l  #270,d3     ; bottom left X on screen
        move.l  #253,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        jsr     swapBuffers
        rts
*-----------------------------------------------------------        
drawTheirTurn:
* draws the "their turn" message to screen
        jsr     clearScreen
        lea     t_turn,a0
        move.l  #264,d3     ; bottom left X on screen
        move.l  #253,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        jsr     swapBuffers
        rts
*-----------------------------------------------------------
VSscreen:
* draws opponents on screen with player's BroCmon on the left
* Registers:
* a1 = player's BroCmon image pointer
* a2 = wild BroCmon image pointer  

        jsr     clearScreen
        
        * draw player's BroCmon
        move.l  a1,a0
        move.l  #188,d3     ; bottom left X on screen
        move.l  #290,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw wild BroCmon
        move.l  a2,a0
        move.l  #352,d3     ; bottom left X on screen
        move.l  #290,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw VS sign
        lea     versus,a0
        move.l  #288,d3     ; bottom left X on screen
        move.l  #272,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw press enter 
        lea     r_arrow,a0
        move.l  #280,d3     ; bottom left X on screen
        move.l  #300,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image        
        
        jsr     swapBuffers        
        rts       
*-----------------------------------------------------------        
d_Screen:
* draws the screen for defending against an attack
        
        jsr     clearScreen
        
        * draw background
        lea     d_field,a0
        move.l  #0,d3       ; bottom left X on screen
        move.l  #480,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw player's BroCmon
        move.l  a3,a0
        move.l  #450,d3     ; bottom left X on screen
        move.l  #360,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw wild BroCmon
        move.l  a6,a0
        move.l  #0,d3       ; bottom left X on screen
        move.l  #100,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw health counts
        jsr     updateHealth
        
        jsr     swapBuffers        
        rts
*-----------------------------------------------------------
a_Screen:
* draws the screen for attacking the wild BroCmon
        
        jsr     clearScreen
        
        * draw background
        lea     a_field,a0
        move.l  #0,d3     ; bottom left X on screen
        move.l  #480,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw player's BroCmon
        move.l  a4,a0
        move.l  #540,d3     ; bottom left X on screen
        move.l  #100,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw wild BroCmon
        move.l  a5,a0
        move.l  #90,d3      ; bottom left X on screen
        move.l  #360,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw health counts
        jsr     updateHealth
        
        jsr     swapBuffers        
        rts
*-----------------------------------------------------------
drawFaint:
* shows the fainted message to the screen and waits for enter

        jsr     clearScreen
        
        * draw fainted message
        lea     fainted,a0
        move.l  #170,d3     ; bottom left X on screen
        move.l  #265,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image   
        
        * draw enter sign
        lea     r_arrow,a0
        move.l  #280,d3     ; bottom left X on screen
        move.l  #320,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        jsr     swapBuffers        
        jsr     enterLoop
        rts     
*-----------------------------------------------------------
obtainScreen:  
* shows a congrats message with the BroCmon underneath, waits for enter
* Registers:
* a1 = congrats image pointer
* a2 = BroCmon image pointer

        jsr     clearScreen
        
        * draw congrats message
        move.l  a1,a0
        move.l  #180,d3     ; bottom left X on screen
        move.l  #190,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw obtained BroCmon
        move.l  a2,a0
        move.l  #270,d3     ; bottom left X on screen
        move.l  #290,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * draw enter sign
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
