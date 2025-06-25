DIM permutation(0 TO 255) AS UBYTE

' A simple implementation of Perlin noise using a random permutation table
FUNCTION hashPerm(x as INTEGER, y AS INTEGER) AS UBYTE
    DIM idx AS Integer = x MOD 256
    idx = permutation(idx) + y
    idx = idx MOD 256
    return permutation(idx)
END FUNCTION

' Returns 1 for noise, 0 for no noise
FUNCTION noise01(x AS INTEGER, y AS INTEGER, scale AS INTEGER) AS UBYTE
    DIM sx AS INTEGER = INT(x / scale)
    DIM sy AS INTEGER = INT(y / scale)
    IF (hashPerm(sx, sy) & 128) <> 0 THEN
        RETURN 1
    END IF
    RETURN 0
END FUNCTION



paper 0: ink 7:cls
print at 0, 0; "Perlin Noise. Press any key."
pause 0

randomize


DIM i,x,y as UInteger

newNoise:
CLS
'Generate a random permutation table'
for i = 0 to 255
    permutation(i) = RND * 255
next i

FOR y = 0 TO 196 STEP 4
    FOR x = 0 TO 255 STEP 4
        IF noise01(x, y, 20) = 1 THEN
            PLOT x, y
        END IF
    NEXT x
NEXT y

WHILE INKEY=""
END WHILE
if INKEY$ = "z" THEN
    GOTO newNoise
END IF

'pause 0
paper 7: ink 0:cls
STOP