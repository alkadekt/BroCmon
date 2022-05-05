*-----------------------------------------------------------
* Title      : Interactive Assembly Project: BroCmon
* Written by : Andrew Keehan
* Date       : 9/27/21
* Description: This program runs BroCmon, the game
*-----------------------------------------------------------
* trap codes
DRAWING_MODE            EQU 92
DOUBLE_BUFFERED_MODE    EQU 17
DELAY_FRAME             EQU 23
REPAINT_SCREEN          EQU 94
CLEAR_SCREEN            EQU 11
CLEAR_SCREEN_MAGIC_VAL  EQU $FF00
KEY_STATE               EQU 19

* miscellaneous
FRAME_DELAY_TIME        EQU 1
ALL_REG                 REG d0-d7/a0-a6
ENTER                   EQU $D

* screen dimensions
SCREEN_WIDTH            EQU 640
SCREEN_HEIGHT           EQU 480

* player attributes
PLAYER_WIDTH            EQU 32
PLAYER_HEIGHT           EQU 32
PLAYER_START_X          EQU 100
PLAYER_START_Y          EQU 380
PLAYER_VELOCITY         EQU $2

* brocmon attributes
PROJ_WIDTH              EQU 32
PROJ_HEIGHT             EQU 32
DAMAGE_N                EQU 20
DAMAGE_A                EQU 30
DAMAGE_D                EQU 10
HEALTH                  EQU 30
*-----------------------------------------------------------
        
START   ORG     $1000      
     
        * set double buffered mode
        move.l  #DRAWING_MODE,d0
        move.l  #DOUBLE_BUFFERED_MODE,d1
        trap    #15
        
gameStart:        
        * draw loading and logo icons, then wait for player to enter
        jsr     drawLoad
        jsr     drawLogo
        jsr     enterLoop
        
        * have player choose a starting BroCmon
        jsr     chooseStarter

init:        
        * load the outside scene, which includes player sprite
        jsr     drawLoad
        jsr     initOutside

outsideLoop:
* the loop for walking on the island and encountering BroCmon in grass       

        * redraw background chunk where player used to be
        jsr     redrawIslandChunk     
      
        * get player input, then update player location        
        jsr     updatePlayer
        * draw player
        jsr     drawPlayer
        jsr     swapBuffers
     
        * check for grass collision, change scenes if needed
        jsr     encounter        
        
        * check to see if we had a fight, if so reload this scene
        cmp.l   #1,d6
        beq     init
   
        * check to see if all BroCmon have been obtained
        * if not keep doing outside loop
        jsr     checkInventory
        cmp.l   #1,d7
        bne     outsideLoop
        
        * show the winner screen
        jsr     winScreen          
                
*-----------------------------------------------------------
*                       SUBROUTINES
*-----------------------------------------------------------

        * file includes        
        INCLUDE     "DrawWholeBitmap.X68"
        INCLUDE     "DrawBitmapChunk.X68"
        INCLUDE     "BroCmonOptions.X68"
        INCLUDE     "Fight.X68"
        INCLUDE     "Movement.X68"
        INCLUDE     "Encounter.X68"
        INCLUDE     "7seg.X68"
*-----------------------------------------------------------        
clearScreen:
* clears entire screen
        move.l  #CLEAR_SCREEN,d0
       	move.l  #CLEAR_SCREEN_MAGIC_VAL,d1
       	TRAP    #15
	    rts
*-----------------------------------------------------------
swapBuffers:
* swaps hidden screen to front
	    move.l  #REPAINT_SCREEN,d0
      	trap    #15
	    rts
*-----------------------------------------------------------	    
checkKeyDown:
* returns what key was pressed in lower word of d1
        clr.l   d1
        move.l  #KEY_STATE,d0
        trap    #15	    
        rts
*-----------------------------------------------------------        
checkKeyUp:
* returns what key was up in lower word of d1        
        clr.l   d1
        move.l  #KEY_STATE,d0
        trap    #15	    
        swap    d1
        rts
*-----------------------------------------------------------        
checkKeyPress:
* returns if an arrow key is being pressed
        move.l  #KEY_STATE,d0
        clr.l   d1
        move.b  #LEFT_ARROW,d1
        lsl.l   #8,d1
        move.b  #RIGHT_ARROW,d1
        lsl.l   #8,d1
        move.b  #UP_ARROW,d1
        lsl.l   #8,d1
        move.b  #DOWN_ARROW,d1
        trap    #15
        rts
