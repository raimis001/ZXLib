#include "../helper.bas"
#include "../hrprint.bas"

DIM ch_posY as ubyte = 2*8
DIM ch_posX as ubyte = 2*8
DIM ch_speed as ubyte = 1

CONST attr as ubyte = BLACK + WHITE * 8
CONST attrBlank as ubyte = WHITE + WHITE * 8
'CONST attr as ubyte = WHITE + BLACK * 8

const scrH as ubyte = (SCREEN_HEIGHT - 2) * 8
const scrW as ubyte = (SCREEN_WIDTH - 1) * 8

DIM field(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1) as ubyte

DIM moveX as byte = 0
DIM moveY as byte = 0

DIM key as string

DIM hasKey as BOOLEAN = FALSE

SUB Init()
    DIM x as ubyte
    DIM y as ubyte
    FOR y = 0 TO SCREEN_HEIGHT - 1
        FOR x = 0 TO SCREEN_WIDTH - 1
            field(x,y) = 0
        NEXT x
    NEXT y
    PlaceItems(1, 1)
    PlaceItems(2, 1)
END SUB

SUB PlaceItems(itemType as ubyte, itemCount as ubyte)
    DIM rx as ubyte
    DIM ry as ubyte
    DIM placed as ubyte = 0

    DO
        rx = INT(RND * SCREEN_WIDTH )
        ry = INT(RND * SCREEN_HEIGHT - 2) + 1    

        IF field(rx, ry) = 0 THEN
            field(rx, ry) = itemType
            placed = placed + 1
        END IF
    LOOP UNTIL placed = itemCount
END SUB

SUB OpenCell(x as ubyte, y as ubyte)
    if (y >= SCREEN_HEIGHT - 1) THEN RETURN
    if (x > SCREEN_WIDTH - 1) THEN RETURN
    if (y < 1) THEN RETURN
    if (x < 0) THEN RETURN
    if (field(x,y) >= 10) THEN RETURN

    field(x,y) = field(x,y) + 10 'mark as opened

    if field(x,y) = 10 THEN print at y,x; paper WHITE; ink BLACK; " ": RETURN

    DrawItem(x,y)

END SUB

SUB ExecuteCell(x as ubyte, y as ubyte)

    'if field(x,y) = 0 THEN RETURN

    if field(x,y) = 11 THEN
        if hasKey THEN
            PrintAt(SCREEN_HEIGHT - 1 , 0, LINE_EMPTY)
            PrintAt(SCREEN_HEIGHT - 1 , 0, "You opened the door! You win!")
            'hasKey = FALSE
        else
            PrintAt(SCREEN_HEIGHT - 1 , 0, LINE_EMPTY)
            PrintAt(SCREEN_HEIGHT - 1 , 0, "The door is locked. Find the key!")
        END IF
    END IF

    if field(x,y) = 12 OR field(x,y) = 2 THEN
        field(x,y) = 22 'mark as taken
        hasKey = TRUE
        PrintAt(SCREEN_HEIGHT - 1 , 0, LINE_EMPTY)
        PrintAt(SCREEN_HEIGHT - 1 , 0, "You found the key! Now find the door!   ")
        for xx = 0 to SCREEN_WIDTH - 1
            for yy = 0 to SCREEN_HEIGHT - 1
                if field(xx,yy) = 11 THEN DrawDoor(xx,yy)
            next yy
        next xx
    END IF
END SUB

SUB DrawKey(x as ubyte, y as ubyte)

    if hasKey THEN RETURN

    print at y,x; paper WHITE; ink GREEN; CHR(144 + 1)

END SUB

SUB DrawDoor(x as ubyte, y as ubyte)

    dim c as ubyte = RED
    if hasKey THEN c = GREEN        

    print at y,x; paper WHITE; ink c; CHR(144)

END SUB

SUB DrawField()
    DIM x as ubyte
    DIM y as ubyte
    FOR y = 0 TO SCREEN_HEIGHT - 1
        FOR x = 0 TO SCREEN_WIDTH - 1
            DrawItem(x,y)
        NEXT x
    NEXT y
END SUB

SUB DrawItem(x as ubyte, y as ubyte)
    if field(x,y) = 0 THEN RETURN
    'if field(x,y) = 10 THEN print at y,x; paper WHITE; ink BLACK; " ": RETURN
    if field(x,y) = 11 OR field(x,y) = 1 THEN DrawDoor(x,y): RETURN
    if field(x,y) = 12 OR field(x,y) = 2 THEN DrawKey(x,y): RETURN
END SUB

