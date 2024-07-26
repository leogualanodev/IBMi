**FREE
//----------------------------------------------------------------------//
//Consignes de compilation : A compiler avec 15                         //
//----------------------------------------------------------------------//

CTL-OPT NOMAIN COPYRIGHT('(C) ARMONIE 2023.') OPTIMIZE(*NONE)
DATFMT(*ISO) TIMFMT(*ISO)
ALLOC(*STGMDL) STGMDL(*INHERIT) THREAD(*CONCURRENT)
PGMINFO(*PCML:*DCLCASE:*MODULE:*V7);

//**********************************************************************//
// Déclaration des constantes                                           //
//**********************************************************************//

DCL-C HTPP_OK 200;
DCL-C HTPP_NOT_FOUND 404;
DCL-C HTPP_SERVER_ERROR 500;

//----------------------------------------------------------------------//
//Consignes de compilation SQL                                          //
//----------------------------------------------------------------------//

//Gestion du contrôle de validation, des performances, etc ..
EXEC SQL
 SET OPTION COMMIT = *CHG , ALWCPYDTA = *OPTIMIZE, CLOSQLCSR = *ENDMOD,
 DYNUSRPRF = *OWNER, DATFMT = *ISO, TIMFMT = *ISO;

//**********************************************************************//
//**********************************************************************//
// METHODE GET (PROCEDURE GET_EMPLOYE)                                  //
//**********************************************************************//
//**********************************************************************//

