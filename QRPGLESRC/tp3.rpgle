     *********** déclaratives **********
     ** datastructure sous zone 'zone'=> tableau de 10 *10 *********
     Di                s              2  0 inz(1)
     Ddtarea           ds                  dtaara(dt100)
     Dzone                           10    dim(10)
     ************ traitement ***********
     c                   seton                                            lr
     c                   in        dtarea
     C                   for       I to 10
     c                   if        %scan('FIN': zone(i)) > 0
     c     zone(i)       dsply
     c                   leave
     c                   else
     c     zone(i)       dsply
     c                   endif
     C                   endfor
     C                   eval      *inlr=*on
