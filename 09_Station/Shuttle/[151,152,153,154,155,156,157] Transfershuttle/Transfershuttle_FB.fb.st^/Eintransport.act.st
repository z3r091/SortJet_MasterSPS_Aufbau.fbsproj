(* METADATA
{
	"v3Meta": {
		"objectGuid": "93967610-2410-4e42-850f-494d72b5027b"
	}
}
*)
ACTION Eintransport
(***************************************************************************************************)
(* AKTION EINTRANSPORT *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bEintransport[cWAND_1]
   AND BasisStationsParameter.bAutomatik )
THEN
  CASE steplEintransport OF
(*EINTRANSPORT ==============================*)
    STEP_0_E:
      (* Hinweis:
         - Status setzen (Resource reservieren)
      *)
      IF ( ReservierungsStatus <> TS_EINTRANSPORT_RESERVIERUNG ) THEN
        ReservierungsStatus := TS_EINTRANSPORT_RESERVIERUNG;
      END_IF

      steplEintransport := STEP_20_E;

(*EINTRANSPORT ==============================*)
    STEP_20_E:
      IF ( blZielPositionErreicht ) THEN
        steplEintransport := STEP_30_E;
      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(Querfahrt.rpAktPosition);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rStationsZielposition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_30_E:
      (* ---------------------------------------------------------------------------------------
      //  OPTIONALE - ABFRAGE DES SICHERHEITSKREISES 
      //         
      //  Hinweis:
      // - Sicherstellen das der Sicherheitskreis geschlossen und nicht angefordert worden ist
      // ---------------------------------------------------------------------------------------*)

      IF Sicherheitskreis[BasisStationsParameter.stMKs.eaSicherheitskreis[0]].bpSicherheitskreisGeschlossen
        AND NOT Sicherheitskreis[BasisStationsParameter.stMKs.eaSicherheitskreis[0]].bpAnforderungSKGestellt
      THEN
        blHinweisGenerierenSKAusgeloest := FALSE;
        steplEintransport := STEP_40_E;

      ELSE
        blHinweisGenerierenSKAusgeloest := TRUE;

      END_IF

(*EINTRANSPORT ==============================*)
    STEP_40_E:
      (* Anmerkung:
         - Shuttle steht an der gewuenschten Position und es kann mit dem Eintransport 
           begonnen werden
      *)
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpRueckwaertsEintransportieren := BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.bpEintransport := TRUE;

      steplEintransport := STEP_50_E;

(*EINTRANSPORT ==============================*)
    STEP_50_E:
      IF ( Glastransport.bpDone ) THEN
        ReservierungsStatus := TS_KEINE_RESERVIERUNG;

        Glastransport.bpEintransport := FALSE;
        steplEintransport := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*EINTRANSPORT ==============================*)
    STEP_1000_E:
      BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := TRUE;

(*EINTRANSPORT ==============================*)
  END_CASE
ELSE
  IF ( steplEintransport > STEP_0_E ) THEN
    BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;
    blHinweisGenerierenSKAusgeloest := FALSE;

    Glastransport.bpEintransport := FALSE;
    steplEintransport := STEP_0_E;
  END_IF
END_IF
END_ACTION