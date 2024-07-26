**FREE
//*------------------------------------------------------------------------*
//*   Programme : CHK_APIEXO                                               *
//*   Libellé   : PGM de service  EN FREE   Webservice                     *
//*   Compilation : CRTSRVPGM SRVPGM(*CURLIB/CHK_APIEXO)
//*                 MODULE(*CURLIB/MOD_API) EXPORT(*ALL) ACTGRP(*CALLER)
//*                 USRPRF(*OWNER) STGMDL(*INHERIT)

//*------------------------------------------------------------------------*
//*   Projet    : FORMATION                                                *
//*   Auteur    : Sylvain AKTEPE                                           *
//*   Date      : 11/09/2023                                               *
//*------------------------------------------------------------------------*
CTL-OPT COPYRIGHT('(C) ARMONIE 2023.') USRPRF(*OWNER) OPTIMIZE(*NONE)
DFTACTGRP(*NO) ACTGRP(*CALLER) DATFMT(*ISO) TIMFMT(*ISO)
ALLOC(*STGMDL) STGMDL(*INHERIT) BNDDIR('SCHTROUMBD');

//**********************************************************************//
//Déclaration des prototypes                                            //
//**********************************************************************//

// ICI MODIFICATION
// Méthode GET    // à modifier en fonction des paramètres
dcl-pr GET_EMPLOYE extproc('GET_EMPLOYE');
    http_code int(5);
    http_text char(64);
    p_JSON like(JSON_DATA);
end-pr;

// Méthode DELETE
dcl-pr DELETE_EMPLOYE extproc('DELETE_EMPLOYE');
    http_code int(5);
    http_text char(64);
    p_JSON like(JSON_DATA);
end-pr;

// Méthode POST
dcl-pr POST_EMPLOYE extproc('POST_EMPLOYE');
    http_code int(5);
    http_text char(64);
    p_JSON like(JSON_DATA);
end-pr;

// Méthode PUT
dcl-pr PUT_EMPLOYE extproc('PUT_EMPLOYE');
http_code int(5);
    http_text char(64);
    p_JSON like(JSON_DATA);
end-pr;

dcl-pr QCmdExc extpgm('QSYS/QCMDEXC');
  Cmd char(32702) options(*varsize) const;
  Len packed(15:5) const;
end-pr;

// Extraction d'infos job
dcl-pr QUsrJobI extpgm('QSYS/QUSRJOBI');
  RcvVar like(JOBI0400) options(*varsize) const;
  VarLen bindec(9:0) const;
  FmtNam char(8) const;
  JobNam char(26) const;
  IntJbI char(16) const;
  ErrCod char(4) const;
end-pr;

//Gestion des erreurs
Dcl-PR Qmhsndpm  extpgm('QSYS/QMHSNDPM');
  MsgId          Char(7)    const;
  MsgF           Char(20)   const;
  MsgDta         Char(512)  options(*varsize) const;
  MsgDtaLen      Bindec(9:0)  const;
  MsgType        Char(10)   const;
  PgmQ           Char(10)   const;
  Stk            Char(4)    const;
  MsgKey         Char(4)    const;
  ApiErr         Char(4)    const;
  CSEntLn        Char(4)    options(*nopass) const;
  CSEntQual      Char(20)   options(*nopass) const;
  DPMSWT         Bindec(9:0)  options(*nopass) const;
End-PR;
//
Dcl-PR Qmhrcvpm  extpgm('QSYS/QMHRCVPM');
  RcvM0200       Char(688)  options(*varsize) const;
  FmtLen         Bindec(9:0)  const;
  FmtNam         Char(8)    const;
  PgmQ           Char(10)   const;
  Stk            Char(4)    const;
  MsgType        Char(10)   const;
  MsgKey         Char(4)    const;
  Wait           Char(4)    const;
  Act            Char(10)   const;
  ApiErr         Char(4)    const;
