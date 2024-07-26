     *******  HEADER *************

     Halwnull(*usrctl)

     *********    DECLARATIVES     **************

     FPOKEMONL1 IF a E           K DISK    prefix(lf_)
     Ftp4       cf   e             workstn

     *********     TRAITEMENT      **************

     C                   SETON                                            LR

     C                   DOW       *in03 = '0'

     c                   clear                   pokenum
     C                   EXFMT     FMT1

     C                   SELECT
     C                   WHEN      *IN50 = '1'
     C     pokenum       CHAIN     POKEMON
     C                   IF        %found
     c                   move      lf_poked00001 pokenum2
     c                   movel     lf_name       name2
     c                   move      lf_attack     attack2
     c                   move      lf_defense    defense2
     c                   EXFMT     FMT2
     c                   else
     c                   exsr      trt_creation
     c                   endif

     c                   ENDSL
     c                   enddo
     c     trt_creation  begsr
     c                   move      pokenum       pokenum3
     c                   exfmt     fmt3
     c                   if        *in23 = '1'
     c                   eval      lf_name = name3
     c                   move      pokenum3      lf_poked00001
     c                   move      hp3           lf_hp
     c                   move      attack3       lf_attack
     c                   move      defense3      lf_defense
     c                   move      specia3       lf_speci00001
     c                   move      specid3       lf_speci00002
     c                   move      speed3        lf_speed
     c                   eval      lf_type1 = type13
     c                   eval      lf_type2 = type23
     c                   write     pokemon
     c                   endif
     c                   endsr