*-----------------------------------------------------------        
enterLoop:
* waits for player to hit enter, then quits loop
        jsr     checkKeyDown
        cmp.b   #ENTER,d1
        bne     enterLoop
        rts
*-----------------------------------------------------------
checkInventory:
* checks to see if all BroCmon have been obtained
* passes 1 into d7 if they have
        lea     inventory,a0
        move.l  (a0),d4
        btst    #24,d4
        bne     haveF         ; branch ahead if they have fire
        rts
haveF:    
        btst    #16,d4        
        bne     haveG         ; branch ahead if they have grass
        rts
haveG:
        btst    #8,d4
        bne     haveW         ; branch ahead if they have water
        rts
haveW:
        move.l  #1,d7
        rts    
*-----------------------------------------------------------    
winScreen:
* shows the winner screen
        jsr     clearScreen
        lea     winner,a0  ; load in the image        
        move.l  #180,d3     ; bottom left X on screen
        move.l  #278,d2     ; bottom left Y on screen
        
        jsr     drawWholeBMP    ; draw the image
        jsr     swapBuffers        
        SIMHALT             ; halt simulator
*-----------------------------------------------------------    
initOutside:
* loads the outside background with player in starting location
* puts starting coords in d6/d7
        jsr     drawIsland      ; draw the background
        * set initial player location
        move.l  #PLAYER_START_X,d6
        move.l  #PLAYER_START_Y,d7 
        jsr     drawPlayer      ; draw the player
        jsr     swapBuffers       
        rts
*-----------------------------------------------------------        
drawLoad:
* draws the loading icon to the screen
        jsr     clearScreen
        lea     loading,a0  ; load in the image
        move.l  #270,d3     ; bottom left X on screen
        move.l  #227,d2     ; bottom left Y on screen
        
        jsr     drawWholeBMP    ; draw the image
        jsr     swapBuffers
        rts
*-----------------------------------------------------------        
drawLogo:
* draws the logo to the screen
        jsr     clearScreen
        lea     logo,a0     ; load in the image
        move.l  #200,d3     ; bottom left X on screen
        move.l  #260,d2     ; bottom left Y on screen
        
        jsr     drawWholeBMP    ; draw the image
        jsr     drawEnter       ; draw instruction underneath
        jsr     swapBuffers
        rts
*-----------------------------------------------------------        
drawEnter:
* draws the right arrow symbol to screen
        lea     r_arrow,a0  ; load in the image
        move.l  #260,d3     ; bottom left X on screen
        move.l  #280,d2     ; bottom left Y on screen
        
        jsr     drawWholeBMP    ; draw the image
        rts
*-----------------------------------------------------------        
drawIsland:
* draws the outside to the screen
        jsr     clearScreen
        lea     island,a0   ; load in the image
        move.l  #0,d3       ; bottom left X on screen
        move.l  #480,d2     ; bottom left Y on screen
        
        jsr     drawWholeBMP    ; draw the image
        rts
*-----------------------------------------------------------        
drawPlayer:
* draws the player's movement
        lea     player1,a0  ; load in the image
        move.l  d6,d3     ; bottom left X on screen
        move.l  d7,d2     ; bottom left Y on screen
        
        jsr     drawWholeBMP    ; draw the image
        rts
*-----------------------------------------------------------        
        * program shouldn't reach this far but it does, halt sim
        SIMHALT

