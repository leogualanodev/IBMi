             PGM
             /* COMMENTAIRES */
             DCL        VAR(&CURLIB) TYPE(*CHAR) LEN(10) +
                          VALUE('gualano')
             CHGLIBL    LIBL(QTEMP QGPL GUALANO) CURLIB(&CURLIB)
             ENDPGM