DCL-PROC GET_EMPLOYE SERIALIZE EXPORT;
  DCL-PI *N;
    http_code int(5);
    http_text char(64);
    p_JSON like(JSON_DATA);
  END-PI;

  //----------------------------------------------------------------------//
  //Déclaration des prototypes                                            //
  //----------------------------------------------------------------------//

  /INCLUDE *LIBL/QRPGLESRC,PSSR_FRE_D

  //----------------------------------------------------------------------//
  //Déclaration des variables                                             //
  //----------------------------------------------------------------------//

  dcl-s JSON sqltype(CLOB:65536);
  dcl-s NIn_CLOB bindec(4:0);
  dcl-s whttp_code like(http_code);
  dcl-s whttp_text like(http_text);

  //**********************************************************************//
  //               T R A I T E M E N T    P R I N C I P A L               //
  //**********************************************************************//
  DOW 1 = 1 ;
    //Initialisation
    http_code = HTPP_SERVER_ERROR;
    http_text = '{}';
    p_JSON = '[]';

    Clear JSON;

    ExSr GET_SR;

    // si erreur...
    If *InLr;
      Leave;
    ElseIf whttp_code<>HTPP_OK;
      http_code=whttp_code;
      http_text=whttp_text;
      Leave;
    EndIf;

    // Si erreur
    If NOT(JSON_LEN>*zero);
      *InLr=*On;
      MsgId='SQL0901';
      MsgDta='*N     '+X'00000000';
      Leave;
    Else;
      p_JSON = %subst(JSON_DATA:1:JSON_LEN);
    EndIf;

    http_code = HTPP_OK;
    leave;
  //Fin de la procedure.
  EndDo;

  If not(*InLr);
    If http_code = HTPP_OK;
      EXEC SQL
       COMMIT;
    Else;
      EXEC SQL
       ROLLBACK;
    EndIf;
    If SqlCod=-7007;
      Clear SqlCA;
      SQLSTATE=*zero;
    ElseIf SqlCod<>*zero;
      *InLr=*On;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
    Else;
    EndIf;
  EndIf;
  If *InLr;
    EXSR *PsSR;
  Endif;
  Return;

  //**********************************************************************//
  //          F I N    T R A I T E M E N T    P R I N C I P A L           //
  //**********************************************************************//

  //**********************************************************************//
  //                                                                      //
  //**********************************************************************//

  BegSr GET_SR;
    whttp_code = HTPP_SERVER_ERROR;
    whttp_text = '{}';

    // Requete pour créer le JSON
    // à modifier
    // indice  : utiliser JSON_ARRAYAGG


    // Coder ici
    EXEC SQL
    SELECT JSON_OBJECT(KEY 'TABLEAU'
      VALUE JSON_ARRAYAGG(
        JSON_OBJECT(
      KEY 'ID' VALUE ID,
      KEY 'NOM' VALUE TRIM(NOM),
      KEY 'PRENOM' VALUE TRIM(PRENOM),
      KEY 'AGE' VALUE TRIM(AGE),
      KEY 'POSTE' VALUE TRIM(POSTE)
      ABSENT ON NULL RETURNING CLOB(32K) FORMAT JSON)))
      INTO :JSON:NIn_CLOB
      FROM employe;

    // -----------------------------------

    // Si erreur SQL
    *InLr=(SqlCod<>*zero and SqlCod<>100);
    If *InLr;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
      LeaveSr;
    ElseIf (SqlCod<>*zero or NIn_CLOB<>*zero);
      JSON_DATA='[]';
      JSON_LEN =%len(%trimR(JSON_DATA));
      NIn_CLOB =*zero;
      whttp_code = HTPP_NOT_FOUND;
      whttp_text = '{"'+%char(whttp_code)+'":"NOT FOUND"}';
      LeaveSr;
    Else;
    EndIf;

    whttp_code = HTPP_OK;
  EndSR;

  //**********************************************************************//
  //Gestion des exceptions - Ne pas toucher                               //
  //**********************************************************************//

  BegSr *PsSr;

    If MsgId=*blanks;
      If %len(MsgDta)>*zero;
        MsgId='CPF9897';
        MsgFNM='QCPFMSG';
        MsgFLU='QSYS';
      Else;
        CallP(e) Qmhrcvpm(RcvM0200:%size(RcvM0200)-2:
            'RCVM0200':'*':*loval:'*LAST':*blanks:
            *loval:'*REMOVE':*loval);
        If %error();
          MsgId='CAE0031';
          MsgDta='QMHRCVPM';
          MsgFNM='QCPFMSG';
          MsgFLU='QSYS';
        ElseIf MsgId<>*blanks;
          MsgDta=%subst(RcvM0200:1+%size(RcvM0200)-
              %size(MsgDta):DtaLnr);
        EndIf;
        If MsgId=*blanks;
          MsgId='CPF2551';
          Clear MsgDta;
          MsgFNM='QCPFMSG';
          MsgFLU='QSYS';
        EndIf;
      EndIf;
    EndIf;
    //----------------------------------------------------------------------//
    If %addr(http_code)<>*null;
      http_code = HTPP_SERVER_ERROR;
    EndIf;
    If %addr(http_text)<>*null;
      http_text = '{}';
    EndIf;
    If %addr(p_JSON)<>*null;
      p_JSON = '[]';
    EndIf;
    EXEC SQL
     ROLLBACK;
    If SqlCod=-7007;
      Clear SqlCA;
      SQLSTATE=*zero;
    EndIf;
    //----------------------------------------------------------------------//
    DoU MsgId=*blanks;
      If MsgFNM=*blanks;
        If %subst(MsgId:1:3)='SQL' or
              %subst(MsgId:1:3)='JVA' or
              %subst(MsgId:1:3)='RNX';
          MsgFNM='Q'+%subst(MsgId:1:3)+'MSG';
        Else;
          MsgFNM='QCPFMSG';
        EndIf;
      EndIf;
      If MsgFLU=*blanks;
        MsgFLU='*LIBL';
      EndIf;
      CallP(e) Qmhsndpm(MsgId:MsgFNM+MsgFLU:MsgDta:%len(
          MsgDta):'*ESCAPE':'*PGMBDY':X'00000001':
          *blanks:*loval);
      If %error() and
            (MsgId<>'CAE0031' or MsgDta<>'QMHSNDPM' or
            MsgFNM+MsgFLU<>'QCPFMSG   QSYS');
        MsgId='CAE0031';
        MsgDta='QMHSNDPM';
        MsgFNM='QCPFMSG';
        MsgFLU='QSYS';
        Iter;
      EndIf;
      Clear RcvM0200;
    EndDo;

  EndSR;

END-PROC;






//**********************************************************************//
//**********************************************************************//
// METHODE DELETE (PROCEDURE DELETE_EMPLOYE)                            //
//**********************************************************************//
//**********************************************************************//

