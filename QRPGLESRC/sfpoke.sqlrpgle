**free


//----------------------|
//     déclaratives     |
//----------------------|

dcl-f e_sfpoke workstn sfile(sf1:rang);
dcl-f e_sfpoke1 workstn sfile(sf2:rang1);

dcl-s rang packed(4:0);
dcl-s rang1 packed(4:0);
dcl-s name char(25);
dcl-s pokenbr packed(4:0);
dcl-s pokenbr1 packed(4:0);
dcl-s nbr_enreg packed(4:0);
dcl-s nbr_enreg1 packed(4:0);

//----------------------------------|
//         programme                |
// ---------------------------------|
// indicateurs :                    |
// *in50 = SFLDSP (sf1)             |
// *IN51 = SFLDSPCTl (sf1)          |
// *IN52 = SFLCLEAR (sf1)           |
// *IN53 = SFLLEND  (sf1)           |
// *IN61 = protected ID(FMT1)       |
// *IN60 = protected zones (FMT1)   |
// *in40 = SFLDSP (sf2)             |
// *IN41 = SFLDSPCTl (sf2)          |
// *IN42 = SFLCLEAR (sf2)           |
// *IN43 = SFLLEND  (sf2)           |
//----------------------------------|

*inlr = *on;

exec sql
set option commit = *none;

exec sql
declare c1 cursor for
select e.idpoke , e.nom , p.type1 , ifnull(p.type2 , '-')
from monequipe2g e
join pokemon2g p
on e.idpoke = p.pokedex_number
where e.nom >= :filtre
order by e.nom;

exec sql
declare c2 cursor for
select name , type1 , hp , attack , defense
from pokemon2g
where name >= :filtre1
order by name;


dow not *in03;

  clear opt;
  *in60 = *off;
  *in61 = *off;

  exsr init;
  exsr build;
  write BAS;
  exfmt CTL1;
  clear valid;

  if *in05 = *on;
    iter;
  ENDIF;

  if *in06 = *on;
    exsr capture;
  ENDIF;

  // affichage de la liste de tout les pokemons (SF2)
  if *in10 = *on;
    dow 1 = 1;

      clear opt1;
      exsr init1;
      exsr build1;
      write BAS1;
      exfmt CTL2;
      clear valid1;

      if *in05 = *on;
        iter;
      ENDIF;

      if *in12 = *on or *in03 = *on;
        leave;
      ENDIF;

      readc SF2;
      dow not %eof;
        select;
          when opt1 = '1';
            exsr ajout;
          when opt1 = '5';
            exsr display1;
        ENDSL;
      readc SF2;
      ENDDO;

    ENDDO;
  ENDIF;


  readc sf1;
  dow not %eof;
    select;
      when opt = '5';
        exsr display;
      when opt = '4';
        exsr delete;
    ENDSL;
  readc sf1;
  ENDDO;


ENDDO;


//--------------------------|
//      SOUS ROUTINES       |
//--------------------------|

// sous routines INIT
begsr init;
   exec sql close c1;
   exec sql open c1;
   rang = 0;
   *in52 = *on;
   write CTL1;
   *in52 = *off;
ENDSR;

// sous routine BUILD
begsr build;
  exec sql fetch c1 into :epokenbr , :enom , :etype1 , :etype2;
  dow sqlcode <> 100;
    rang += 1;
    write sf1;
    exec sql fetch c1 into :epokenbr , :enom , :etype1 , :etype2;
  ENDDO;
  *in53 = *on;
   if rang > 0;
     *in51 = *on;
     *in50 = *on;
   else;
     *in51 = *on;
   ENDIF;
ENDSR;

// sous routine DISPLAY
begsr display;
   titre = 'Affichage';
   *in60 = *on;
   *in61 = *on;
   exec sql
   select e.idpoke , e.nom , p.type1 , ifnull(p.type2, '-') , p.hp , p.attack ,
   p.defense , p.special_attack , p.special_defense , p.speed
   into :e2pokenbr , :e2nom , :e2type1 , :e2type2 , :e2hp , :e2attack ,
   :e2defense , :e2spatt , :e2spdef , :e2speed
   from monequipe2g e join pokemon2g p
   on e.idpoke = p.pokedex_number
   where e.idpoke = :epokenbr;
   exfmt FMT1;
   if *in12 or *in03;
     clear opt;
     exsr init;
     exsr build;
   ENDIF;
ENDSR;

// sous routine DELETE
begsr delete;
  wnom = enom;
  exfmt W1;
  if not *in12 and not *in03;
    exec sql
    delete from monequipe2g where nom = :wnom;
    valid = 'pokemon ' + %trim(wnom) + ' supprimé';
  ENDIF;
ENDSR;

// sous routine CAPTURE
begsr capture;
  exfmt W2;
  if not *in12 and not *in03;
    dow 1=1;
      exec sql
      select count(e.idpoke) as nbr_enreg, p.pokedex_number , p.name
      into :nbr_enreg , :pokenbr , :name
      from pokemon2g p
      left join monequipe2g e
      on p.pokedex_number = e.idpoke
      group by p.pokedex_number , p.name
      order by rand() limit 1;
      if nbr_enreg = 0;
        exec sql
        insert into monequipe2g ( idpoke , nom )
        VALUES ( :pokenbr , :name );
        valid = 'pokemon ' + %trim(name) + ' ajouté';
        leave;
      else;
        iter;
      ENDIF;
    ENDDO;
  ENDIF;
ENDSR;


// sous routine pour sous fichier 2 (liste de tout les pokemons
// sous routine INIT1
begsr init1;
  exec sql close c2;
  exec sql open c2;
  rang1 = 0;
  *in42 = *on;
  write CTL2;
  *in42 = *off;
ENDSR;

// sous routine BUILD1
begsr build1;
  exec sql fetch c2 into :e_nom , :e_type1 , :e_hp , :e_attack , :e_defense;
  dow sqlcode <> 100;
    rang1 += 1;
    write SF2;
    exec sql fetch c2 into :e_nom , :e_type1 , :e_hp , :e_attack , :e_defense;
  ENDDO;
  *in43 = *on;
  if rang1 > 0;
    *in41 = *on;
    *in40 = *on;
  else;
    *in41 = *on;
  ENDIF;
ENDSR;

// sous routine AJOUT
begsr ajout;
  w3name = e_nom;
  exfmt W3;
  if not *in12 and not *in03;
      exec sql
      select count(e.idpoke) , p.pokedex_number into :nbr_enreg1 ,:pokenbr1
      from pokemon2g p left join monequipe2g e
      on e.idpoke = p.pokedex_number
      where name = :e_nom
      group by p.pokedex_number;
      if nbr_enreg1 = 0;
        exec sql
        insert into monequipe2g (idpoke , nom) VALUES ( :pokenbr1 , :e_nom);
        valid1 = %trim(e_nom) + ' ajouté à votre équipe';
      else;
        valid1 = %trim(e_nom) + ' existe déjà dans votre équipe';
      ENDIF;
  ENDIF;
ENDSR;

// sous routine DISPLAY1
begsr display1;
   exec sql
   select name , hp , attack , defense ,special_attack , special_defense ,speed,
   type1 , ifnull(type2 , '-')
   into :e2_nom , :e2_hp , :e2_att , :e2_def , :e2_spatt , :e2_spdef ,:e2_speed,
   :e2_type1 , :e2_type2
   from pokemon2g where name = :e_nom;
   exfmt FMT2;
ENDSR;

