DIM permutation(0 TO 255) AS UBYTE

' A simple implementation of Perlin noise using a random permutation table
FUNCTION hashPerm(x as uByte, y as uByte) as uByte
    DIM idx as uByte = x & 255
    idx = permutation(idx) + y
    idx = idx & 255
    return permutation(idx)
END FUNCTION


' Returns 1 for noise, 0 for no noise
'x and y are pixel coordinates, scale is the size of the noise "cells"'
' threshold is the value above which noise is considered present'
FUNCTION noise01(x as uByte, y as uByte, scale as uByte, threshold AS UBYTE = 128) as uByte
    DIM sx as uByte = INT(x / scale)
    DIM sy as uByte = INT(y / scale)
    'RETURN (hashPerm(sx, sy) & 128) / 128

    IF hashPerm(sx, sy) > threshold THEN
        RETURN 1
    END IF
    RETURN 0

END FUNCTION

SUB initPerlin()
    'DIM i as UInteger
    'for i = 0 to 255
    ''    permutation(i) = RND * 255
    'next i
    DIM i AS UInteger
    DIM j AS UInteger
    DIM temp AS UByte
    'Fill permutation with values 0-255'
    FOR i = 0 TO 255
        permutation(i) = i
    NEXT i
    ' Shuffle the permutation array using Fisher-Yates algorithm'
    FOR i = 255 TO 1 STEP -1
        j = RND * i 
        temp = permutation(i)
        permutation(i) = permutation(j)
        permutation(j) = temp
    NEXT i

END SUB

paper 0: ink 7:cls
print at 0, 0; "Perlin Noise. Press any key."
pause 0

randomize

DIM x,y as UInteger
DIM tresh as UByte = 125
DIM scale AS UByte = 20

newNoise:
if scale > 100 THEN scale = 100
if scale < 1 THEN scale = 1
if tresh > 255 THEN tresh = 255
if tresh < 0 THEN tresh = 0
CLS
print at 0,0; "Treshold: "; tresh;" Scale: "; scale


'Generate a random permutation table'
initPerlin()

FOR y = 0 TO 175 STEP 4
    FOR x = 0 TO 255 STEP 4
        IF noise01(x, y, scale, tresh) = 1 THEN
            PLOT x, y
        END IF
    NEXT x
NEXT y

WHILE INKEY=""
END WHILE
if INKEY$ = "z" THEN GOTO newNoise
if INKEY$ = "a" scale = scale + 1: GOTO newNoise
if INKEY$ = "d" scale = scale - 1: GOTO newNoise
if INKEY$ = "w" THEN tresh = tresh + 5: GOTO newNoise
if INKEY$ = "s" THEN tresh = tresh - 5: GOTO newNoise


'pause 0
paper 7: ink 0:cls
STOP