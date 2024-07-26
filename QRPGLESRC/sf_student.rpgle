     ****************     Déclaratives    *****************
     FE_STUDENT cf   e             workstn
     F                                     sfile(sfl01:rang)
     Fstudent   uf a e           k disk
     Fprtfstud  o    e             printer oflind(*in23)

     ****************     Programme       *****************
     * Indicateurs
     * *IN50 = affichage sous fichier
     * *in51 = affichage format de contrôle
     * *in52 = effacement du sous fichier
     * *in53 = caractère de suite
     * *in60 = zone protégé
     * *in61 = gestion de l'affichage de f22 update
     * *in62 = gestion de l'affichage de f23 supprimmer
     * *in63 = gestion de l'affichage de f21 créer
     * *in70 = message modif
     * *in71 = message delete
     * *in72 = message creation
     * *in73 = message impression

     * seton lr pour sortir du prog
     c                   seton                                            lr
     * declaration de rang et init à zéro
     c                   z-add     *zero         rang              4 0

     * boucle globale F3
     c                   dow       *in03 = '0'
     c                   exsr      sf_student
     c                   write     entete
     c                   write     bas
     c                   exfmt     ctl01
     *  lecture du sous fichier
     c                   readc     sfl01                                  98
     c                   dow       *in98 = '0'
     c                   setoff                                           60
     c                   setoff                                           61
     c                   setoff                                           62
     c                   setoff                                           63
     c                   setoff                                           73
     c                   if        opt <> *blanks
     c                   call      'STUDENTDSP'
     c                   parm                    enom
     c                   parm                    opt
     c                   endif
     c                   eval      opt = ' '
     c                   readc     sfl01                                  98
     c                   enddo
     *  gestion des touches de fonctions
     c                   if        *in05 = '1'
     c                   eval      filtre = ' '
     c                   endif
     c                   if        *in06 = '1'
     c                   seton                                            61
     c                   seton                                            62
     c                   exfmt     fmt1
     c                   endif
     C                   IF        *IN21 = '1'
     c                   exsr      creation
     c                   seton                                            72
     c                   endif
     c                   if        *in08 = '1'
     c                   exsr      impression
     c                   seton                                            73
     c                   endif
     c                   enddo



     ***********    SOUS ROUTINES     ****************

     * sous routines chargement du sous fichier ( sf_student)
     c     sf_student    begsr
     c                   seton                                            52
     c                   write     ctl01
     c                   setoff                                           52
     c                   z-add     *zero         rang
     c     *loval        setll     fmt
     c                   read      fmt                                    99
     c                   dow       *in99 = '0'
     c                   if        filtre = house or filtre = *blanks
     c                   movel     name          enom
     c                   movel     house         ehouse
     c                   movel     actor         eactor
     c                   add       1             rang
     c                   write     sfl01
     c                   endif
     c                   read      fmt                                    99
     c                   enddo
     c                   seton                                            51
     c                   if        rang <> *zero
     c                   seton                                            50
     c                   seton                                            53
     c                   endif
     c                   endsr

     * sous routines creation
     c     creation      begsr
     c                   move      e1name        name
     c                   move      e1species     species
     c                   move      e1gender      gender
     c                   move      e1house       house
     c                   move      e1actor       actor
     c                   write     fmt
     c                   endsr

     * sous routine impression
     c     impression    begsr
     c                   write     titre
     c     *loval        setll     fmt
     c                   read      fmt                                    91
     c                   write     colonne
     c                   dow       *in91 = '0'
     c   23              write     eject
     c   23              setoff                                           23
     c                   movel     name          pname
     c                   movel     house         phouse
     c                   movel     actor         pactor
     c                   movel     gender        pgender
     c                   movel     species       pspecies
     c                   write     details
     c                   read      fmt                                    91
     c                   enddo
     c                   endsr
