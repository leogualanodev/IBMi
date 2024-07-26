**FREE
ctl-opt copyright('(C) ARMONIE 2023.') usrprf(*owner)
option(*srcstmt) dftactgrp(*no) optimize(*none)
actgrp(*caller) datfmt(*iso) timfmt(*iso) alloc(*stgmdl)
stgmdl(*inherit) thread(*serialize);

// *****************************************************************
// Programme : SOUPRC
// FORMATION-  SOUS-FICHIER SEMI DYNAMIQUE EN SQL FULL FREE AVEC PROCÉDURE
// date      - 02/10/2023
// Copyright - ARMONIE
// *****************************************************************

// **********************************************************************//
// Déclaration des fichiers                                             //
// **********************************************************************//
dcl-f SFDSPSQL WORKSTN SFILE(SFL1:rang);

// **********************************************************************//
// Déclaration des variables                                            //
// **********************************************************************//
dcl-s last_rang zoned(4:0) inz(*zero); // Dernier rrn écrit av pagination
dcl-s i         zoned(4:0) inz(*zero);
dcl-s datejour  date(*iso) inz(*job);

// **********************************************************************//
// Déclaration des constantes                                           //
// **********************************************************************//
dcl-c SFLPAG    const(12);   // Nombre de ligne à afficher par page ...
dcl-c AFFICHER  const('5');
dcl-c SUPPRIMER const('4');
dcl-c MODIFIER  const('2');

// **********************************************************************//
// Traitement pricipale                                                 //
// **********************************************************************//
*inlr = *on;
exec sql
set option commit = *none , alwcpydta = *optimize, closqlcsr = *endmod;

// A - initialisation du sous-fichier
initialisation_sous_fichier();

// B - fabrication du sous-fichier
fabrication_sous_fichier();

// La zone de "afficher à partir de" à blanc
scodpro = *blank;

dou *in03;  // Sortie F3
  write Fkey1;
  exfmt SF1CTL;

  // Et là, on se pose la question : Qu'à fait l'utilisateur ?
  select;
  when *in39;    // a-t-il paginé ? (Pagedown)
    fabrication_sous_fichier();
  when scodpro <> *blank; // a-t-il touché à la zone "Afficher à partir de" ?
    exec sql close c1;
    initialisation_sous_fichier();
    fabrication_sous_fichier();
    clear Scodpro;
  when *in05; // F5=Réafficher
    exec sql close c1;
    initialisation_sous_fichier();
    fabrication_sous_fichier();
  when *in06; // F6=Création
    creation();
    exec sql close c1;
    initialisation_sous_fichier();
    fabrication_sous_fichier();
  other; // La touche ENTRER
    exec sql
      SELECT codpro INTO :e1codpro FROM entrepot;
    if sqlcode <> 100;  // si sqlCODE est différent de vide
      trt_readc();  // on fait un readc seulement s'il y a des données
    endif;
    exec sql close c1;
    initialisation_sous_fichier();
    fabrication_sous_fichier();
  endsl;

enddo;

exec sql close c1;

// ************************************************************************
// initialisation du sous fichier                                       //
// ************************************************************************
dcl-proc initialisation_sous_fichier;
  rang = *zero;      // initialisat° du compteur d'enregistrement.
  last_rang = *zero; // initialisat° du dernier rrn d'enregistrement.
  *in31 = *on;       // Activat° de l'indic de vidage de SFL  (Associé au mot cl
  write SF1CTL;      // Vidage du sous-fichier
  *in31 = *off;      // Désactivat° de l'indic de vidage de SFL (Associé au mot
  *in32 = *off;      // Désactivat° de l'indic de vidage de SFL (Associé au mot
  *in90 = *off;      // Désactivat° de l'indic de vidage de SFL (Associé au mot
  exec sql
    DECLARE c1 CURSOR FOR
    (select codpro, nmpro, qtpro, dtdinv
    from entrepot
    order by codpro)
    FOR READ ONLY OPTIMIZE FOR ALL ROWS;

  exec sql
    open c1;
