**free

//-----------------------------------------------------------------|
//     Programme THE FINAL CUT (gestion formations)                |
//-----------------------------------------------------------------|


//----------------------|
//     déclaratives     |
//----------------------|

// Déclaration écran
dcl-f e_finalcut workstn sfile(sfl1:rang);

// Déclaration fichier impréssion
dcl-f prtf_final PRINTER oflind(*in30);

// Variables Globales
dcl-s rang packed(4:0);
dcl-s sql  varchar(32000);
dcl-s sqlw varchar(32000);
dcl-s year packed(4:0);
dcl-s month packed(4:0);
dcl-s day packed(4:0);
dcl-s currentdate date;



//------------------------------------|
//         programme                  |
// -----------------------------------|
// indicateurs :                      |
// *in50 = SFLDSP                     |
// *IN51 = SFLDSPCTl                  |
// *IN52 = SFLCLEAR                   |
// *IN53 = SFLLEND                    |
// *IN60 = Zones protégées (FMT1)     |
// *IN61 = Zones Non affichable(FMT1) |
// *IN62 = Zone protégée datefin(FMT1)|
// *IN63 = Zone non affichable MSG_err|
// *IN64 = Zone Non affichable (datef)|
//------------------------------------|

// sortie du programme
*inlr = *on;

exec sql set option commit = *none;

// date du jour
currentdate = %date();

exec sql
declare c2 cursor for
select code_f , date_debut , date_fin , nom , prenom ,
  societe , etat , type , formateur
from sessions
where date_debut >= :currentdate
order by date_debut desc;

// Boucle principale
DOW NOT *IN03;

  //indicateurs off + clear zones
  *in60 = *off;
  *in61 = *off;
  *in62 = *off;
  *in63 = *off;
  *in64 = *off;
  *in70 = *off;
  clear opt;
  clear fonction;
  clear titre;
  clear msg;
  clear msg_err;

  // initialisation et écriture du sf
  exsr init;
  exsr build;
  write BAS;
  exfmt CTL1;
  clear msg_valid;

  // gestion de l'actualisation du sf
  if *in05 = *on;
    clear opt;
    clear filtre;
    iter;
  ENDIF;

  // gestion de la création
  if *in06 = *on;
    exsr create;
  ENDIF;

  // gestion de l'impréssion
  if *in08 = *on;
    exsr printer;
  ENDIF;

  // lecture du sous-fichier
  readc sfl1;
  dow not %eof;
    *in60 = *off;
    *in61 = *off;
    *in62 = *off;
    *in63 = *off;
    *in64 = *off;
    *in70 = *off;
    clear msg_err;
    clear nbrcode;
    clear nbrnom;
    clear nbrsoc;
    clear nbrjours;
    // gestion des options
    select;
      when opt = '5';
        exsr display;
      when opt = '2';
        exsr update;
      when opt = '4';
        exsr delete;
    ENDSL;
    readc sfl1;
  ENDDO;

ENDDO;



//----------------------|
//     sous-routines    |
//----------------------|

// sous routine INIT
begsr INIT;
  rang = 0;
  // clear du sf
  *in52 = *on;
  write CTL1;
  *in52 = *off;
ENDSR;

