**free

//*************************************************************//
// Programme:RPG_API                                           //
// Principe : Saisir le nom d'un pokemon pour                  //
// avoir ses informations                                      //
// Dev : Léo GUALANO                                           //
// ************************************************************//


CTL-OPT COPYRIGHT('(C) ARMONIE 2024.')
OPTION(*SRCSTMT) DFTACTGRP(*NO) OPTIMIZE(*NONE)
ACTGRP(*CALLER) DATFMT(*ISO) TIMFMT(*ISO) ALLOC(*STGMDL)
STGMDL(*INHERIT) THREAD(*SERIALIZE);

//*************************************************************//
// Déclarations des fichiers                                   //
//*************************************************************//
DCL-F POKEDSPF WORKSTN; // QDDSSRC - GUALANO

//*************************************************************//
// Déclaration des variables                                   //
//*************************************************************//
DCL-S UrlFull varchar(255);
DCL-S notvalid ind;

//*************************************************************//
// Déclaration des constantes                                  //
//*************************************************************//
DCL-C Url CONST('https://pokeapi.co/api/v2/pokemon/');



//*************************************************************//
// Traitement principal                                        //
//*************************************************************//

EXEC SQL
 SET option commit = *none , ALWCPYDTA = *OPTIMIZE, CLOSQLCSR = *ENDMOD;

DOW NOT *IN03;

   exfmt fmt1;   // format FMT1: Saisir le nom du pkmn
   clear e1_err; // clear du message d'erreur

   if e1_name = *blanks;
     e1_err = 'Veuillez saisir un nom de pokemon';
     iter;
   ENDIF;

   IF *IN03;
     LEAVE;
   ENDIF;

   exsr fetch;   // Chargement des informations

   if notvalid ;
     e1_err = 'Ce pokemon n''existe pas';
     iter;
   ENDIF;

   exfmt fmt2;   // format FMT2: DSP INFO pokemon

   if *in12;     // Retour à l'écran de saisie
     iter;
   ENDIF;

ENDDO;


*inlr = *on;

//*************************************************************//
// SOUS-ROUTINES                                               //
//*************************************************************//

begsr fetch;
  clear UrlFull; // Remise à zéro de l'URL
  UrlFull =  Url + %trim(%lower(e1_name)); // Constuction de l'URL

  // Récupération des informations grâce à HTTPGETCLOB
  EXEC SQL
        select  NAME , PV , ATT , DEF , SATT , SDEf ,
                VIT , POKETYPE , ABILITY
          into :E2_NAME , :E2_PV , :E2_ATTACK , :E2_DEF , :E2_SATTACK ,
               :E2_SDEF , :E2_VIT , :E2_TYPE , :E2_ABILITY
          from json_table(systools.HTTPGETCLOB(
            cast(:UrlFull as varchar(255)),
            cast(null as clob(1k))),
          '$'
          COLUMNS(
           NAME   VARCHAR(99) PATH '$.forms.name',
           PV VARCHAR(99) PATH '$.stats[0].base_stat',
           ATT VARCHAR(99) PATH '$.stats[1].base_stat',
           DEF VARCHAR(99) PATH '$.stats[2].base_stat',
           SATT VARCHAR(99) PATH '$.stats[3].base_stat',
           SDEF VARCHAR(99) PATH '$.stats[4].base_stat',
           VIT VARCHAR(99) PATH '$.stats[5].base_stat',
           POKETYPE VARCHAR(99) PATH '$.types[0].type.name',
           ABILITY VARCHAR(99) PATH '$.abilities[0].ability.name'
         )
        );

   if SQLCODE = -4302;
      notvalid = *on;
   ENDIF;
ENDSR;