end-proc;

// ************************************************************************
// fabrication du sous fichier                                          //
// ************************************************************************
dcl-proc fabrication_sous_fichier;
  rang = last_rang;        // Le "RRN" reçoit la valeur du dernier rang

  for i=1 to SFLPAG;  // Tantque i est inférieur à sflpag
    exec sql FETCH c1 INTO :e1codpro, :e1nmpro, :e1qtpro, :e1dtdinv;
    if sqlcode = 100;
      *in90=*on;   // "Fin" en bas à droite de l'écran et on sort.
      leave;
    endif;

    // Gere le "Afficher à partir de..."
    if e1codpro >= scodpro;
      rang += 1;  // incrémentation du compteur de ligne
      write SFL1; // Ecrie le sous-fichier
    endif;
  endfor;

  if rang = *zero;
    *in32 = *on;
  endif;

  last_rang = rang;

end-proc;


// ******************************************************************
// Traitement du READC                                            //
// ******************************************************************
dcl-proc trt_readc;
  Readc SFL1;
  dow not %eof;
    select;
    when opt = AFFICHER;  // option 5 Afficher
      affiche();
    when opt = SUPPRIMER; // option 4 Supprimer
      suppression();
    when opt = MODIFIER;  // option 2 Modifier
      modification();
    endsl;
    Readc SFL1;
  enddo;
end-proc;

// ************************************************************************
// Créer                                                                //
// ************************************************************************
dcl-proc creation;
  dou *in03;
    e6dtdinv = datejour;
    exfmt FMT6; // Affiche l'ecran de création
    select;
    when *in03;
      iter;
    when *in12;
      leave;
    when *in23;
      EXEC SQL
      call prc_create(:e6codpro , :e6nmpro , :e6qtpro , :e6dtdinv);
      leave;
    endsl;
  enddo;
  clear opt; // Remise à blanc de l'option saisie
end-proc;

// ************************************************************************
// Afficher                                                             //
// ************************************************************************
dcl-proc affiche;
  EXEC SQL
   SELECT codpro, nmpro, qtpro, dtdinv
    INTO :e5codpro, :e5nmpro, :e5qtpro, :e5dtdinv
   FROM entrepot
   WHERE codpro = :e1codpro;

  exfmt FMT5;
  clear opt; // Remise à blanc de l'option saisie
end-proc;

// ************************************************************************
// Modifier                                                             //
// ************************************************************************
dcl-proc modification;
  exec sql
    select codpro, nmpro, qtpro, dtdinv
    INTO :e2codpro, :e2nmpro, :e2qtpro, :e2dtdinv
    FROM entrepot
    WHERE codpro = :e1codpro;
  dou *in03;
    exfmt FMT2; // Affiche l'ecran de modification
    select;
    when *in03;
      iter;
    when *in12;
      leave;
    when *in23;
      exec sql
      CALL prc_modif(:e1codpro , :e2codpro , :e2nmpro ,
       :e2qtpro , :e2dtdinv);
      leave;
    endsl;
  enddo;
  clear opt; // Remise à blanc de l'option saisie
  update SFL1;  // Mets à jour le Sous-fichier
end-proc;

// ************************************************************************
// Supprimer                                                            //
// ************************************************************************
dcl-proc suppression;
  exec sql
    SELECT codpro, nmpro, qtpro, dtdinv
    INTO :e4codpro, :e4nmpro, :e4qtpro, :e4dtdinv
    FROM entrepot
    WHERE codpro = :e1codpro;
  exfmt FMT4 ; // Affiche l'ecran de suppression
  clear opt; // Remise à blanc de l'option saisie

  if *in23;  // Si F23 on active le delete
     EXEC SQL
     call prc_delete(:e1codpro);
  endif;

  update SFL1;   // Mets à jour le Sous-fichier
end-proc;