// sous routine BUILD
begsr build;
  exec sql close c1;
  // conditionnement du cursor
  sql='select code_f,date_debut,date_fin,nom,prenom,';
  sql += 'societe,etat,type,formateur from sessions';
  sqlw = '';
  if filtre <> *blanks;
    // Vérification du format de date
    if %len(%trim(filtre)) = 10 AND
       %scan('-':%trim(filtre)) > 1 and
       %check('0123456789': %subst(%trim(filtre): 1:4)) = 0 and
       %check('0123456789': %subst(filtre: 6:2)) = 0 And
       %int(%subst(filtre:6:2)) <= 12 and
       %int(%subst(filtre:6:2)) > 0 and
       %check('0123456789': %subst(filtre: 9:2)) = 0;

      month = %int(%subst(filtre:6:2));
      day = %int(%subst(filtre:9:2));
      year = %int(%subst(filtre:1:4));

      if ( month = 1 or month = 3 or month = 5 or month = 7 or month = 8 or
        month = 10 or month = 12);
        if day <= 31 and day > 0;
          sqlw = 'date_debut <= '''  + %char(filtre) + '''' ;
        else;
          sqlw = '';
          msg = 'Format date: YYYY-MM-JJ ';
        ENDIF;
      ENDIF;

      if ( month = 4 or month = 6 or month = 9 or month = 11 );
        if day <= 30 and day > 0;
          sqlw = 'date_debut <= '''  + %char(filtre) + '''' ;
        else;
          sqlw = '';
          msg = 'Format date: YYYY-MM-JJ ';
        ENDIF;
      ENDIF;

      if month = 2;
        if %rem(year:4) = 0;
          if day <= 29 and day > 0;
            sqlw = 'date_debut <= '''  + %char(filtre) + '''' ;
          else;
            sqlw = '';
            msg = 'Format date: YYYY-MM-JJ ';
          ENDIF;
        else;
          if day <= 28 and day > 0;
            sqlw = 'date_debut <= '''  + %char(filtre) + '''' ;
          else;
            sqlw = '';
            msg = 'Format date: YYYY-MM-JJ ';
          ENDIF;
        ENDIF;
      ENDIF;

    else;
      sqlw = '';
      msg = 'Format date: YYYY-MM-JJ ';
    ENDIF;
  ENDIF;
  if sqlw <> '' ;
    sql += ' where ' + sqlw;
  ENDIF;
  sql += ' order by date_debut desc ';
  exec sql
  prepare p1 from :sql;
  exec sql
  declare c1 cursor for p1;

  exec sql open c1;
  exec sql
  fetch c1 into
  :e_codef , :e_dated , :e_datef , :e_nom , :e_prenom , :e_societe ,
  :e_etat , :e_type , :e_form;
  dow sqlcode <> 100;
    rang += 1;
    write sfl1;
    exec sql
      fetch c1 into
      :e_codef , :e_dated , :e_datef , :e_nom , :e_prenom , :e_societe ,
      :e_etat , :e_type , :e_form;
  ENDDO;
  *in53 = *on;
  // affichage du format de controle et du sf si enreg
  if rang > 0;
    *in51 = *on;
    *in50 = *on;
  // affichage du format de controle
  else;
    *in51 = *on;
  ENDIF;
ENDSR;

// sous routine CREATE
begsr create;
  clear fmt1;
  *in61 = *on;
  *in62 = *on;
  *in64 = *on;
  titre = 'Création';
  fonction = 'F6=Créer';
  dow 1=1;
    exfmt fmt1;
    clear msg_err;
    if *in03 = *on or *in12 = *on;
      leave;
    ENDIF;
    if *in06 = *on;
      clear msg_err;
      // sous routine des regles de gestions
      exsr datacheck;
      if msg_err = *blanks;
        // calcul de la date de fin
        exec sql
        select nbjours into :nbrjours from catalogue where code_f=:e1_codef;
        e1_datef = e1_dated + %days(nbrjours);
        exec sql
        select max(id) into :idsess from sessions;
        idsess = idsess + 1;
        // Insertion
        exec sql
        insert into sessions (id , code_f , date_debut , date_fin , nom,
        prenom , societe , etat , type , formateur )
        VALUES ( :idsess , :e1_codef , :e1_dated , :e1_datef , :e1_nom,
        :e1_prenom , :e1_societe , :e1_etat , :e1_type , :e1_form );
        msg_valid = 'Session du ' + %char(e1_dated) + ' créé';
        leave;
      else;
        iter;
      ENDIF;
    ENDIF;
  ENDDO;
ENDSR;

// sous routine PRINTER
begsr printer;
  write titres;
  exec sql close c2;
  exec sql open c2;
  exec sql
  fetch c2 into :pcodef , :pdated , :pdatef , :pnom , :pprenom , :psociete ,
  :petat , :ptype , :pform;
  write colonne;
  dow sqlcode <> 100;
    write details;
    // gestion du saut de page
    if *in30;
      write eject;
      write colonne;
    ENDIF;
    *in30 = *off;
    exec sql
    fetch c2 into :pcodef , :pdated , :pdatef , :pnom , :pprenom , :psociete,
    :petat , :ptype , :pform;
  ENDDO;
  msg_valid = 'Fichier impression dans fichier spool';
ENDSR;

// sous routine DISPLAY
begsr display;
  *in60 = *on;
  *in62 = *on;
  *in63 = *on;
  titre = 'Affichage';
  // Récupération des informations des tables sessions,participant,catalogue
  exec sql
  SELECT c.code_f,
       c.libelle,
       c.detail,
       c.nbjours,
       c.requis,
       p.nom,
       p.prenom,
       s.date_debut,
       s.date_fin,
       s.societe,
       s.etat,
       s.type,
       s.formateur,
       p.tel,
       p.email
   INTO :e1_codef, :e1_libelle, :e1_detail, :e1_jour, :e1_requis, :e1_nom,
   :e1_prenom, :e1_dated, :e1_datef , :e1_societe, :e1_etat, :e1_type,
   :e1_form, :e1_tel, :e1_mail
    FROM gualano.catalogue AS c
         JOIN gualano.sessions AS s
             ON c.code_f = s.code_f
         JOIN gualano.participants AS p
             ON s.nom = p.nom
                 AND s.prenom = p.prenom
    WHERE p.nom = :e_nom
          AND p.prenom = :e_prenom;
  exfmt fmt1;
  if *in12 = *on or *in03 = *on;
    clear opt;
    exsr init;
    exsr build;
  ENDIF;
ENDSR;

// sous routine UPDATE
begsr update;
  *in61 = *on;
  *in62 = *on;
  *in64 = *on;
  fonction = 'F7=Mofifier';
  titre = 'Modification';
  e1_codef = e_codef;
  e1_dated = e_dated;
  e1_datef = e_datef;
  e1_nom = e_nom;
  e1_prenom = e_prenom;
  e1_form = e_form;
  exec sql
  select etat, type
  into :e1_etat, :e1_type
  from sessions
  where nom=:e_nom and prenom=:e_prenom;
  exec sql
  select societe
  into :e1_societe
  from participants
  where nom=:e_nom and prenom=:e_prenom;
  dow 1=1;
    exfmt fmt1;
    if *in07 = *on;
      clear msg_err;
      // sous routine regles de gestions
      exsr datacheck;
      if msg_err = *blanks;
        exec sql
        select nbjours into :nbrjours from catalogue where code_f=:e1_codef;
        e1_datef = e1_dated + %days(nbrjours);
        exec sql
        update sessions
        set code_f=:e1_codef , date_debut=:e1_dated, date_fin=:e1_datef ,
        nom=:e1_nom , prenom=:e1_prenom , societe=:e1_societe , etat=:e1_etat,
        type=:e1_type , formateur=:e1_form
        where date_debut = :e_dated and date_fin=:e_datef
        and nom=:e_nom and prenom=:e_prenom;
        msg_valid = 'Modification(s) réussie(s)';
        leave;
      else;
        iter;
      ENDIF;
    ENDIF;
    leave;
  enddo;
  if *in12 = *on or *in03 = *on;
    clear opt;
    exsr init;
    exsr build;
  ENDIF;
ENDSR;

// sous routine DELETE
begsr delete;
  *in61 = *on;
  *in60 = *on;
  *in62 = *on;
  *in63 = *on;
  fonction = 'F23=Supprimer';
  titre = 'Suppression';
  e1_codef = e_codef;
  e1_dated = e_dated;
  e1_datef = e_datef;
  e1_nom = e_nom;
  e1_prenom = e_prenom;
  e1_form = e_form;
  exec sql
  select etat, type
  into :e1_etat, :e1_type
  from sessions
  where nom=:e_nom and prenom=:e_prenom;
  exec sql
  select societe
  into :e1_societe
  from participants
  where nom=:e_nom and prenom=:e_prenom;
  exfmt fmt1;
  // Supression
  if *in23 = *on;
    exec sql
    delete from sessions where code_f=:e1_codef and date_debut=:e1_dated
    and date_fin=:e1_datef and nom=:e1_nom and prenom=:e1_prenom and
    societe=:e1_societe and formateur=:e1_form;
    msg_valid = 'Suppression(s) réussie(s)';
  ENDIF;
  if *in12 = *on or *in03 = *on;
    clear opt;
    exsr init;
    exsr build;
  ENDIF;
ENDSR;

// sous routines
// sous routine regle de gestion
begsr datacheck;
  dow 1 = 1;
    // Vérification du code formation
    exec sql
      select count(*) into :nbrcode
      from catalogue
      where code_f = :e1_codef;
    if nbrcode = 0;
      msg_err = 'Ce code Formation n''existe pas dans le catalogue';
      leave;
    ENDIF;
    // Vérificaion Nom/Prénom dans table participants
    exec sql
    select count(*) into :nbrnom
    from participants
    where nom = :e1_nom and prenom = :e1_prenom;
    if nbrnom = 0;
      msg_err = 'Ce nom et prénom n''existe pas dans les participants';
      leave;
    ENDIF;
    // Vérification société
    exec sql
    select count(*) into :nbrsoc
    from participants
    where nom=:e1_nom and prenom=:e1_prenom and societe=:e1_societe;
    if nbrsoc = 0 ;
      msg_err = 'La société ne correpond pas avec le Nom/Prénom';
      leave;
    ENDIF;
    // Vérification ETAT
    if %trim(e1_etat) <> 'Non Facturé' and %trim(e1_etat) <> 'Facturé';
      msg_err = 'Valeures admises pour etat : Facturé/Non Facturé';
      leave;
    ENDIF;
    // Vérification TYPE
    if %trim(e1_type) <> 'Présentiel' and %trim(e1_type) <> 'Distanciel';
      msg_err = 'Valeures admises pour type : Présentiel/Distanciel';
      leave;
    ENDIF;
  leave;
  ENDDO;
ENDSR;