End-PR;
//
Dcl-DS RcvM0200  inz;
  BytRtn         Bindec(4:0)  Pos(1);
  BytAvl         Bindec(4:0)  Pos(5);
  MsgSev         Bindec(4:0)  Pos(9);
  MsgId          Char(7)    Pos(13);
  MsgTyp         Char(2)    Pos(20);
  MsgKey         Char(4)    Pos(22);
  MsgFNM         Char(10)   Pos(26);
  MsgFLS         Char(10)   Pos(36);
  MsgFLU         Char(10)   Pos(46);
  SndJob         Char(10)   Pos(56);
  SndUsr         Char(10)   Pos(66);
  SndNbr         Char(6)    Pos(76);
  SndPgm         Char(12)   Pos(82);
  SndDat         Char(7)    Pos(98);
  SndTim         Char(6)    Pos(105);
  DtaLnr         Bindec(4:0)  Pos(153);
  DtaLna         Bindec(4:0)  Pos(157);
  MsgLnr         Bindec(4:0)  Pos(161);
  MsgLna         Bindec(4:0)  Pos(165);
  HlpLnr         Bindec(4:0)  Pos(169);
  HlpLna         Bindec(4:0)  Pos(173);
  MsgDta         Varchar(512);
End-DS;


//**********************************************************************//
// Déclaration des data-structures                                      //
//**********************************************************************//

Dcl-DS *N  PSDS;
  wk_NomPgm      Char(10)   Pos(1);
  wk_PgmErI      Char(7)    Pos(40);
  wk_PgmLib      Char(10)   Pos(81);
  wk_PgmErM      Char(80)   Pos(91);
  wk_PgmDt8      Char(8)    Pos(191);
  wk_NomJob      Char(10)   Pos(244);
  wk_NomUser     Char(10)   Pos(254);
  wk_NomNbr      Char(6)    Pos(264);
  wk_CurUsr      Char(10)   Pos(358);
End-DS;

dcl-ds JOBI0400;
  RtnByt bindec(9:0) pos(1);
  AvlByt bindec(9:0) pos(5);
  CCSID  bindec(9:0) pos(301);
  ASPGIE like(FmtGie) DIM(1) pos(575);
end-ds;

dcl-ds FmtGie;
  ASPGrp char(10);
  Reserved char(6);
end-ds;

//**********************************************************************//
// Déclaration des variables                                            //
//**********************************************************************//

DCL-S RPLY sqltype(CLOB:16773100);
DCL-S NullInd bindec(4:0);

DCL-S JSON sqltype(CLOB:32768);

// Variable à utiliser dans la construction du JSON ( POST ET PUT)
DCL-S id zoned(5:0);
DCL-S nom varchar(50);
DCL-S prenom varchar(50);
DCL-S age zoned(3:0);
DCL-S poste varchar(50);

//
DCL-S http_code int(5);
DCL-S http_text char(64);
//
DCL-S p_JSON like(JSON_DATA);
//
DCL-S url varchar(2048) CCSID(1208);
//
DCL-s CurPwd char(10);
//
DCL-s Cmd varchar(32702);

//**********************************************************************//
//                                                                      //
//**********************************************************************//
DCL-PI *n;
  METHOD    CHAR(6);
  MODE      CHAR(7);
END-PI;


//**********************************************************************//
//Consignes de compilation SQL                                          //
//**********************************************************************//
DOU 1 = 1;
  //Gestion du contrôle de validation, des performances, etc ...
  EXEC SQL
   SET OPTION COMMIT = *NONE, ALWCPYDTA = *OPTIMIZE, CLOSQLCSR = *ENDMOD,
   DYNUSRPRF = *OWNER, DATFMT = *ISO, TIMFMT = *ISO;

  //**********************************************************************//
  //               T R A I T E M E N T    P R I N C I P A L               //
  //**********************************************************************//

  //Contrôle des paramétres (en entrée) ...  ON TOUCHE PAS                //
  If %addr(METHOD)=*NULL;
    *InLr=*On;
    MsgId='CPD0172';
    MsgDta=X'00000014'+wk_NomPgm+wk_PgmLib;
  ElseIf METHOD=*BLANKS;
    *InLr=*On;
    MsgId='CPD0071';
    MsgDta=X'0000000A'+'METHOD';
  Else;
  EndIf;
  If *InLr;
    Leave;
  EndIf;

  If %addr(MODE)=*NULL;
    *InLr=*On;
    MsgId='CPD0172';
    MsgDta=X'00000014'+wk_NomPgm+wk_PgmLib;
  ElseIf MODE=*BLANKS;
    *InLr=*On;
    MsgId='CPD0071';
    MsgDta=X'0000000A'+'MODE';
  Else;
  EndIf;
  If *InLr;
    Leave;
  EndIf;

  If %parms()<>2;
    *InLr=*On;
    MsgId='CPD0172';
    MsgDta=X'00000014'+wk_NomPgm+wk_PgmLib;
  Else;
  EndIf;
  If *InLr;
    Leave;
  EndIf;

  //-----------------------------------------------------------------------//


  //Sélection du traitement en fonction de la méthode (à tester)          //

  // Décommenter quand vous avez besoin d'utiliser la méthode !
  select;
  When %xlate('acdeghlopstu':'ACDEGHLOPSTU':%trim(METHOD))='GET';
    ExSr GET;
  When %xlate('acdeghlopstu':'ACDEGHLOPSTU':%trim(METHOD))='DELETE';
  ExSr DELETE;
  When %xlate('acdeghlopstu':'ACDEGHLOPSTU':%trim(METHOD))='POST';
   ExSr POST;
  When %xlate('acdeghlopstu':'ACDEGHLOPSTU':%trim(METHOD))='PUT';
  ExSr PUT;
  Other;
    *InLr=*On;
    MsgId='CPD0084';
    MsgDta=X'00000014'+'METHOD    '+METHOD;
  EndSl;
  If *InLr;
    Leave;
  EndIf;
  leave;
