**free

CTL-OPT OPTION(*SRCSTMT) DFTACTGRP(*NO) OPTIMIZE(*NONE)
       ACTGRP(*CALLER) DATFMT(*ISO) TIMFMT(*ISO) ALLOC(*STGMDL)
       STGMDL(*INHERIT) THREAD(*SERIALIZE);

//*****************************************************************
// Programme : TEST_API
// GUALANO Léo - Exemple test Utilisation API
// Date      - 22/05/2024
// IMPORTANT !!- CHANGEZ LE OPTIMIZE(*FULL) EN *NONE POUR DEBUG
// Copyright - ARMONIE
//*****************************************************************

//****************************************************************//
// Déclaration Variables                                          //
// ***************************************************************//

DCL-S NAME CHAR(25);
DCL-S ATTAQUE varchar(50);

//****************************************************************//
// Déclaration Url API                                            //
// ***************************************************************//


DCL-C UrlFull CONST('https://pokeapi.co/api/v2/pokemon/pikachu');


//****************************************************************//
// Traitement Principal                                           //
// ***************************************************************//

EXEC SQL
 SET option commit = *none , ALWCPYDTA = *OPTIMIZE, CLOSQLCSR = *ENDMOD;

EXEC SQL
        select  NAME , ATTAQUE into :NAME , :ATTAQUE from json_table(systools.HT
            cast(:UrlFull as varchar(255)),
            cast(null as clob(1k))),
          '$'
          COLUMNS(
           NAME   VARCHAR(99) PATH '$.forms.name',
           ATTAQUE VARCHAR(99) PATH '$.stats[1].base_stat'
         )
        );


dsply NAME;
dsply ATTAQUE;


*inlr=*on;