*-----------------------------------------------------------
*                         POINTERS        
*-----------------------------------------------------------
* declared memory
* game info
inventory   dc.l    0   ; value determines the BroCmon player has
tmr         dc.l    20  ; how many frames in grass before encounter
pHealth     ds.l    1   ; player's brocmon health
wHealth     ds.l    1   ; wild brocmon health
dam         ds.l    1   ; damage amount
* saved registers
eSave       ds.l    1   ; holds which wild brocmon is being fought
fSave       ds.l    5   ; where to save register when fighting
addSave     ds.l    2   ; holds two addresses
ledSave     ds.l    7   ; where to save during led draw
inSave      ds.l    1   ; holds damage during led draw
bmpSave     ds.l    11  ; where to save register when drawing whole bmp  
chunkSave   ds.l    11   ; where to save register when drawing bmp chunk 
* art asset pointers
loading:    INCBIN  "loading.bmp"
logo:       INCBIN  "logo.bmp"
r_arrow:    INCBIN  "right_arrow.bmp"
u_turn      INCBIN  "Uturn.bmp"
t_turn      INCBIN  "Tturn.bmp"
choose      INCBIN  "choose.bmp"
versus      INCBIN  "versus.bmp"
fainted:    INCBIN  "fainted.bmp"
f_congrats: INCBIN  "Fcongrats.bmp"
g_congrats: INCBIN  "Gcongrats.bmp"
w_congrats: INCBIN  "Wcongrats.bmp"
f_encount:  INCBIN  "Fencounter.bmp"
g_encount:  INCBIN  "Gencounter.bmp"
w_encount:  INCBIN  "Wencounter.bmp"
fire:       INCBIN  "cyndaquil.bmp"
grass:      INCBIN  "chicorita.bmp"
water:      INCBIN  "totodile.bmp"
f_option:   INCBIN  "cyndaquil_option.bmp"
g_option:   INCBIN  "chicorita_option.bmp"
w_option:   INCBIN  "totodile_option.bmp"
d_cyn       INCBIN  "Dcyndaquil.bmp"
d_chi       INCBIN  "Dchicorita.bmp"
d_tot       INCBIN  "Dtotodile.bmp"
ar_cyn      INCBIN  "ARcyndaquil.bmp"
ar_chi      INCBIN  "ARchicorita.bmp"
ar_tot      INCBIN  "ARtotodile.bmp"
al_cyn      INCBIN  "ALcyndaquil.bmp"
al_chi      INCBIN  "ALchicorita.bmp"
al_tot      INCBIN  "ALtotodile.bmp"
island:     INCBIN  "island.bmp"
d_field:    INCBIN  "d_field.bmp"
a_field:    INCBIN  "a_field.bmp"
player1:    INCBIN  "player1.bmp"
winner:     INCBIN  "winner.bmp"
* segment tables (A-G)
* console segments
segTabL
A           dc.l    280,390,315,400
B           dc.l    305,390,315,430
C           dc.l    305,430,315,470
D           dc.l    280,460,315,470
E           dc.l    280,430,290,470
F           dc.l    280,390,290,430
G           dc.l    280,425,315,435
segTabR        
AR          dc.l    325,390,360,400
BR          dc.l    350,390,360,430
CR          dc.l    350,430,360,470
DR          dc.l    325,460,360,470
ER          dc.l    325,430,335,470
FR          dc.l    325,390,335,430
GR          dc.l    325,425,360,435
* wild BroCmon segments
WsegL
WA           dc.l   75,390,110,400
WB           dc.l   100,390,110,430
WC           dc.l   100,430,110,470
WD           dc.l   75,460,110,470
WilE         dc.l   75,430,85,470
WF           dc.l   75,390,85,430
WG           dc.l   75,425,110,435
WsegR        
WAR          dc.l   120,390,155,400
WBR          dc.l   145,390,155,430
WCR          dc.l   145,430,155,470
WDR          dc.l   120,460,155,470
WER          dc.l   120,430,130,470
WFR          dc.l   120,390,130,430
WGR          dc.l   120,425,155,435
* player's (ally) BroCmon segments
PsegL
PA           dc.l   485,390,520,400
PB           dc.l   510,390,520,430
PC           dc.l   510,430,520,470
PD           dc.l   485,460,520,470
PE           dc.l   485,430,495,470
PF           dc.l   485,390,495,430
PG           dc.l   485,425,520,435
PsegR        
PAR          dc.l   530,390,565,400
PBR          dc.l   555,390,565,430
PCR          dc.l   555,430,565,470
PDR          dc.l   530,460,565,470
PER          dc.l   530,430,540,470
PFR          dc.l   530,390,540,430
PGR          dc.l   530,425,565,435
* bitmask table (0-9)
maskTab
            dc.b    126,48,109,121,51,91,95,112,127,115  
            
        END    START






















































































*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
