      ********************************************************************
      *                                                                  *
      *  DSPO7072 - DSP SR Agent for HISO <-> HISO   LEONGHY/25-11-2006  *
      *  ** Cater for reversal                                           *
      *  ** Keys = APK1                                                  *
      *  ** Message contain DSP Header                                   *
      *                                                                  *
      *  PEP : DSPO7072                                                  *
      *  MOD : DSPO7072 - SR Agent for HISO <-> HISO                     *
      *        DSPS0002 - Search route name                              *
      *                                                                  *
      *                                                                  *
      * Compilation Guide :                                              *
      *      1) Compile module with *VARCHAR                             *
      *      2) Create program                                           *
      *         Option :(i)   Bind *BNDDIR DSPO7070(Module : DSPO7072)   *
      *                                            (SRVPGM : DSPSSRV01)  *
      *                                                                  *
      *                                                                  *
      *  Enhancement:                                                    *
      *                                                                  *
      *                                                                  *
      *                  (C) Copyright Silverlake System Sdn. Bhd. 1997. *
      ********************************************************************
      /EJECT
      ********************************************************************
      * LAST CHANGED :
      * CHANGE ID   DATE      DESCRIPTION
      * ---------   ----      -----------
JOEY  * J0025       22/12/06  Fix Error:Cater for Reversal.
      *
      ********************************************************************
      /EJECT
      ********************************************************************
      * File                                                             *
      ********************************************************************
     FDSPPARL0  IF   E           K DISK    USROPN                               Parameter file
     FDSPHHLL0  UF A E           K DISK    USROPN                               Subrouter log
      ********************************************************************
      * Copy Books                                                       *
      ********************************************************************
     D/COPY QDSPCOPY,DSPDBAS01
      * Search route
     D/COPY QDSPCOPY,DSPDOPT01
      * Swap log file
     D/COPY QDSPCOPY,DSPDOPT07
      * Convert BITMAP/HEX
     D/COPY QDSPCOPY,DSPDOPT08
      * Convert Pack/Unpack
     D/COPY QDSPCOPY,DSPDOPT14
      * DSPSLGHDR
     D/COPY QDSPCOPY,DSPDOPT09
      * DSPSHDR
     D/COPY QDSPCOPY,DSPDOPT13
      * Service program DSPSSRV01
     D/COPY QDSPCOPY,DSPDSRV01
      * Program exception
     D/COPY QDSPCOPY,DSPDPSSR
      ********************************************************************
      * Datastructure for mapping presentation layer
      ********************************************************************
      * Program Variable
      * ----------------
     D XFLD            S              1    DIM(128)
      *                                                                          -Socket & port no.
     D SKTMSGDS      E DS                  EXTNAME(DSPSKTDS)                    Socket message fmt
     D  QSKTHDR                1     33                                         Socket header
      *                                                                          -Socket & port no.
      ********************************************************************
      * Parameter entry
      ********************************************************************
     D WPARM           DS
     D  WFID                          1                                         File id
     D  WTRACE                        1                                         Trace no
     D  WRNAM                        10                                         Route name
     D  WRLIB                        10                                         Route lib
     D  WJID                         10                                         Job id
     D  WJSQN                         3  0                                      Job sequence
     D  WLEN                          5  0                                      Message length
     D  WFILLER                      64                                         Filler
     D  WJGRP                         1                                         Job Group
     D  WQTYP                         1                                         Queue Type
      *
      ********************************************************************
      * Data structure
      ********************************************************************
      * General
      * -------
     D WPLEN           DS             2
     D  XLEN                   1      2B 0
      *
     D XDSPMSG         DS
     D XDSPMSG1                1     12
     D XDSPMSG2               13   4096
      *
     D XAPK1DS         DS
     D XFLD37                  1     12
     D XFLD13                 13     16
     D XFLD12                 17     24
     D XFLD3                  25     30
      *
      * Cater for Reverval
     D XFLD90          DS
     D XORGTRNTYP              1      4
     D XORGSEQNUM              5     16
     D XTRNDATE               17     20
     D XTRNTIME               21     28
     D XORGCAPDAT             29     32
     D XFIL                   33     42
      *
      ********************************************************************
      * Constant fields
      ********************************************************************
      * General
      * -------
     D XMYBASELOG      S             10    INZ('DSPHHLL0')                      My base log file
     D XREQ            S              1    INZ(*OFF)                            Request indicator
     D XRSP            S              1    INZ(*ON)                             Response indicator
     D XINIT           S              1    INZ(*ON)
     D XGOODREV        S                   LIKE(I08MSTA) INZ('%-------')
     D XBADREV         S                   LIKE(I08MSTA) INZ('?-------')
     D XGOODRSP        S                   LIKE(I08MSTA) INZ('/-------')
     D XBADRSP         S                   LIKE(I08MSTA) INZ('.REJ7072')
     D XSUSPECT        S                   LIKE(I13MSTA) INZ('?       ')
     D XREVERSAL       S                   LIKE(I08APK2) INZ('*REV')
     D XREVREQ         S                   LIKE(I08MSTA) INZ('&-------')
     D XTREVERSAL      S                   LIKE(I08APK2) INZ('TREV')
      *
     D XFRFMID         S                   LIKE(I13FMID) INZ('BS24')
     D XTOFMID         S                   LIKE(I13FMID) INZ('BS24')
      *
     D XEXCPCD         C                   CONST('A0001')
     D XSRENV          C                   CONST('*EV')
     D XLIBL           C                   CONST('*LIBL     ')
     D XSAF            C                   CONST('SAF')
      *
      * Base24 Msg ID support
     D X420C           C                   CONST('0420')
     D X421C           C                   CONST('0421')
