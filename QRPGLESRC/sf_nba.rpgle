     ************   declaratives ****************
     Fe_sfnba   cf   e             workstn
     F                                     sfile(sf01:rang)
     Fjoueursnbauf a e           k disk    rename(joueursnba:fmtnba)
     fnbaprtf   O    E             PRINTER
     ************    programme   ****************

     ************* INDICATEURS ************
     *  *IN40 = zone protégé
     *  *IN41 = gestion affichage f23 = delete
     *  *IN42 = gestion affichage f22 = update

     *  seton lr pour sortir du prog
     c                   seton                                            lr

     *  decl de rang et init à 0
     c                   z-add     *zero         rang              4 0

     * boucle globale (f3 = quit)
     c                   dow       *in03 = '0'
     c                   exsr      trt_nba
     c                   write     fmt1
     c                   write     fmt2
     c                   exfmt     ctl01
     c                   readc     sf01                                   98
     c                   dow       *in98 = '0'
     c                   setoff                                           40
     c                   setoff                                           41
     c                   setoff                                           42
     c                   if        opt = '5'
     c                   seton                                            40
     c                   seton                                            42
     c                   exsr      trt_dsp
     c                   endif
     c                   if        opt = '4'
     c                   exsr      trt_del
     c                   endif
     c                   if        opt = '2'
     c                   exsr      trt_modif
     c                   endif
     c                   readc     sf01                                   98
     c                   enddo
     c                   if        *in05 = '1'
     c                   eval      filtre = ' '
     c                   endif
     * gestion de l'impression
     c                   if        *in08 = '1'
     c                   exsr      trt_prtf
     c                   endif
     c                   enddo

     ************   sous routine  *************
     ** TRT NBA ***
     c     trt_nba       begsr
     * mis a zéro du sous fichier
     * sur format de contôle car indicateurs placé sur celui-ci
     c                   seton                                            52
     c                   WRITE     CTL01
     c                   setoff                                           52

     *  lecture et ecriture du sous fichier
     c                   z-add     0             rang
     c     *loval        setll     fmtnba
     c                   read      fmtnba                                 99
     c                   dow       *in99 = '0'
     c                   if        filtre = equipe or filtre = *blanks
     c                   add       1             rang
     c                   movel     nom           enom
     c                   movel     equipe        eequipe
     c                   write     sf01
     c                   endif
     c                   read      fmtnba                                 99
     c                   enddo
     c                   seton                                            51
     c                   if        rang <> *zero
     c                   seton                                            50
     c                   seton                                            53
     c                   endif
     c                   endsr

     ** trt_dsp : affichage des infos du joueurs
     c     trt_dsp       begsr
     c     id            chain     fmtnba
     c                   move      nom           e3nom
     c                   move      prenom        e3prenom
     c                   move      taille        e3taille
     c                   move      age           e3age
     c                   move      equipe        e3equipe
     c                   move      nombr00001    e3nbrt
     C                   MOVE      ID            E3ID
     c                   exfmt     fmt3
     c                   eval      opt = ' '
     c                   endsr

     * trt_del : effacer un joueurs nba
     c     trt_del       begsr
     c                   seton                                            40
     c                   seton                                            41
     c                   seton                                            42
     c                   exsr      trt_dsp
     c                   if        *in23 = '1'
     c     e3id          delete    fmtnba
     c                   endif
     c                   endsr
     * trt_modif : modificier un enreg
     c     trt_modif     begsr
     c                   exsr      trt_dsp
     c                   if        *in22 = '1'
     c                   move      e3id          id
     c                   move      e3nom         nom
     c                   move      e3prenom      prenom
     c                   move      e3taille      taille
     c                   move      e3age         age
     c                   move      e3equipe      equipe
     c                   move      e3nbrt        nombr00001
     c                   update    fmtnba
     c                   endif
     c                   endsr

     * sous routines impression
     c     trt_prtf      begsr
     c                   write     titre
     c     *loval        setll     fmtnba
     c                   read      fmtnba                                 91
     c                   write     colonne
     c                   write     ligne
     c                   dow       *in91 = '0'
     c                   movel     nom           pnom
     c                   movel     prenom        pprenom
     c                   movel     equipe        pequipe
     c                   write     details
     c                   read      fmtnba                                 91
     c                   enddo
     c                   endsr