//Fin du programme.                                                     //

ENDDO;
If NOT *InLr;
  IF CCSID=65535;
  Endif;
  Cmd='CHGJOB JOB(*) CCSID(65535)';
  QCmdExc(Cmd:%len(Cmd));
  *InLr=%error();
ENDIF;
If *InLr;
  EXSR *PsSR;
Endif;
If NOT *InLr;
  *InLr = *On;
Endif;


//**********************************************************************//
//          F I N    T R A I T E M E N T    P R I N C I P A L           //
//**********************************************************************//
//                                                                      //
//                                                                      //
//**********************************************************************//
//Sous-programme intitial                                               //
//**********************************************************************//

BegSR *InzSr;    // ON TOUCHE PAS

  Clear JOBI0400;
  CallP(e) QUsrJobI(JOBI0400:%size(JOBI0400):'JOBI0400':'*':*blank:*loval);
  If  %error();
    *InLr=*On;
  ElseIf CCSID=65535;
    Cmd='CHGJOB JOB(*) CCSID(297)';
    CallP(e) QCmdExc(Cmd:%len(Cmd));
    *InLr=%error();
  Else;
  EndIf;
  If *InLr;
    ExSR *PsSR;
  EndIf;

EndSR;

//**********************************************************************//
// Méthode - GET                                                        //
//**********************************************************************//

BegSR GET;      // ICI MODIFICATION

  select;
  When %xlate('begmprsvw':'BEGMPRSVW':MODE)='*WEBSRV';
    // la on modifie l'url en fonction du lien que vous allez créer
    //Coder ici URL = ...
    //fin-modif
    clear curpwd;
    DoU %error() or CurPwd<>*blanks;
      Dsply(e) 'Veuillez saisir votre mot de passe :' '*EXT' CurPwd;
    EndDo;
    *InLr=%error();
    If *InLr;
      LeaveSr;
    EndIf;
    //
    Clear RPLY;

    // on touche pas
    exec sql
     SET :RPLY:NullInd=QSYS2.HTTP_GET(:Url, JSON_OBJECT(
     'header' VALUE CONCAT('Authorization,Basic ',
     QSYS2.BASE64_ENCODE(CAST(RTRIM(:wk_CurUsr) CONCAT ':' CONCAT
     RTRIM(:CurPwd) as varchar(21) CCSID 1208)))
     RETURNING CLOB(10K) CCSID 1208));
    If (SqlCod=-204 and %scan('QSYS2':SqlErm)<>*zero);
      exec sql
       SET :RPLY:NullInd=SYSTOOLS.HTTPGETCLOB(:Url, CAST(
       '<httpHeader><header name="Authorization" value="Basic ' CONCAT
       SYSTOOLS.BASE64ENCODE(CAST(RTRIM(:wk_CurUsr) CONCAT ':' CONCAT
        RTRIM(:CurPwd) as varchar(21) CCSID 1208)) CONCAT '"/></httpHeader>'
       AS CLOB(10K) CCSID 1208));
    EndIf;

    *InLr=(SqlCod<>*zero);
    If *InLr;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
      LeaveSr;
    ElseIf NullInd<>*zero;
      Clear RPLY;
    Else;
    EndIf;
  //
  When %xlate('begmprsvw':'BEGMPRSVW':MODE)='*SRVPGM';

    Clear http_code;
    Clear http_text;
    Clear p_JSON;

    // à modifier
    //indice CallP(e) GET_EMPL...;
    CallP(e) GET_EMPLOYE(http_code:http_text:p_JSON);

    // fin-modif

    *InLr=%error();
    If *InLr;
      LeaveSr;
    EndIf;

  Other;
    *InLr=*On;
    MsgId='CPD0084';
    MsgDta=X'00000014'+'MODE      '+MODE;
  EndSl;
