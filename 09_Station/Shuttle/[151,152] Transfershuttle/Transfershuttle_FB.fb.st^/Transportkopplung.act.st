(* METADATA
{
  "v3Meta": {
    "objectGuid": "e563e5e5-2947-436a-95e2-efb6cb74158d"
  }
}
*)
{attribute 'excludefrombuild'}
ACTION Transportkopplung
(***************************************************************************************************)
(* AKTION TRANSPORTKOPPLUNG *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bTransportkopplung[cWAND_1] )
THEN

  CASE steplTransportkopplung OF
    (*TRANSPORTKOPPLUNG ==============================*)
    STEP_0_E:
      (* Hinweis:
         - Status setzen (Resource reservieren)
      *)
      IF ( ReservierungsStatus <> TS_TRANSPORTKOPPLUNG_RESERVIERUNG ) THEN
        ReservierungsStatus := TS_TRANSPORTKOPPLUNG_RESERVIERUNG;
      END_IF

      steplTransportkopplung := STEP_10_E;


    (*TRANSPORTKOPPLUNG ==============================*)
    STEP_10_E:
      (* Hinwies:
         - Pruefen der Ist-Position
      *)
      IF ( blZielPositionErreicht ) THEN
        steplTransportkopplung := STEP_20_E;
      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(Verfahrauftraege.rlAktPosition);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rStationsZielposition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplTransportkopplung := STEP_900_E;
      END_IF

    (*TRANSPORTKOPPLUNG ==============================*)
    STEP_20_E:
      (* ---------------------------------------------------------------------------------------
      //  OPTIONALE - ABFRAGE DES SICHERHEITSKREISES 
      //         
      //  Hinweis:
      // - Sicherstellen das der Sicherheitskreis geschlossen und nicht angefordert worden ist
      // ---------------------------------------------------------------------------------------*)

      IF (  Sicherheitskreis[2].bpSicherheitskreisGeschlossen
           AND NOT Sicherheitskreis[2].bpAnforderungSKGestellt )
      THEN
        blHinweisGenerierenSKAusgeloest := FALSE;
        steplTransportkopplung := STEP_30_E;

      ELSE
        blHinweisGenerierenSKAusgeloest := TRUE;

      END_IF

    (*TRANSPORTKOPPLUNG ==============================*)
    STEP_30_E:
      (* Anmerkung:
         - Shuttle steht an der gewuenschten Position und es kann mit dem Eintransport 
           begonnen werden
      *)
      Glastransport.pAuftrag        := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpSlaveKopplung := TRUE;

      steplTransportkopplung := STEP_1000_E;

    (*TRANSPORTKOPPLUNG ==============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      BasisStationsParameter.bFehler  := TRUE;
      Glastransport.bpSlaveKopplung   := FALSE;

    (*TRANSPORTKOPPLUNG ==============================*)
    STEP_1000_E:
      (* Hinweis:
         - Warteschritt
      *)
      ;

  (*TRANSPORTKOPPLUNG ==============================*)
  END_CASE
ELSE

  IF( steplTransportkopplung > STEP_0_E )THEN
    blHinweisGenerierenSKAusgeloest := FALSE;
    Glastransport.bpSlaveKopplung := FALSE;

    steplTransportkopplung := STEP_0_E;
  END_IF

END_IF
END_ACTION