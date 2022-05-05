*-----------------------------------------------------------
* Title      :  BroCmon Options
* Written by :  Andrew Keehan
* Date       :  9/16/21
* Description:  This program handles BroCmon options. It takes 
*               shows options and gets a player's selection
*-----------------------------------------------------------
* key codes
LEFT_ARROW              EQU     $25
UP_ARROW                EQU     $26
RIGHT_ARROW             EQU     $27
DOWN_ARROW              EQU     $28
*-----------------------------------------------------------        
chooseStarter:
* draws all BroCmon options and gets player selection
        jsr     clearScreen
        jsr     drawFoption
        jsr     drawGoption
        jsr     drawWoption
        jsr     swapBuffers
        
        jsr     selection      
        rts
*-----------------------------------------------------------        
chooseFighter:
* draws available BroCmon options and gets player selection
        
        jsr     clearScreen
        
        lea     choose,a0
        move.l  #170,d3     ; bottom left X on screen
        move.l  #150,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        
        * check player inventory to see which BroCmon they have
        * then print the ones they have to screen
        lea     inventory,a0
        move.l  (a0),d4
        btst    #24,d4
        beq     noF         ; branch ahead if they dont have fire
        jsr     drawFoption
noF:    
        btst    #16,d4        
        beq     noG         ; branch ahead if they dont have grass
        jsr     drawGoption
noG:
        btst    #8,d4
        beq     noW         ; branch ahead if they dont have water
        jsr     drawWoption
noW:
        jsr     swapBuffers
        
fighterLoop:
        * now loop to get player choice
        jsr     checkKeyPress
        btst.l  #24,d1      ; check for left arrow
        bne     Ffighter
        btst.l  #16,d1      ; check for right arrow
        bne     Wfighter
        btst.l  #8,d1       ; check for up arrow
        beq     fighterLoop  
        
Gfighter:
* verify that they have a grass BroCmon, if not go back
        btst    #16,d4      ; inventory still in d4       
        beq     fighterLoop
        
        * if they do have it, set info for player BroCmon
        move.l  #2,d6        
        rts        
Ffighter:
* verify that they have a fire BroCmon, if not go back
        btst    #24,d4      ; inventory still in d4       
        beq     fighterLoop
        
        * if they do have it, set info for player BroCmon
        move.l  #1,d6         
        rts
Wfighter:        
* verify that they have a water BroCmon, if not go back
        btst    #8,d4      ; inventory still in d4       
        beq     fighterLoop
        
        * if they do have it, set info for player BroCmon
        move.l  #3,d6 
        rts        
*-----------------------------------------------------------        
selection:
* gets player input for selection, then changes mem value        
        
        * check key press, then test register bits for input
        jsr     checkKeyPress
        btst.l  #24,d1      ; check for left arrow
        bne     Fstarter
        btst.l  #16,d1      ; check for right arrow
        bne     Wstarter
        btst.l  #8,d1       ; check for up arrow
        beq     selection

Gstarter:
* if they chose grass, update mem value accordingly
        lea     g_congrats,a1
        lea     grass,a2
        jsr     obtainScreen
        lea     inventory,a0
        move.l  (a0),d0
        bset    #16,d0
        move.l  d0,(a0)
        rts           
Fstarter:
* if they chose fire, update mem value accordingly
        lea     f_congrats,a1
        lea     fire,a2
        jsr     obtainScreen
        lea     inventory,a0
        move.l  (a0),d0
        bset    #24,d0
        move.l  d0,(a0)
        rts   
Wstarter:
* if they chose water, update mem value accordingly
        lea     w_congrats,a1
        lea     water,a2
        jsr     obtainScreen
        lea     inventory,a0
        move.l  (a0),d0
        bset    #8,d0
        move.l  d0,(a0)
        rts
*-----------------------------------------------------------        
drawFoption:
* draws the fire option to screen
        lea     f_option,a0 ; load in the image
        move.l  #170,d3     ; bottom left X on screen
        move.l  #306,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        rts
*-----------------------------------------------------------        
drawGoption:
* draws the grass option to screen
        lea     g_option,a0 ; load in the image
        move.l  #270,d3     ; bottom left X on screen
        move.l  #306,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        rts
*-----------------------------------------------------------        
drawWoption:
* draws the water option to screen
        lea     w_option,a0 ; load in the image
        move.l  #370,d3     ; bottom left X on screen
        move.l  #306,d2     ; bottom left Y on screen        
        jsr     drawWholeBMP    ; draw the image
        rts     

*-----------------------------------------------------------























































*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
