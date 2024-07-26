//
        dcl-pr Qmhsndpm extpgm('QSYS/QMHSNDPM');
          MsgId char(7) const;
          MsgF char(20) const;
          MsgDta char(512) options(*varsize) const;
          MsgDtaLen bindec(9:0) const;
          MsgType char(10) const;
          PgmQ char(10) const;
          Stk char(4) const;
          MsgKey char(4) const;
          ApiErr char(4) const;
          CSEntLn char(4) options(*nopass) const;
          CSEntQual char(20) options(*nopass) const;
          DPMSWT bindec(9:0) options(*nopass) const;
        end-pr;
      //
        dcl-pr Qmhrcvpm extpgm('QSYS/QMHRCVPM');
          RcvM0200 char(688) options(*varsize) const;
          FmtLen bindec(9:0) const;
          FmtNam char(8) const;
          PgmQ char(10) const;
          Stk char(4) const;
          MsgType char(10) const;
          MsgKey char(4) const;
          Wait char(4) const;
          Act char(10) const;
          ApiErr char(4) const;
        end-pr;
      //
        dcl-ds RcvM0200 inz;
          BytRtn bindec(9:0) pos(1);
          BytAvl bindec(9:0) pos(5);
          MsgSev bindec(9:0) pos(9);
          MsgId char(7) pos(13);
          MsgTyp char(2) pos(20);
          MsgKey char(4) pos(22);
          MsgFNM char(10) pos(26);
          MsgFLS char(10) pos(36);
          MsgFLU char(10) pos(46);
          SndJob char(10) pos(56);
          SndUsr char(10) pos(66);
          SndNbr char(6) pos(76);
          SndPgm char(10) pos(82);
      //
          SndDat char(7) pos(98);
          SndTim char(6) pos(105);
      //
          DtaLnr bindec(9:0) pos(153);
          DtaLna bindec(9:0) pos(157);
          MsgLnr bindec(9:0) pos(161);
          MsgLna bindec(9:0) pos(165);
          HlpLnr bindec(9:0) pos(169);
          HlpLna bindec(9:0) pos(173);
          MsgDta varchar(512) pos(177);
        end-ds;
      //