DCL-PROC DELETE_EMPLOYE SERIALIZE EXPORT;
  DCL-PI *N;
    idEmploye zoned(5:0);
    http_code int(5);
    http_text char(64);
  END-PI;

  //----------------------------------------------------------------------//
  //Déclaration des prototypes                                            //
  //----------------------------------------------------------------------//

  /INCLUDE *LIBL/QRPGLESRC,PSSR_FRE_D

  //----------------------------------------------------------------------//
  //Déclaration des variables                                             //
  //----------------------------------------------------------------------//

  dcl-s whttp_code like(http_code);
  dcl-s whttp_text like(http_text);

  //**********************************************************************//
  //               T R A I T E M E N T    P R I N C I P A L               //
  //**********************************************************************//
  DOW 1 = 1 ;
    //Initialisation
    http_code = HTPP_SERVER_ERROR;
    http_text = '{}';

    ExSr DLT_SR;

    If *InLr;
      Leave;
    ElseIf whttp_code<>HTPP_OK;
      http_code=whttp_code;
      http_text=whttp_text;
      Leave;
    Else;
    EndIf;

    http_code = HTPP_OK;
    leave;
  //Fin de la procedure.
  EndDo;
  If not(*InLr);
    If http_code = HTPP_OK;
      EXEC SQL
       COMMIT;
    Else;
      EXEC SQL
       ROLLBACK;
    EndIf;
    If SqlCod=-7007;
      Clear SqlCA;
      SQLSTATE=*zero;
    ElseIf SqlCod<>*zero;
      *InLr=*On;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
    Else;
    EndIf;
  EndIf;
  If *InLr;
    EXSR *PsSR;
  Endif;
  return;

  //**********************************************************************//
  //          F I N    T R A I T E M E N T    P R I N C I P A L           //
  //**********************************************************************//


  //**********************************************************************//
  // Méthode - DELETE                                                     //
  //**********************************************************************//

  BegSr DLT_SR;
    whttp_code = HTPP_SERVER_ERROR;
    whttp_text = '{}';


    // Coder ici
    EXEC SQL
    DELETE FROM employe
    WHERE id=:idEmploye;


    *InLr=(SqlCod<>*zero and SqlCod<>100);
    If *InLr;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
      LeaveSr;
    ElseIf (SqlCod<>*zero);
      whttp_code = HTPP_NOT_FOUND;
      whttp_text = '{"'+%char(whttp_code)+'":"NOT FOUND"}';
      LeaveSr;
    Else;
    EndIf;

    whttp_code = HTPP_OK;
  EndSR;

  //**********************************************************************//
  // Gestion des exceptions                                               //
  //**********************************************************************//

  BegSr *PsSr;

    If MsgId=*blanks;
      If %len(MsgDta)>*zero;
        MsgId='CPF9897';
        MsgFNM='QCPFMSG';
        MsgFLU='QSYS';
      Else;
        CallP(e) Qmhrcvpm(RcvM0200:%size(RcvM0200)-2:
            'RCVM0200':'*':*loval:'*LAST':*blanks:
            *loval:'*REMOVE':*loval);
        If %error();
          MsgId='CAE0031';
          MsgDta='QMHRCVPM';
          MsgFNM='QCPFMSG';
          MsgFLU='QSYS';
        ElseIf MsgId<>*blanks;
          MsgDta=%subst(RcvM0200:1+%size(RcvM0200)-
              %size(MsgDta):DtaLnr);
        EndIf;
        If MsgId=*blanks;
          MsgId='CPF2551';
          Clear MsgDta;
          MsgFNM='QCPFMSG';
          MsgFLU='QSYS';
        EndIf;
      EndIf;
    EndIf;
    //----------------------------------------------------------------------//
    If %addr(http_code)<>*null;
      http_code = HTPP_SERVER_ERROR;
    EndIf;
    If %addr(http_text)<>*null;
      http_text = '{}';
    EndIf;
    EXEC SQL
     ROLLBACK;
    If SqlCod=-7007;
      Clear SqlCA;
      SQLSTATE=*zero;
    EndIf;
    //----------------------------------------------------------------------//
    DoU MsgId=*blanks;
      If MsgFNM=*blanks;
        If %subst(MsgId:1:3)='SQL' or
              %subst(MsgId:1:3)='JVA' or
              %subst(MsgId:1:3)='RNX';
          MsgFNM='Q'+%subst(MsgId:1:3)+'MSG';
        Else;
          MsgFNM='QCPFMSG';
        EndIf;
      EndIf;
      If MsgFLU=*blanks;
        MsgFLU='*LIBL';
      EndIf;
      CallP(e) Qmhsndpm(MsgId:MsgFNM+MsgFLU:MsgDta:%len(
          MsgDta):'*ESCAPE':'*PGMBDY':X'00000001':
          *blanks:*loval);
      If %error() and
            (MsgId<>'CAE0031' or MsgDta<>'QMHSNDPM' or
            MsgFNM+MsgFLU<>'QCPFMSG   QSYS');
        MsgId='CAE0031';
        MsgDta='QMHSNDPM';
        MsgFNM='QCPFMSG';
        MsgFLU='QSYS';
        Iter;
      EndIf;
      Clear RcvM0200;
    EndDo;

  EndSR;