J0025D X430C           C                   CONST('0430')
      *
      ********************************************************************
      * Working fields
      ********************************************************************
      * General
      * -------
     D XMSGIND         S              1    INZ
     D XRRNO           S                   LIKE(I13RRNO)
     D XRTGN           S                   LIKE(I13RTGN)
     D XMSGL           S                   LIKE(QLEN)
     D XMSGO           S           4096
     D XMSGRSPO        S           4096
     D XTTYP           S             10A
     D XSYSYY          S              4S 0
     D XSYSY           S              2S 0
      *
      *
      * Program Variable
      * ----------------
      *
     D XNM1            S              1  0 INZ                                  numeric field
     D XCHAR1          S              1    INZ                                  Alpha numeric field
     D XCHAR6          S              6    INZ                                  Alpha numeric field
     D XCHAR8          S              8    INZ                                  Alpha numeric field
      *
     D XAPK1           S                   LIKE(I08APK1)
     D XAPK2           S                   LIKE(I08APK2)
     D XMSTA           S                   LIKE(I08MSTA)
      *
     D X24MID          S              4
      *
     D ERR             S            128                                         Error
      ********************************************************************
      * Declaration Of Parameters and Key Lists                          *
      ********************************************************************
     C     *ENTRY        PLIST
     C                   PARM                    WPARM
      *
     C     KPARL0        KLIST                                                  DSPPARL0 file
     C                   KFLD                    I04PNAM                        Par name
     C                   KFLD                    I04PITM                        Par name
      *
     C     KSLGL0        KLIST                                                  DSPSLGL0 file
     C                   KFLD                    XAPK1
     C                   KFLD                    XAPK2
      *
      *
      ********************************************************************
      /EJECT
      ********************************************************************
      * Main logic                                                       *
      ********************************************************************
      * Loop until EOJ
     C                   DOW       (QEOJONOF = *OFF)                            Not end of job
      * System request
     C                   IF        QRNAMCMD <> *BLANK
     C                   EXSR      DSPSRCMDQ                                    Receive command Q
     C                   IF        QLEN > *ZEROS and I13HFMID = 'SYSC'          Incomming syscmd ?
     C                   SELECT
     C                   WHEN      (I13MSTA = '*DOWN')                          Shutdown job
     C                   MOVE      *ON           QEOJONOF
     C                   WHEN      (I13MSTA = '*LOAD')                          Load table
     C                   EXSR      DSPLOADTBL
     C                   WHEN      (I13MSTA = '*SWAPLOG')                       Swap log file
     C                   CLOSE     DSPHHLL0
     C                   MOVEL     I13UDTA       QFID                           New file used
     C                   EXSR      DSPSWAPLOG
     C                   OPEN      DSPHHLL0
     C                   WHEN      (I13MSTA = '*TRACE')
     C                   MOVEL     I13UDTA       QTRCONOF                       Trace on/off
     C                   OTHER
     C                   ENDSL
     C                   IF        I13MORE = *ON
     C                   MOVE      'RPYC'        I13HFMID                       Reply commmand type
     C                   EVAL      QKEY = I13SID + I13USER + I13TMID            Back to requester
     C                   EXSR      DSPSSCMDQ                                    Reply command Q
     C                   ENDIF
     C                   ENDIF                                                  QLEN
     C                   ENDIF                                                  QRNAMCMD <> *BLANK
      * Message request
     C                   IF        QEOJONOF = *OFF
     C                   EXSR      DSPMSGIN                                     Read from Queue
     C                   IF        QLEN > *ZEROS                                Incomming message ?
     C                   EXSR      DSPMAIN                                      Main process
     C                   EXSR      DSPMSGOUT                                    send message out
     C                   ENDIF                                                  QLEN
     C                   ENDIF                                                  QEOJONOFf
      *
     C                   ENDDO                                                  QEOJONOFf
      *
     C     ST009         TAG
     C                   CLOSE     DSPHHLL0
     C                   MOVE      *ON           *INLR
     C                   RETURN
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine DSPMSGIN                                              *
      *  Read incoming message                                           *
      ********************************************************************
     C     DSPMSGIN      BEGSR
      *
     C                   CLEAR                   XMSGRSPO                       Clear response
      *
     C                   CLEAR                   DSPHDR                         Clear header
     C                   CLEAR                   DSPMSG                         Clear message
     C                   CLEAR                   DSPSHDR                        Clear message
      *
     C                   EXSR      DSPSRCVQ                                     Receive message
      *
     C                   IF        QLEN > *ZEROS
      *
      * Check whether the message is request or response
     C                   SELECT
     C                   WHEN      (%SUBST(QMSGI:15:4) = '*DSP')
     C                   MOVE      XREQ          XMSGIND                        Request
     C                   MOVEL(P)  QMSGI         DSPMSG                         DSP message
     C                   MOVEL     QDSPHDR       DSPHDR                         Header
      * check for envelope exist
     C                   WHEN      (%SUBST(QMSGI:1:3) = XSRENV)
     C                   MOVE      XREQ          XMSGIND                        Request
     C                   EVAL      DSPSHDR = (%SUBST(QMSGI:1:33))               DSP message
     C                   EVAL      DSPMSG  = (%SUBST(QMSGI:34:4063))            DSP message
     C                   MOVEL     QDSPHDR       DSPHDR                         Header
      *
     C                   OTHER
      *
     C                   MOVEL(P)  QMSGI         DSPMSG                         DSP message
     C                   MOVE      XRSP          XMSGIND                        Response
     C                   ENDSL
     C                   ENDIF
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine DSPMAIN                                               *
      *   Process DSP message                                            *
      ********************************************************************
     C     DSPMAIN       BEGSR
      *
     C                   IF        XMSGIND = XREQ                               Request
      *
     C                   SELECT
     C                   WHEN      (%SUBST(I13MSTA:1:1) = '&')
     C                             OR (%SUBST(QDSPMSG:13:4) = X420C)
     C                             OR (%SUBST(QDSPMSG:13:4) = X421C)
     C                   EXSR      GENREVMSG                                    Generate reversal
     C
     C                   WHEN      (I13MSTA = *BLANKS)
     C                   EXSR      GENREQMSG                                    Generate normal req
     C                   ENDSL
      *
     C                   ELSE                                                   Response
      *
     C                   EXSR      GENRESPONSE                                  Generate response
      *
     C                   ENDIF
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine DSPMSGOUT                                             *
      *  Send message out                                                *
      ********************************************************************
     C     DSPMSGOUT     BEGSR
      *
     C                   IF        XMSGIND = XREQ
      *
      * Get destination queue from I13DSTQ if this fields
      * not equal blank, otherwise search routing table
     C                   IF        (I13DSTQ <> *BLANKS)
     C                   MOVEL(P)  XLIBL         QRLIBI
     C                   MOVEL(P)  I13DSTQ       QRNAMI
     C                   MOVEL     *ON           QFOUND
     C                   ELSE
     C                   EXSR      DSPSSRNM                                     Search route name
     C                   ENDIF
      *
      * Response message will send back to the sender.
     C                   ELSE
     C                   MOVE      *ON           QFOUND
     C                   MOVE      I13XID        QRNAMI
     C                   MOVEL     I13XID        QRLIBI
     C                   ENDIF
      *
     C                   IF        QFOUND = *ON
      *
     C                   IF        (%SUBST(I13MSTA:1:1)) = '?'
     C                   MOVEL     *BLANKS       QRNAMI
     C                   MOVEL     '*END'        QRNAMI
     C                   ENDIF
      *
     C                   MOVEL     QRNAMI        QRNAM
     C                   MOVEL     QRLIBI        QRLIB
     C                   Z-ADD     WLEN          QLEN
      *
     C                   MOVEL(P)  XMSGRSPO      QMSGO                          Send DSP msg
      *
      * Send data to queue
     C                   EXSR      DSPSSNDQ                                     Send message
      *
     C                   ELSE                                                   Route not found
      *
     C                   MOVEL     QDSP0002      QMSGTYP
     C                   MOVE      QDSP0002      QMSGNBR
     C                   EXSR      DSPSSNDQEX                                   Send to pgm except
      *
     C                   ENDIF
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine GENREQMSG                                             *
      *   Generate normal request format                                 *
      ********************************************************************
     C     GENREQMSG     BEGSR
      * check the data format ID
     C                   IF        (I13FMID <> XFRFMID)                         HISO
     C                   EVAL      I13MSTA = '.' + QDSP0008
     C                   EXSR      FMTERROR
     C                   EXSR      WRTSLG                                       Write S/R log
     C                   GOTO      ENDREQMSG
     C                   ENDIF
      *
      * Keep original message
     C                   MOVEL(P)  *BLANKS       XMSGO
     C                   MOVEL(P)  DSPMSG        XMSGO
      *
     C                   MOVEL(P)  *BLANKS       XDSPMSG
     C                   MOVEL(P)  QDSPMSG       XDSPMSG
     C                   EVAL      ERR = DSPUNPKB24(XDSPMSG2)
      *
      * Get the Message ID
     C                   MOVEL(P)  *BLANKS       X24MID
     C                   MOVEL(P)  B24MID        X24MID
      *
     C                   EXSR      CVTREQMSG
      *
     C     ENDREQMSG     TAG
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine CVTREQMSG                                             *
      *  Map to desired message format                                   *
      ********************************************************************
     C     CVTREQMSG     BEGSR
      *
     C                   CLEAR                   XMSGRSPO
     C                   MOVEL(P)  DSPMSG        XMSGRSPO
      *
     C                   EXSR      WRTSLG                                       Write S/R log
      *
     C                   ENDSR
      *
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine WRTSLG                                                *
      *   Write to log file                                              *
      ********************************************************************
     C     WRTSLG        BEGSR
      *
     C                   CLEAR                   DSPSLGRC
      *
