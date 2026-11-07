(* METADATA
{
	"v3Meta": {
		"objectGuid": "641c87ce-8284-4321-bfe9-ecbcb8027972"
	}
}
*)
ACTION Austransport
//-------------------------------------------------------------------------------------------------
// AKTION: AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
IF (  BasisStationsParameter.bAustransport[cWAND_1]
     AND BasisStationsParameter.bAutomatik )
THEN
  CASE steplAustransport OF
    // AUSTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - Status setzen (Resource reservieren)
      *)
      IF ( ReservierungsStatus <> TS_AUSTRANSPORT_RESERVIERUNG ) THEN

        IF ( BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1] ) THEN
          ReservierungsStatus := TS_AUSTRANSPORT_RUECKWERTIG_RESERVIERUNG;
        ELSE
          ReservierungsStatus := TS_AUSTRANSPORT_RESERVIERUNG;
        END_IF

      END_IF

      steplAustransport := STEP_20_E;

    // AUSTRANSPORT ==============================
    STEP_20_E:
      IF ( blZielPositionErreicht ) THEN
        steplAustransport := STEP_30_E;
      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(Querfahrt.rpAktPosition);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rStationsZielposition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_30_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONALE - ABFRAGE DES SICHERHEITSKREISES
      //
      //  Hinweis:
      //  - Sicherstellen das der Sicherheitskreis geschlossen und nicht angefordert worden ist
      //  WICHTIG
      //  - Aufgrund der USC11B darf der Riemen bei geoeffneten SK [Input-Speicher] nicht negativ
      //    bewegt werden da sonst der STO [Sicherehalt] ausloest
      // ---------------------------------------------------------------------------------------

      IF  ( Sicherheitskreis[BasisStationsParameter.stMKs.eaSicherheitskreis[0]].bpSicherheitskreisGeschlossen
            AND NOT Sicherheitskreis[BasisStationsParameter.stMKs.eaSicherheitskreis[0]].bpAnforderungSKGestellt )
      THEN
        blHinweisGenerierenSKAusgeloest := FALSE;
        steplAustransport := STEP_40_E;

      ELSE
        blHinweisGenerierenSKAusgeloest := TRUE;

      END_IF

    // AUSTRANSPORT ==============================
    STEP_40_E:
      (* Anmerkung:
         - Shuttle steht an der gewuenschten Position und es kann mit dem Eintransport begonnen werden
         - Uebergabe des Bits "Erste Scheibe" zum Steuern des Austransports
           => Bit = TRUE: Austransport ohne Restwegpositionierung zum Lueckebilden
      *)
      Glastransport.bpRueckwaertsAustransportieren := BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpAustransport := TRUE;

      steplAustransport := STEP_50_E;

    // AUSTRANSPORT ==============================
    STEP_50_E:
      (* Hinweis:
         - Resource freigeben wenn es zu keinem Fehler gekommen ist
      *)
      IF ( Glastransport.bpDone ) THEN
        ReservierungsStatus := TS_KEINE_RESERVIERUNG;

        Glastransport.bpAustransport := FALSE;
        steplAustransport := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpAustransport := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // AUSTRANSPORT ==============================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := TRUE;

  // AUSTRANSPORT ==============================
  END_CASE
ELSE
  IF ( steplAustransport > STEP_0_E ) THEN

    BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;
    blHinweisGenerierenSKAusgeloest := FALSE;

    Glastransport.bpAustransport  := FALSE;
    steplAustransport := STEP_0_E;
  END_IF
END_IF
END_ACTION