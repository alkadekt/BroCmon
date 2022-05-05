*-----------------------------------------------------------
* Title      :  DrawBitmapChunk
* Written by :  Andrew Keehan
* Date       :  9/16/21
* Description:  This program takes a pointer to a .bmp file,
*               the top left corner of a bitmap chunk, 
*               the width and height of the bitmap chunk,
*               and the top left corner of screen section,
*               and displays that bitmap chunk to the screen
*               !!!CHUNK MUST FIT INSIDE IMAGE DIMENSIONS!!!
*-----------------------------------------------------------
SAVED_CHUNK_REG                 REG     d0-d3
*-----------------------------------------------------------
drawBMPchunk:
* draws a chunk of a 24 bit depth bitmap
* Registers:
* a0 = image pointer
* d4 = chunk width
* d5 = chunk height
* d6 = bottom left X on screen
* d7 = bottom left Y on screen

        * save off anything that isn't an input
        lea     chunkSave,a1
        movem.l SAVED_REG,(a1)        
        
        * get header size
        add.l   #14,a0      ; get to DIB header size        
        move.l  (a0)+,d0    ; get DIB header size
        swap    d0          ; swap
        ror.w   #8,d0       ; roll right
        
        * move to pixel data
        subi.l  #4,d0       ; subtract 4 bytes from header size
        add.l   d0,a0       ; advance to start of pixel data      

        * get num rows to chunk
        move.l  #SCREEN_HEIGHT,d0        
        sub.l   d7,d0       ; subtract chunk bottom left Y from img height
        
        * multiply result by image width
        mulu    #SCREEN_WIDTH,d0 
        move.l  d0,d1       ; save off result so we can add it twice more
        add.l   d1,d0       ; add it two times (to account for RGB)
        add.l   d1,d0
        
        * move to data row for chunk pixel data        
        add.l   d0,a0
        
        * adjust for X coord of chunk
        add.l   d6,a0       ; add bottom left X of chunk to pointer
        add.l   d6,a0
        add.l   d6,a0
        * a0 is now at start of chunk data
        
        * set row output and column counter
        move.l  d7,d2       ; move bottom left Y on screen into row output
        clr.l   d3          ; set column counter to 0        

displayLoop:
* subroutine to draw pixel data to the screen at a specified location
* Registers:
* a0 = start of pixel data      (input)
* d2 = row output
* d3 = column counter
* d4 = chunk width              (input)
* d5 = chunk height             (input)
* d6 = bottom left X on screen  (input)
* d7 = bottom left Y on screen  (input)

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
        clr.l   d1
        add.l   d6,d1       ; add in bottom left X on screen
        add.l   d3,d1       ; add in column counter
        move.l  #DRAW_PIXEL,d0
        trap    #15         ; draw pixel
        
        * check if done with row, branch if not
        add.l   #1,d3       ; increment column counter
        cmp.l   d3,d4       ; compare column counter to chunk width
        bne     displayLoop
        
        * reset column counter
        clr.l   d3          ; set column counter to 0
        
        * move the data pointer to the next chunk row
        move.l  #SCREEN_WIDTH,d1    ; get image width
        sub.l   d4,d1       ; subtract chunk width
        add.l   d1,a0       ; add to data pointer 3 times for RGB
        add.l   d1,a0
        add.l   d1,a0
        
        * check if done with image, branch if not
        subi.l  #1,d2       ; decrement the row output
        move.l  d7,d0       ; get bottom edge
        sub.l   d5,d0       ; subtract chunk height
        cmp.l   d2,d0       ; compare row output to top edge
        bne     displayLoop
        
        * move register saves back in
        movem.l (a1),SAVED_CHUNK_REG
        rts






























*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
