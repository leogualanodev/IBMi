     Djsemaine         s              8a   dim(7) ctdata
     Dcmdos400         s             70a   dim(3) ctdata
     Dlong             S             15  5 inz(50)
     DI                s              2  0 inz(1)
     C                   for       I TO 7
     C     jsemaine(I)   Dsply
     c                   ENDFOR
     C                   CALL      'QCMDEXC'
     C                   parm                    cmdos400(1)
     c                   parm                    long
     C                   eval      *inlr=*on
**ctdata jsemaine
lundi
mardi
mercredi
jeudi
vendredi
samedi
dimanche
**ctdata cmdos400
?wrkobj
SNDMSG MSG(deux) TOUSR(leo2)
SNDMSG MSG(trois) TOUSR(leo2)