FUNCTION CheckKey(dir as string) as BOOLEAN
    if dir = "w" AND (key = "w" OR key = "W" OR key = "7") THEN RETURN TRUE
    if dir = "s" AND (key = "s" OR key = "S" OR key = "6") THEN RETURN TRUE
    if dir = "a" AND (key = "a" OR key = "A" OR key = "5") THEN RETURN TRUE
    if dir = "d" AND (key = "d" OR key = "D" OR key = "8") THEN RETURN TRUE
    RETURN FALSE
END FUNCTION

'================== ==============='
'== PROGRAM START                =='
'================== ==============='
paper BLACK: ink WHITE: border BLACK: cls
LoadTitleScreen()
ClearTitleScreenData()
PAUSE 1000

PROGRAM:

    randomize
    Wait(RND * 5)
    randomize

    Init()
    paper BLACK: ink WHITE: border BLACK: cls
    POKE UINTEGER 23675, @Items

    PrintAt(0,0, "Adventure Game.")
    HRPrint(ch_posX, ch_posY, @Character, attr , 0)   

    hasKey = FALSE

    DIM oldX as ubyte
    DIM oldY as ubyte


    DO
        oldX = ch_posX
        oldY = ch_posY

        key = INKEY$
        if key = " " THEN GOTO END_PROGRAMM

        ' =====================================
        ' IF NOT MOVING, CHECK FOR INPUT TO START MOVING
        ' =====================================
        IF moveX = 0 AND moveY = 0 THEN

            ' atļauj sākt iet tikai tad, ja čars ir uz grida
            IF (ch_posX MOD 8) = 0 AND (ch_posY MOD 8) = 0 THEN

                IF CheckKey("w") AND ch_posY > 8 THEN moveX = 0: moveY = -1
                IF CheckKey("s") AND ch_posY <= scrH - ch_speed THEN moveX = 0: moveY = 1
                IF CheckKey("a") AND ch_posX >= ch_speed THEN moveX = -1: moveY = 0
                IF CheckKey("d") AND ch_posX <= scrW - ch_speed THEN moveX = 1: moveY = 0

            END IF
        END IF

        ' =====================================
        ' IF MOVING, CONTINUE MOVEMENT UNTIL REACHING THE NEXT GRID CELL
        ' =====================================
        IF moveX <> 0 OR moveY <> 0 THEN

            oldX = ch_posX
            oldY = ch_posY
            ch_posX = ch_posX + moveX * ch_speed
            ch_posY = ch_posY + moveY * ch_speed

            ' kad sasniegts nākamais grid punkts, apstājās
            IF (ch_posX MOD 8) = 0 AND (ch_posY MOD 8) = 0 THEN moveX = 0: moveY = 0
        END IF

        Wait(2)        

        if oldX = ch_posX AND oldY = ch_posY THEN CONTINUE DO

        DIM cellX as ubyte = (ch_posX + 4) / 8
        DIM cellY as ubyte = (ch_posY + 4) / 8

        'open adjacent cells X
        if moveX <> 0 THEN
            OpenCell(cellX, cellY)
            OpenCell(cellX, cellY + 1)
            OpenCell(cellX, cellY - 1)
        END IF

        'open adjacent cells Y
        if moveY <> 0 THEN
            OpenCell(cellX, cellY)
            OpenCell(cellX + 1, cellY)
            OpenCell(cellX - 1, cellY)
        END IF

        HRPrint(oldX, oldY, 32, attrBlank ,  0)
        HRPrint(ch_posX, ch_posY, @Character, attr ,  0)   

        ExecuteCell(cellX, cellY)

        DrawItem(cellX, cellY)
        DrawItem(cellX+1, cellY)
        DrawItem(cellX-1, cellY)
        DrawItem(cellX, cellY+1)
        DrawItem(cellX, cellY-1)

        oldX = ch_posX
        oldY = ch_posY

        PrintAt(0,21, "Cell: " + str(cellX) + ":" + str(cellY) + "   ")
        'PrintAt(SCREEN_HEIGHT - 1 , 0, str(oldX) + ":" + str(oldY) + " -> " + str(ch_posX) + ":" + str(ch_posY) + "   ")

        'DrawField()
        'PRINT AT 15, 10; INK BLACK; PAPER WHITE; CHR(144+1)
    LOOP UNTIL FALSE

ASM
    title_screen_data:
    INCBIN "zxTitleScr.scr"
END ASM

Character:
    ASM
        DB 0,24,60,24,60,90,36,36   ;Character
        ;#include "Graph.asm"
    END ASM
Items:
    ASM
        DB 24,60,110,74,90,90,74,126    ;Door
        DB 16,112,80,248,12,6,28,8      ;Key
    END ASM

END_PROGRAMM:       
    paper WHITE: ink BLACK: border WHITE: cls
    STOP