END-PROC;





//**********************************************************************//
//**********************************************************************//
// METHODE POST (PROCEDURE POST_EMPLOYE)                             //
//**********************************************************************//
//**********************************************************************//

DCL-PROC POST_EMPLOYE SERIALIZE EXPORT;
  DCL-PI *N;
    p_JSON like(JSON_DATA);
    http_code int(5);
    http_text char(64);
  END-PI;

  //----------------------------------------------------------------------//
  //Déclaration des prototypes                                            //
  //----------------------------------------------------------------------//

  /INCLUDE *LIBL/QRPGLESRC,PSSR_FRE_D




  //----------------------------------------------------------------------//
  //Déclaration des data-structures                                       //
  //----------------------------------------------------------------------//

  DCL-DS EMPLOYE EXTNAME('EMPLOYE') END-DS;

  //----------------------------------------------------------------------//
  //Déclaration des variables                                             //
  //----------------------------------------------------------------------//

  DCL-S JSON sqltype(CLOB:32768);
  DCL-S NIn_CLOB bindec(4:0);

  DCL-S whttp_code like(http_code);
  DCL-S whttp_text like(http_text);

  //**********************************************************************//
  //               T R A I T E M E N T    P R I N C I P A L               //
  //**********************************************************************//
  DOW 1=1;
    //Initialisation
    http_code = HTPP_SERVER_ERROR;
    http_text = '{}';

    JSON_DATA=p_JSON;
    JSON_LEN=%len(%trimR(JSON_DATA));

    ExSr POST_SR;

    If *InLr;
      Leave;
    ElseIf whttp_code<>HTPP_OK;
      http_code=whttp_code;
      http_text=whttp_text;
      Leave;
    Else;
    EndIf;

    http_code = HTPP_OK;
    leave;
  //Fin de la procedure.
  ENDDO;
  If not(*InLr);
    If http_code = HTPP_OK;
      EXEC SQL
       COMMIT;
    Else;
      EXEC SQL
       ROLLBACK;
    EndIf;
    If SqlCod=-7007;
      Clear SqlCA;
      SQLSTATE=*zero;
    ElseIf SqlCod<>*zero;
      *InLr=*On;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
    Else;
    EndIf;
  EndIf;
  If *InLr;
    EXSR *PsSR;
  Endif;
  RETURN;

  //**********************************************************************//
  //          F I N    T R A I T E M E N T    P R I N C I P A L           //
  //**********************************************************************//

  //**********************************************************************//
  //                                                                      //
  //**********************************************************************//

  BegSr POST_SR;
    whttp_code = HTPP_SERVER_ERROR;
    whttp_text = '{}';


    // Récupération des données dans le JSON
    EXEC SQL
    SET
      :NOM = JSON_VALUE(:JSON FORMAT JSON, '$.NOM'
      RETURNING VARCHAR(50)),
      :PRENOM = JSON_VALUE(:JSON FORMAT JSON, '$.PRENOM'
      RETURNING VARCHAR(50)),
      :AGE = JSON_VALUE(:JSON FORMAT JSON, '$.AGE'
      RETURNING VARCHAR(3)),
      :POSTE = JSON_VALUE(:JSON FORMAT JSON, '$.POSTE'
      RETURNING VARCHAR(50));

    // Insertion des données dans la table EMPLOYE
    EXEC SQL
    INSERT INTO employe( nom , prenom , age , poste)
    VALUES (:nom , :prenom , :age , :poste);

    // Gestion erreur
    *InLr=(SqlCod<>*zero);
    If *InLr;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
      LeaveSr;
    EndIf;

    whttp_code = HTPP_OK;
  EndSR;

  //**********************************************************************//
  //Gestion des exceptions                                                //
  //**********************************************************************//

  BegSr *PsSr;

    If MsgId=*blanks;
      If %len(MsgDta)>*zero;
        MsgId='CPF9897';
        MsgFNM='QCPFMSG';
        MsgFLU='QSYS';
      Else;
        CallP(e) Qmhrcvpm(RcvM0200:%size(RcvM0200)-2:
            'RCVM0200':'*':*loval:'*LAST':*blanks:
            *loval:'*REMOVE':*loval);
        If %error();
          MsgId='CAE0031';
          MsgDta='QMHRCVPM';
          MsgFNM='QCPFMSG';
          MsgFLU='QSYS';
        ElseIf MsgId<>*blanks;
          MsgDta=%subst(RcvM0200:1+%size(RcvM0200)-
              %size(MsgDta):DtaLnr);
        EndIf;
        If MsgId=*blanks;
          MsgId='CPF2551';
          Clear MsgDta;
          MsgFNM='QCPFMSG';
          MsgFLU='QSYS';
        EndIf;
      EndIf;
    EndIf;
    //----------------------------------------------------------------------//
    If %addr(http_code)<>*null;
      http_code = HTPP_SERVER_ERROR;
    EndIf;
    If %addr(http_text)<>*null;
      http_text = '{}';
    EndIf;
    EXEC SQL
     ROLLBACK;
    If SqlCod=-7007;
      Clear SqlCA;
      SQLSTATE=*zero;
    EndIf;
    //----------------------------------------------------------------------//
    DoU MsgId=*blanks;
      If MsgFNM=*blanks;
        If %subst(MsgId:1:3)='SQL' or
              %subst(MsgId:1:3)='JVA' or
              %subst(MsgId:1:3)='RNX';
          MsgFNM='Q'+%subst(MsgId:1:3)+'MSG';
        Else;
          MsgFNM='QCPFMSG';
        EndIf;
      EndIf;
      If MsgFLU=*blanks;
        MsgFLU='*LIBL';
      EndIf;
      CallP(e) Qmhsndpm(MsgId:MsgFNM+MsgFLU:MsgDta:%len(
          MsgDta):'*ESCAPE':'*PGMBDY':X'00000001':
          *blanks:*loval);
      If %error() and
            (MsgId<>'CAE0031' or MsgDta<>'QMHSNDPM' or
            MsgFNM+MsgFLU<>'QCPFMSG   QSYS');
        MsgId='CAE0031';
        MsgDta='QMHSNDPM';
        MsgFNM='QCPFMSG';
        MsgFLU='QSYS';
        Iter;
      EndIf;
      Clear RcvM0200;
    EndDo;

  EndSR;