J0025C                   SELECT
      * Format Reversal Key
J0025C                   WHEN      (X24MID = X420C OR X24MID =X421C)
J0025C                   EXSR      FMTAPK
J0025C                   EVAL      %SUBST(XAPK2:10:4) = XTREVERSAL
      *
      * Format Application Key
     C                   OTHER
     C                   EXSR      FMTAPK
J0025C                   ENDSL
      *
     C     KSLGL0        CHAIN(N)  DSPSLGRC
     C                   IF        NOT (%FOUND)
     C                   MOVE      DSPHDR        DSPSLGHDR
     C                   MOVEL(P)  DSPSHDR       I08SRE
     C                   MOVE      QWJID         I08JID
     C                   MOVEL(P)  *BLANKS       I08MSTA
      *
     C                   MOVEl(P)  XAPK1         I08APK1
     C                   MOVEl(P)  XAPK2         I08APK2
      *
     C     ' '           CHECKR    XMSGRSPO      XLEN                     90
     C     WPLEN         CAT(P)    XMSGRSPO      I08MSGI
      *
      * keep the request format in I08MSGO
     C     ' '           CHECKR    QDSPMSG       XLEN                     10
     C     WPLEN         CAT(P)    QDSPMSG       I08MSGO                        In rec log
      *
      * Get time stamp
     C                   MOVE      QXTIMSTM      I08TSTI
      *
     C                   WRITE     DSPSLGRC
      *
     C                   ELSE
      *
     C                   IF        %SUBST(I13MSTA:1:1) = '.'
     C                   EXSR      FMTPGMEXC
     C                   ENDIF
     C                   EVAL      I13MSTA = '.' + QDSP0007                     Duplicate key
     C                   EXSR      FMTERROR
     C                   EXSR      FMTPGMEXC
     C                   ENDIF                                                  %FOUND
      *
     C                   UNLOCK    DSPHHLL0
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine FMTERROR                                              *
      * send back error                                                  *
      ********************************************************************
     C     FMTERROR      BEGSR
     C                   MOVEL     DSPHDR        QDSPHDR
     C                   CLEAR                   XMSGRSPO
     C                   MOVEL     DSPMSG        XMSGRSPO
     C                   MOVE      XRSP          XMSGIND                        Response
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine FMTRSPERR                                             *
      * send back response error                                         *
      ********************************************************************
     C     FMTRSPERR     BEGSR
      * retreive back the original DSP header from log file, then
      * change the I08MSTA
     C                   MOVEL     DSPSLGHDR     QDSPHDR
     C                   MOVEL     QDSPHDR       DSPHDR
     C                   EVAL      QDSPMSG = (%SUBST(I08MSGO:3:4096))
     C                   CLEAR                   XMSGRSPO
     C                   MOVEL(P)  DSPMSG        XMSGRSPO                       Send Original Msg bk
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine FMTPGMEXC                                             *
      *   Format program exception                                       *
      ********************************************************************
     C     FMTPGMEXC     BEGSR
     C                   MOVEL     XEXCPCD       QEXCPCD                        Exeception code
     C                   EVAL      QMSGTYP = (%SUBST(I13MSTA:2:3))              Messsage type
     C                   EVAL      QMSGNBR = (%SUBST(I13MSTA:5:4))              Message ID
     C                   MOVE      DSPHDR        QDSPHDR
     C                   EXSR      DSPSSNDQEX
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine GENRESPONSE                                           *
      *   Generate Response Message                                      *
      ********************************************************************
     C     GENRESPONSE   BEGSR
      *
      * Keep original message
     C                   MOVEL(P)  *BLANKS       XMSGO
     C                   MOVEL(P)  DSPMSG        XMSGO
      *
     C                   MOVEL(P)  QDSPHDR       DSPHDR
      *
     C                   EXSR      CVTRSPMSG
      *
     C                   EXSR      UPDSLG
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine CVTRSPMSG                                             *
      ********************************************************************
     C     CVTRSPMSG     BEGSR
      *
     C                   MOVEL(P)  *BLANKS       XDSPMSG
     C                   MOVEL(P)  QDSPMSG       XDSPMSG
     C                   EVAL      ERR = DSPUNPKB24(XDSPMSG2)
      *
      * Check response code
     C                   SELECT
     C                   WHEN      (%SUBST(I13UDTA:6:4) = XREVERSAL)
     C                   IF        (B24FLD39 = '00')
     C                   EVAL      %SUBST(I13MSTA:1:8) = XGOODRSP
     C                   ELSE
     C                   EVAL      %SUBST(I13MSTA:1:8) = XBADRSP
     C                   ENDIF
     C                   OTHER
     C                   IF        (B24FLD39 = '00')
     C                   EVAL      %SUBST(I13MSTA:1:8) = XGOODRSP
     C                   ELSE
     C                   EVAL      %SUBST(I13MSTA:1:8) = XBADRSP
     C                   ENDIF
     C                   ENDSL
      *
     C     ENDCVTRSP     TAG
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine UPDSLG                                                *
      * Update DSPSLGRC                                                  *
      ********************************************************************
     C     UPDSLG        BEGSR
      *
     C                   CLEAR                   DSPSLGRC
      *