EndSR;


//**********************************************************************//
// Méthode - DELETE                                                     //
//**********************************************************************//

BegSR DELETE;
  //                                                                      //
  idEmploye = 1;
  //
  select;
  When %xlate('begmprsvw':'BEGMPRSVW':MODE)='*WEBSRV';
    // coder ici l'url

    //
    clear curpwd;
    DoU %error() or CurPwd<>*blanks;
      Dsply(e) 'Veuillez saisir votre mot de passe :' '*EXT' CurPwd;
    EndDo;
    *InLr=%error();
    If *InLr;
      LeaveSr;
    EndIf;
    //
    Clear RPLY;
    exec sql
     SET :RPLY:NullInd=QSYS2.HTTP_DELETE(:Url, JSON_OBJECT(
     'header' VALUE CONCAT('Authorization,Basic ',
     QSYS2.BASE64_ENCODE(CAST(RTRIM(:wk_CurUsr) CONCAT ':' CONCAT
     RTRIM(:CurPwd) as varchar(21) CCSID 1208)))
     ));
    If (SqlCod=-204 and %scan('QSYS2':SqlErm)<>*zero);
      exec sql
       SET :RPLY:NullInd=SYSTOOLS.HTTPDELETECLOB(:Url, CAST(
       '<httpHeader><header name="Authorization" value="Basic ' CONCAT
       SYSTOOLS.BASE64ENCODE(CAST(RTRIM(:wk_CurUsr) CONCAT ':' CONCAT
        RTRIM(:CurPwd) as varchar(21) CCSID 1208)) CONCAT '"/></httpHeader>'
       AS CLOB(10K) CCSID 1208));
    EndIf;
    *InLr=(SqlCod<>*zero);
    If *InLr;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
      LeaveSr;
    ElseIf NullInd<>*zero;
      Clear RPLY;
    Else;
    EndIf;
  //
  When %xlate('begmprsvw':'BEGMPRSVW':MODE)='*SRVPGM';
    //
    Clear http_code;
    Clear http_text;

    // à modifier
    //indice  : CallP(e) DELETE_EMPL...;
    CallP(e) DELETE_EMPLOYE(http_code:http_text:p_JSON);
    If *InLr;
      LeaveSr;
    EndIf;

  Other;
    *InLr=*On;
    MsgId='CPD0084';
    MsgDta=X'00000014'+'MODE      '+MODE;
  EndSl;
//                                                                      //
EndSR;


//**********************************************************************//
// Méthode - POST
//**********************************************************************//

BegSR POST;
  ID = 1;
  NOM = 'Xavier';
  PRENOM = 'Professeur X';
  AGE = 54;
  POSTE = 'Archange IBM i 1993 - 2023';

  EXEC SQL
   SET :JSON=JSON_OBJECT(
      KEY 'ID' VALUE ID,
      KEY 'NOM' VALUE NOM,
      KEY 'PRENOM' VALUE PRENOM,
      KEY 'AGE' VALUE AGE,
      KEY 'ID' VALUE POSTE
      ABSENT ON NULL RETURNING CLOB(32K) FORMAT JSON);

  *InLr=(SqlCod<>*zero);

  If *InLr;
  MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
    %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
    MsgDta=SqlErm;
    LeaveSr;
  EndIf;
  //
  select;
  When %xlate('begmprsvw':'BEGMPRSVW':MODE)='*WEBSRV';
    // coder l'url
    // coder ici
    //
    clear curpwd;
    DoU %error() or CurPwd<>*blanks;
      Dsply(e) 'Veuillez saisir votre mot de passe :' '*EXT' CurPwd;
    EndDo;
    *InLr=%error();
    If *InLr;
      LeaveSr;
    EndIf;
    //
    Clear RPLY;
    exec sql
     SET :RPLY:NullInd=QSYS2.HTTP_POST(:Url,
     CAST(:JSON AS CLOB(2G) CCSID 1208),
     JSON_OBJECT('header' VALUE CONCAT('Authorization,Basic ',
     QSYS2.BASE64_ENCODE(CAST(RTRIM(:wk_CurUsr) CONCAT ':' CONCAT
     RTRIM(:CurPwd) as varchar(21) CCSID 1208)))
     RETURNING CLOB(10K) CCSID 1208));
    If (SqlCod=-204 and %scan('QSYS2':SqlErm)<>*zero);
      exec sql
       SET :RPLY:NullInd=SYSTOOLS.HTTPPOSTCLOB(:Url, CAST(
       '<httpHeader><header name="Authorization" value="Basic ' CONCAT
       SYSTOOLS.BASE64ENCODE(CAST(RTRIM(:wk_CurUsr) CONCAT ':' CONCAT
        RTRIM(:CurPwd) as varchar(21) CCSID 1208)) CONCAT '"/></httpHeader>'
       AS CLOB(10K) CCSID 1208),
       CAST(:JSON AS CLOB(2G) CCSID 1208));
    EndIf;
    *InLr=(SqlCod<>*zero);
    If *InLr;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
      LeaveSr;
    ElseIf NullInd<>*zero;
      Clear RPLY;
    Else;
    EndIf;
  //
  When %xlate('begmprsvw':'BEGMPRSVW':MODE)='*SRVPGM';
    //
    Clear http_code;
    Clear http_text;
    //
    CallP(e) POST_EMPLOYE(http_code:http_text:p_JSON);
    // indice CallP(e) Post...


    *InLr=%error();
    If *InLr;
      LeaveSr;
    EndIf;

  Other;
    *InLr=*On;
    MsgId='CPD0084';
    MsgDta=X'00000014'+'MODE      '+MODE;
  EndSl;
