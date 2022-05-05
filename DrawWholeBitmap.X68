*-----------------------------------------------------------
* Title      :  DrawWholeBitmap
* Written by :  Andrew Keehan
* Date       :  9/16/21
* Description:  This program takes a pointer to a .bmp file,
*               and the top left corner of screen section,
*               and displays that bitmap to the screen
*-----------------------------------------------------------
PEN_COLOR               EQU     80
DRAW_PIXEL              EQU     82
SAVED_REG               REG     d0-d1/d4-d7/a2-a6
*-----------------------------------------------------------
drawWholeBMP:
* draws an entire bitmap, rather than a chunk of one
* Registers:
* a0 = image pointer
* d2 = bottom left Y on screen
* d3 = bottom left X on screen

        * save off anything that isn't an input
        lea     bmpSave,a1
        movem.l SAVED_REG,(a1)

        * get header size
        add.l   #14,a0      ; get to DIB header size  
        move.l  (a0)+,d0    ; get DIB header size
        swap    d0          ; swap
        ror.w   #8,d0       ; roll right
        
        * get image width
        move.l  (a0)+,d4    ; get the image width
        swap    d4          ; swap
        ror.w   #8,d4       ; roll right
        
        * get image height
        move.l  (a0)+,d5    ; get the image height
        swap    d5          ; swap
        ror.w   #8,d5       ; roll right
        
        subi.l  #12,d0      ; subtract 12bytes from header size
        add.l   d0,a0       ; advance to start of pixel data
        
        clr.l   d6          ; clear out column counter
        jsr     draw24Loop  ; begin drawing pixel data
        rts      
        
draw24Loop:
* subroutine to draw pixel data to the screen at a specified location
* Registers:
* a0 = start of pixel data      (input)
* d2 = bottom left Y on screen  (input)
* d3 = bottom left X on screen  (input)
* d4 = image width              (input)
* d5 = image height             (input)
* d6 = column counter

        * get and set pen color
        clr.l   d1          ; clear out RGB register
        move.b  (a0)+,d1    ; get B value
        lsl.l   #8,d1       ; bit shift left
        move.b  (a0)+,d1    ; get G value
        lsl.l   #8,d1       ; bit shift left
        move.b  (a0)+,d1    ; get R value
        move.l  #PEN_COLOR,d0
        trap    #15         ; set pen color
        
        * get output location then draw
        cmpi.l  #$0000F2FF,d1   ; compare to green screen color
        beq     greenScreen ; don't draw if it's the green screen        
        clr.l   d1
        add.l   d3,d1       ; add in bottom left X on screen
        add.l   d6,d1       ; add in column counter
        move.l  #DRAW_PIXEL,d0
        trap    #15         ; draw pixel
greenScreen:
        
        * check if done with row, branch if not
        add.l   #1,d6       ; increment column counter
        cmp.l   d6,d4       ; compare column counter to image width
        bne     draw24Loop
        
        * reset X output, adjust Y output
        clr.l   d6          ; clear column counter
        subi.l  #1,d2       ; subtract 1 from bottom left Y on screen
        
        * check if done with image, branch if not
        subi.l  #1,d5       ; subtract 1 from image height
        bne     draw24Loop  ; branch if we didn't hit 0

        * move register saves back in
        movem.l (a1),SAVED_REG
        rts






























*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