END-PROC;

//**********************************************************************//
//**********************************************************************//
// METHODE PUT (PROCEDURE PUT_EMPLOYE)                               //
//**********************************************************************//
//**********************************************************************//

DCL-PROC PUT_EMPLOYE SERIALIZE EXPORT;
  DCL-PI *N;
    idEmploye zoned(5:0);
    p_JSON like(JSON_DATA);
    http_code int(5);
    http_text char(64);
  END-PI;

  //----------------------------------------------------------------------//
  //Déclaration des prototypes                                            //
  //----------------------------------------------------------------------//

  /INCLUDE *LIBL/QRPGLESRC,PSSR_FRE_D

  //----------------------------------------------------------------------//
  //Déclaration des data-structures                                       //
  //----------------------------------------------------------------------//

  DCL-DS EMPLOYE EXTNAME('EMPLOYE') END-DS;


  //----------------------------------------------------------------------//
  //Déclaration des variables                                             //
  //----------------------------------------------------------------------//
  DCL-S ptr_NIn pointer inz(%addr(NullInd));
  DCL-S NullInd bindec(4:0) dim(9);

  DCL-S JSON sqltype(CLOB:32768);
  DCL-S NIn_CLOB bindec(4:0);

  DCL-S whttp_code like(http_code);
  DCL-S whttp_text like(http_text);

  //**********************************************************************//
  //               T R A I T E M E N T    P R I N C I P A L               //
  //**********************************************************************//
  DOW 1=1;
    //Initialisation
    http_code = HTPP_SERVER_ERROR;
    http_text = '{}';

    JSON_DATA=p_JSON;
    JSON_LEN=%len(%trimR(JSON_DATA));

    ExSr PUT_SR;

    If *InLr;
      Leave;
    ElseIf whttp_code<>HTPP_OK;
      http_code=whttp_code;
      http_text=whttp_text;
      Leave;
    Else;
    EndIf;

    http_code = HTPP_OK;
    leave;
  //Fin de la procedure.
  ENDDO;
  If not(*InLr);
    If http_code = HTPP_OK;
      EXEC SQL
       COMMIT;
    Else;
      EXEC SQL
       ROLLBACK;
    EndIf;
    If SqlCod=-7007;
      Clear SqlCA;
      SQLSTATE=*zero;
    ElseIf SqlCod<>*zero;
      *InLr=*On;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
    Else;
    EndIf;
  EndIf;
  If *InLr;
    EXSR *PsSR;
  Endif;
  RETURN;

  //**********************************************************************//
  //          F I N    T R A I T E M E N T    P R I N C I P A L           //
  //**********************************************************************//

  //**********************************************************************//
  //                                                                      //
  //**********************************************************************//

  BegSr PUT_SR;
    whttp_code = HTPP_SERVER_ERROR;
    whttp_text = '{}';

    // Récupération des données dans le JSON
    EXEC SQL
    SET :NOM=JSON_VALUE(:JSON FORMAT JSON , '$.NOM' RETURNING VARCHAR(50)),
    :PRENOM=JSON_VALUE (:JSON FORMAT JSON , '$.PRENOM' RETURNING VARCHAR(50)),
    :AGE=JSON_VALUE (:JSON FORMAT JSON , '$.AGE' RETURNING VARCHAR(3)),
    :POSTE=JSON_VALUE (:JSON FORMAT JSON , '$.POSTE' RETURNING VARCHAR(50));


    // Modifier la table EMPLOYE
    EXEC SQL
    UPDATE EMPLOYE SET
    NOM=:EMPLOYE.NOM,
    PRENOM=:EMPLOYE.PRENOM,
    AGE=:EMPLOYE.AGE,
    POSTE=:EMPLOYE.POSTE
    WHERE ID = :idEmploye;


    *InLr=(SqlCod<>*zero and SqlCod<>100);

    // Si Erreur...
    If *InLr;
      MsgId='SQL'+%subst(%editC(%abs(SqlCod):'X'):
      %len(SqlCod)-%size(MsgId)+%len('SQL')+1);
      MsgDta=SqlErm;
      LeaveSr;
    EndIf;

    whttp_code = HTPP_OK;
  EndSR;

  //**********************************************************************//
  //Gestion des exceptions                                                //
  //**********************************************************************//

  BegSr *PsSr;

    If MsgId=*blanks;
      If %len(MsgDta)>*zero;
        MsgId='CPF9897';
        MsgFNM='QCPFMSG';
        MsgFLU='QSYS';
      Else;
        CallP(e) Qmhrcvpm(RcvM0200:%size(RcvM0200)-2:
            'RCVM0200':'*':*loval:'*LAST':*blanks:
            *loval:'*REMOVE':*loval);
        If %error();
          MsgId='CAE0031';
          MsgDta='QMHRCVPM';
          MsgFNM='QCPFMSG';
          MsgFLU='QSYS';
        ElseIf MsgId<>*blanks;
          MsgDta=%subst(RcvM0200:1+%size(RcvM0200)-
              %size(MsgDta):DtaLnr);
        EndIf;
        If MsgId=*blanks;
          MsgId='CPF2551';
          Clear MsgDta;
          MsgFNM='QCPFMSG';
          MsgFLU='QSYS';
        EndIf;
      EndIf;
    EndIf;
    //----------------------------------------------------------------------//
    If %addr(http_code)<>*null;
      http_code = HTPP_SERVER_ERROR;
    EndIf;
    If %addr(http_text)<>*null;
      http_text = '{}';
    EndIf;
    EXEC SQL
     ROLLBACK;
    If SqlCod=-7007;
      Clear SqlCA;
      SQLSTATE=*zero;
    EndIf;
    //----------------------------------------------------------------------//
    DoU MsgId=*blanks;
      If MsgFNM=*blanks;
        If %subst(MsgId:1:3)='SQL' or
              %subst(MsgId:1:3)='JVA' or
              %subst(MsgId:1:3)='RNX';
          MsgFNM='Q'+%subst(MsgId:1:3)+'MSG';
        Else;
          MsgFNM='QCPFMSG';
        EndIf;
      EndIf;
      If MsgFLU=*blanks;
        MsgFLU='*LIBL';
      EndIf;
      CallP(e) Qmhsndpm(MsgId:MsgFNM+MsgFLU:MsgDta:%len(
          MsgDta):'*ESCAPE':'*PGMBDY':X'00000001':
          *blanks:*loval);
      If %error() and
            (MsgId<>'CAE0031' or MsgDta<>'QMHSNDPM' or
            MsgFNM+MsgFLU<>'QCPFMSG   QSYS');
        MsgId='CAE0031';
        MsgDta='QMHSNDPM';
        MsgFNM='QCPFMSG';
        MsgFLU='QSYS';
        Iter;
      EndIf;
      Clear RcvM0200;
    EndDo;

  EndSR;

END-PROC;