//                                                                      //
EndSR;

BegSR PUT;
  idEmploye = 1;
  //                                                                      //
  EXEC SQL
   SET :JSON=JSON_OBJECT(
      // Coder ici la constrcution de votre JSON
   ABSENT ON NULL RETURNING CLOB(32K) FORMAT JSON);


  *InLr=(SqlCod<>*zero);
  If *InLr;
    MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
    %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
    MsgDta=SqlErm;
    LeaveSr;
  EndIf;
  //                                                                      //
  select;
  When %xlate('begmprsvw':'BEGMPRSVW':MODE)='*WEBSRV';
    //
    // coder l'url
    //
    clear curpwd;
    DoU %error() or CurPwd<>*blanks;
      Dsply(e) 'Veuillez saisir votre mot de passe :' '*EXT' CurPwd;
    EndDo;
    *InLr=%error();
    If *InLr;
      LeaveSr;
    EndIf;
    //
    Clear RPLY;
    exec sql
     SET :RPLY:NullInd=QSYS2.HTTP_PUT(:Url,
     CAST(:JSON AS CLOB(2G) CCSID 1208),
     JSON_OBJECT('header' VALUE CONCAT('Authorization,Basic ',
     QSYS2.BASE64_ENCODE(CAST(RTRIM(:wk_CurUsr) CONCAT ':' CONCAT
     RTRIM(:CurPwd) as varchar(21) CCSID 1208)))
     RETURNING CLOB(10K) CCSID 1208));
    If (SqlCod=-204 and %scan('QSYS2':SqlErm)<>*zero);
      exec sql
       SET :RPLY:NullInd=SYSTOOLS.HTTPPUTCLOB(:Url, CAST(
       '<httpHeader><header name="Authorization" value="Basic ' CONCAT
       SYSTOOLS.BASE64ENCODE(CAST(RTRIM(:wk_CurUsr) CONCAT ':' CONCAT
        RTRIM(:CurPwd) as varchar(21) CCSID 1208)) CONCAT '"/></httpHeader>'
       AS CLOB(10K) CCSID 1208),
       CAST(:JSON AS CLOB(2G) CCSID 1208));
    EndIf;
    *InLr=(SqlCod<>*zero);
    If *InLr;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
      LeaveSr;
    ElseIf NullInd<>*zero;
      Clear RPLY;
    Else;
    EndIf;
  //
  When %xlate('begmprsvw':'BEGMPRSVW':MODE)='*SRVPGM';
    //
    Clear http_code;
    Clear http_text;

    CallP(e) PUT_EMPLOYE(idEmploye:http_code:http_text:p_JSON);
    //indice CallP(e) PUT_EMPL;


    *InLr=%error();
    If *InLr;
      LeaveSr;
    EndIf;

  Other;
    *InLr=*On;
    MsgId='CPD0084';
    MsgDta=X'00000014'+'MODE      '+MODE;
  EndSl;
//                                                                      //
EndSR;