J0025C                   MOVEL(P)  B24MID        X24MID
J0025C                   SELECT
      * Format Reversal Key
J0025C                   WHEN      (X24MID = X430C)
J0025C                   EXSR      FMTAPK
J0025C                   EVAL      %SUBST(XAPK2:10:4) = XTREVERSAL
      * Format Application Key
J0025C                   OTHER
     C                   EXSR      FMTAPK
J0025C                   ENDSL
      *
     C     KSLGL0        CHAIN     DSPSLGRC
     C                   IF        ((%FOUND) AND (%SUBST(I08MSTA:1:1) = ' '))
     C                   MOVEL     I13MSTA       I08MSTA
     C                   SELECT
      * If reply format error
     C                   WHEN      I08MSTA = '.' + QDSP0014
     C                   EXSR      FMTRSPERR
     C                   EXSR      UPDFLDSLG
      * If Auto Reversal response
     C                   WHEN      (%SUBST(I13UDTA:6:4) = XREVERSAL)
     C                   EXSR      UPDFLDSLG
     C                   EVAL      %SUBST(I13MSTA:1:1) = XSUSPECT
     C                   MOVEL     DSPHDR        QDSPHDR
      * Good Reply
     C                   OTHER
     C                   CLEAR                   DSPSHDR
     C                   MOVEL(P)  I08SRE        DSPSHDR
     C                   EXSR      GENRSPMSG
     C                   ENDSL
      *
     C                   ELSE
      * reply has error
     C                   SELECT
      * record not found
     C                   WHEN      (NOT %FOUND)
     C                   EVAL      I13MSTA = '.' + QDSP0011
      *
      * receive normal reply after auto reversal already send out
     C                   WHEN      (%SUBST(I08MSTA:1:1) = '&')
     C                   EVAL      I13MSTA = '.' + QDSP0012
      *
      * duplicate reply for normal response
     C                   WHEN      (%SUBST(I08MSTA:1:1) = '.') OR
     C                             (%SUBST(I08MSTA:1:1) = '/')
     C                   EVAL      I13MSTA = '.' + QDSP0013
      *
     C                   ENDSL
      *
     C                   EXSR      FMTPGMEXC
     C                   EVAL      %SUBST(I13MSTA:1:1) = XSUSPECT
     C                   MOVEL     DSPHDR        QDSPHDR
     C                   ENDIF
      *
     C                   UNLOCK    DSPHHLL0
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine GENRSPMSG                                             *
      *   Generate response msg                                         *
      ********************************************************************
     C     GENRSPMSG     BEGSR
      *
     C                   MOVE      DSPSLGHDR     DSPHDR
     C                   EXSR      UPDFLDSLG
      *
      * before send back the transaction,recalculate I13MLEN
     C     ' '           CHECKR    QDSPMSG       XLEN                     90
     C                   EVAL      I13MLEN  = I13HLEN + XLEN
     C                   MOVE      DSPHDR        QDSPHDR
      *
     C                   CLEAR                   XMSGRSPO
     C                   MOVEL(P)  DSPMSG        XMSGRSPO
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine UPDFLDSLG                                             *
      *  Update field                                                    *
      ********************************************************************
     C     UPDFLDSLG     BEGSR
      *
      * Get time stamp
     C                   MOVE      QXTIMSTM      I08TSTO
      *
      * Update log
     C     ' '           CHECKR    QDSPMSG       XLEN                     90
     C     WPLEN         CAT(P)    QDSPMSG       I08MSGO
     C                   UPDATE    DSPSLGRC
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine GENREVMSG                                             *
      *  Generate Reversal Message                                       *
      ********************************************************************
     C     GENREVMSG     BEGSR
      *
      * check the data format ID
     C                   IF        (I13FMID <> XFRFMID)                         HISO
     C                   EVAL      I13MSTA = '.' + QDSP0008
     C                   EXSR      FMTERROR
     C                   EXSR      WRTSLG                                       Write S/R log
     C                   GOTO      ENDREVMSG
     C                   ENDIF
      *
      * Keep original message
     C                   MOVEL(P)  *BLANKS       XMSGO
     C                   MOVEL(P)  DSPMSG        XMSGO
      *
     C                   MOVEL(P)  *BLANKS       XDSPMSG
     C                   MOVEL(P)  QDSPMSG       XDSPMSG
     C                   EVAL      ERR = DSPUNPKB24(XDSPMSG2)
      *
      * Get the Message ID
     C                   MOVEL(P)  *BLANKS       X24MID
     C                   MOVEL(P)  B24MID        X24MID
      *
     C                   IF        (%SUBST(I13MSTA:1:1) = '&')
     C                   EVAL      %SUBST(I13UDTA:6:4) = XREVERSAL
     C                   EXSR      GENAUTREV
     C                   ELSE
     C                   EVAL      %SUBST(I13UDTA:10:4) = XTREVERSAL
     C                   EXSR      GENAPLREV
     C                   ENDIF
      *
     C     ENDREVMSG     TAG
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine GENAUTREV
      *   Generate Auto Reversal format
      ********************************************************************
     C     GENAUTREV     BEGSR
      *
      * Format Application Key
     C                   EXSR      FMTAPK
      *
      * find original request
     C     KSLGL0        CHAIN(N)  DSPSLGRC
     C                   IF        (%FOUND) AND
     C                             ((%SUBST(I08MSTA:1:1) = '/') OR
     C                             (%SUBST(I08MSTA:1:1) = ' '))
      * Update the message status for this record to indicate that need to do reversal
     C                   MOVEL     I13MSTA       I08MSTA
      *
     C                   EVAL      WPLEN = %SUBST(I08MSGI:1:2)
     C                   IF        XLEN > *ZEROS
     C                   UPDATE    DSPSLGRC
      *
     C                   EXSR      CVTSYSREV
     C                   EXSR      WRTSLG
      *
     C                   ELSE
      * If the XLEN = *ZEROS
     C                   EVAL      I13MSTA = '.' + QDSP0005
     C                   UPDATE    DSPSLGRC
     C                   EXSR      FMTERROR
     C                   EXSR      WRTSLG                                       Write S/R log
     C                   ENDIF
      *
     C                   ELSE
      * IF the mesage not found
     C                   EVAL      I13MSTA = '.' + QDSP0005
     C                   EXSR      FMTERROR
     C                   EXSR      WRTSLG                                       Write S/R log
     C                   ENDIF
      *
     C                   UNLOCK    DSPHHLL0
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine GENAPLREV
      *   Generate application reversal request format
      ********************************************************************
     C     GENAPLREV     BEGSR
      *
     C                   MOVEL     *BLANK        XAPK1DS
     C                   MOVEL     *BLANK        XAPK2
     C                   MOVEL     *BLANK        XMSTA
     C                   MOVEL     *BLANK        XFLD90
      *
     C                   MOVEL(P)  B24FLD3       XFLD3
      *
     C                   MOVEL(P)  B24FLD90      XFLD90
      *
     C                   MOVEL(P)  XORGSEQNUM    XFLD37
     C                   MOVE      XTRNDATE      XFLD13
     C                   EVAL      XFLD12 = %SUBST(XTRNTIME:1:6)
     C                   MOVEL(P)  XAPK1DS       XAPK1
      *
      * find original request
     C                   MOVEL     *BLANKS       XAPK2
     C     KSLGL0        CHAIN     DSPSLGRC
     C                   IF        (%FOUND) AND
     C                             ((%SUBST(I08MSTA:1:1) = ' ')
     C                             OR (%SUBST(I08MSTA:1:1) = '/')
     C                             OR (%SUBST(I08MSTA:1:1) = '&'))
      * trx have no reversal been done yet
     C                   MOVEL(P)  XREVREQ       I08MSTA
     C                   UPDATE    DSPSLGRC
      *
     C                   MOVEL(P)  DSPHDR        QDSPHDR
     C                   EXSR      CVTREQMSG
      *
     C                   ELSE
      * record not found in SLG
     C                   EVAL      I13MSTA = '.' + QDSP0016
     C                   EXSR      FMTERROR
     C                   EXSR      WRTSLG
     C                   ENDIF
      *
     C                   UNLOCK    DSPHHLL0
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine CVTSYSREV                                             *
      *  Convert the reversal message                                    *
      ********************************************************************
     C     CVTSYSREV     BEGSR
      *
     C                   MOVEL(P)  *BLANKS       XDSPMSG
     C                   MOVEL(P)  QDSPMSG       XDSPMSG
      *
      * Get the Reversal message bitmap
     C**                 MOVEL(P)  X420C         XIMTMID
     C**                 MOVEL(P)  XCDTCDC       XTRXCD
     C**                 EXSR      GETBMP
      *
      * Format the Reversal message
     C                   EXSR      FMTSYSREV
      *
     C                   MOVEL(P)  *BLANKS       XDSPMSG2
     C                   EVAL      XDSPMSG2 = DSPPACKB24
     C                   MOVEL(P)  XDSPMSG       QDSPMSG
      *
      * before send back the transaction,recalculate I13MLEN
     C     ' '           CHECKR    QDSPMSG       XLEN                     90
     C                   EVAL      I13MLEN  = I13HLEN + XLEN + %SIZE(XDSPMSG1)
     C                   MOVE      DSPHDR        QDSPHDR
      *
     C                   CLEAR                   XMSGRSPO
     C                   MOVEL(P)  DSPMSG        XMSGRSPO
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine FMTSYSREV                                             *
      *  Format the reversal message                                     *
      ********************************************************************
     C     FMTSYSREV     BEGSR
      *
      * Format Message Id - MID
     C                   MOVEL(P)  X420C         B24MID
      *
      * Format Original Date - FLD90
     C                   IF        XFLD(90) = *ON
     C                   MOVEL(P)  *BLANKS       XFLD90
     C                   MOVEL(P)  X24MID        XORGTRNTYP
     C                   MOVEL(P)  B24FLD37      XORGSEQNUM
      *
     C                   MOVEL(P)  *ZEROS        XTRNDATE
     C                   MOVE      B24FLD13      XTRNDATE
      *
     C                   MOVEL(P)  *ZEROS        XTRNTIME
     C                   MOVEL(P)  *ZEROS        XCHAR8
     C                   MOVE      B24FLD12      XCHAR8
     C                   MOVEL(P)  XCHAR8        XTRNTIME
      *
     C                   MOVEL(P)  *ZEROS        XFIL
      *
     C                   MOVEL(P)  XFLD90        B24FLD90
     C                   ENDIF
      *
      * Format Replacemant Amount - Fld95
     C                   IF        XFLD(95) = *ON
     C                   MOVEL(P)  B24FLD4       B24FLD95
     C                   ENDIF
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine FMTATLREVK0                                           *
      *  Format ATL REV KEY0                                             *
      ********************************************************************
     C     FMTATLREVK0   BEGSR
      *
     C                   MOVEL     *BLANK        XRRNO
     C                   MOVEL     *BLANK        XRTGN
     C                   MOVEL     *BLANK        I08APK2
     C                   MOVEL     *BLANK        XAPK2
     C                   MOVEL     I13RRNO       XRRNO
     C                   MOVEL     I13RTGN       XRTGN
     C                   MOVEL     I13UDTA       I08APK2
      *
     C                   MOVEL(P)  XAPK1DS       I08APK1
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine FMTAPK                                                *
      *  Format Application Key                                          *
      ********************************************************************
     C     FMTAPK        BEGSR
      *
     C                   CLEAR                   XAPK1
     C                   CLEAR                   XAPK2
      *
     C                   MOVEL(P)  *BLANKS       XAPK1DS
     C                   MOVEL(P)  B24FLD37      XFLD37
     C                   MOVE      B24FLD13      XFLD13
     C                   MOVEL(P)  B24FLD12      XFLD12
     C                   MOVEL(P)  B24FLD3       XFLD3
      *
     C                   MOVEL(P)  XAPK1DS       XAPK1
      *
     C                   ENDSR
      ********************************************************************
      /EJECT
      ********************************************************************
      * Subroutine *INZSR                                                *
      *  Initial subroutine                                              *
      ********************************************************************
     C     *INZSR        BEGSR
      *
     C                   MOVEL     WFID          QFID                           File id
     C                   MOVEL     WTRACE        QTRCONOF                       Trace no
     C                   MOVEL     WRNAM         QWRNAM                         Queue Name
     C                   MOVEL     WRLIB         QWRLIB                         Queue Library
     C                   MOVEL     WJID          QWJID                          Job Id
     C                   Z-ADD     WJSQN         QWJSQN                         Job Seq
      *
     C                   MOVE      *ON           QSGNONOF                       Sign on
     C                   MOVE      *OFF          QEOJONOF                       Initial EOJ flag
      *
     C                   OPEN      DSPPARL0
      *
     C     XEXCEPTIONQ   CHAIN     DSPPARRC
     C                   IF        (%FOUND)
     C                   MOVEL     I04TVAL       QEXCEPTIONQ                    pgm except route
     C                   MOVEL(P)  WJGRP         WFRJGRP
     C                   EVAL      WFRRNAM = %SUBST(I04TVAL:11:10)
     C                   EXSR      DSPFMTRN
     C                   EVAL      %SUBST(QEXCEPTIONQ:11:10) = WTORNAM
     C                   ELSE
     C                   MOVEL(P)  '*END'        QRNAMEX
     C                   ENDIF                                                  Endif *in90
      *
     C     XSYSCMDQ      CHAIN     DSPPARRC
     C                   IF        (%FOUND)
     C                   MOVEL     I04TVAL       QSYSCMDQ                       syscmd route
     C                   ENDIF                                                  Endif *in90
      *
     C     XWAITMSG      CHAIN     DSPPARRC
     C                   IF        (%FOUND)
     C                   MOVEL     I04TVAL       QWAIT                          wait massage time
     C                   ENDIF                                                  Endif *in90
      *
     C                   EXSR      DSPGETLOGF                                   Get BASE&ALT logf
     C                   EXSR      DSPSWAPLOG                                   Select logf
     C                   OPEN      DSPHHLL0                                     Open logf
      *
     C                   CLOSE     DSPPARL0
      * Load RTE table
     C                   MOVE      *ON           XINIT                          Initial RTE table
     C                   EXSR      DSPSSRNM                                     Search route name
     C                   MOVE      *OFF          XINIT                          Set init off
      *
     C                   ENDSR
      ********************************************************************
     C/COPY QDSPCOPY,DSPCBAS01
      * Search route
     C/COPY QDSPCOPY,DSPCOPT01
      * Load table
     C/COPY QDSPCOPY,DSPCOPT06
      * Swap log file
     C/COPY QDSPCOPY,DSPCOPT07
      * Program exception
     C/COPY QDSPCOPY,DSPCPSSR
      * Bitmap/Hex
     C/COPY QDSPCOPY,DSPCOPT08
      * Convert BITMAP/HEX/(un)packISO8583
     C/COPY QDSPCOPY,DSPCOPT14
      ********************************************************************
      * Tables                                                           *
      *          ALTSEQ-tabel for $,#,@ -sort: Mandatory|                *
      ********************************************************************
**
ALTSEQ    5BEA7BEB7CEC
