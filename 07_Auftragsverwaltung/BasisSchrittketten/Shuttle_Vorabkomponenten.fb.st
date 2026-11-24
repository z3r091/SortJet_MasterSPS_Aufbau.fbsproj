(* METADATA
{
	"v3Meta": {
		"objectGuid": "19fcb8bb-2bd9-4575-a4db-49bc1e849a70"
	}
}
*)
FUNCTION_BLOCK Shuttle_Vorabkomponenten
VAR_INPUT

  // BOOLEAN
  bpReset                : BOOL;

  // WORD
  wStation               : WORD;
  wWand                  : WORD;

  // STRUKTUR
  Auftragsdaten          : VorAbAuftragsdaten_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                 : BOOL;
  bpFehler               : BOOL;

END_VAR
VAR

  // BOOL
  blFreigabeVorabAuftrag     : BOOL;

  // WORD
  wlNextTransferstation  : WORD;

  // STEPS
  steplSchritt           : STEPS_TE;

END_VAR
//-------------------------------------------------------------------------------------------------
// STEUERUNG VORABKOMPONENETEN
//-------------------------------------------------------------------------------------------------


IF ( Auftragsdaten.wAuftrag = eStation_VorabAuftrag ) THEN

  (* Hinweis:
     - Setzen der Freigabe fuer die Resourcen-Ansteuerung wenn zum Zeitpunkt des "STARTENS"
       kein Auftrag aktiv ist. Ist die Ansteuerung "Aktiv" kann diese Variable wieder abfallen.
  *)
  blFreigabeVorabAuftrag := ( Job_Shuttle.AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Kein_Auftrag );

  CASE steplSchritt OF

    // VORABKOMPONENETEN ===============================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrShuttleBasisParameter[wStation])
         AND blFreigabeVorabAuftrag
      THEN
        IF ( Auftragsdaten.wTransferStation <> 0 ) THEN
          steplSchritt := STEP_10_E;
        ELSE
          steplSchritt := STEP_1000_E;
        END_IF
      END_IF

    // VORABKOMPONENETEN ===============================================
    STEP_10_E:
      // Transferstation bestimmen
      wlNextTransferstation := Auftragsdaten.wTransferStation;

      // Auftragsdaten uebergeben
      starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand]:= Auftragsdaten;

      // Vorinitialisieren der Werte
      starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eGlastransport       := eGlastransport_Default;
      starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eDickenverstellung   := eZylinderUndefiniert;
      starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eKippen_SollPosition := eKippen_Default;

      // Scheibentyp prüfen
      starrShuttleBasisParameter[wStation].wGlasTyp[wWand] := eScheibe_Default;
      IF ( Auftragsdaten.rLaenge >= starrShuttleBasisParameter[wStation].stMKs.stStationsParameter.rLaengeUebergroesseScheibe ) THEN
        starrShuttleBasisParameter[wStation].wGlasTyp[wWand] := eScheibe_Maximal;
      END_IF

      (* Hinweis:
         - Austransport
      *)
      IF ( Auftragsdaten.wAuftragstyp.0 ) THEN
        // Folgestation beruecksichtigen damit in verschiedene Richtungen vorpositioniert werden kann.
        starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eGlastransport := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Glastransport[wlNextTransferstation];
        starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eKippen_SollPosition := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Kippen[wlNextTransferstation];
      ELSE
        starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eKippen_SollPosition := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Kippen[wlNextTransferstation];
      END_IF

      // Greifer [Ausbaustufe stStationsAufbau.bGreifer]: Greiferseite je Partnerstation fuer die Vorabpositionierung
      starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eGreiferTyp := eGreiferDefault;
      IF ( starrShuttleBasisParameter[wStation].stMKs.stStationsAufbau.bGreifer[wWand] ) THEN
        IF ( Auftragsdaten.wAuftragstyp.0 ) THEN
          starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eGreiferTyp := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Greifer[wlNextTransferstation];
        ELSE
          starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eGreiferTyp := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Greifer[wlNextTransferstation];
        END_IF
      END_IF

      (* Hinweis:
         - Scheibenführung / Wandverstellung anstellen
         - Aus dem Speicher: Speicherslotdicke nehmen ; von einer Station die Scheibendicke nehmen
      *)
      IF ( starrShuttleBasisParameter[wStation].pAuftrag[cWAND_1].rAuftragsDicke <= wgMKScheibenDicke13mm ) THEN
        starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung16mm;
      ELSIF ( starrShuttleBasisParameter[wStation].pAuftrag[cWAND_1].rAuftragsDicke <= wgMKScheibenDicke19mm ) THEN
        starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung23mm;
      ELSIF ( starrShuttleBasisParameter[wStation].pAuftrag[cWAND_1].rAuftragsDicke <= wgMKScheibenDicke24mm ) THEN
        starrShuttleBasisParameter[wStation].pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung29mm;
      END_IF

      // Auftrag übergeben
      starrShuttleBasisParameter[wStation].bVorabKomponentenAnsteuerung[wWand] := TRUE;

      steplSchritt := STEP_400_E;

    // VORABKOMPONENETEN ===============================================
    STEP_400_E:
      (* Hinweis:
         - Abschliessen des Austransports
      *)
      IF ( starrShuttleBasisParameter[wStation].bVorabKomponentenAnsteuerungAbgeschlossen[wWand] ) THEN
        starrShuttleBasisParameter[wStation].bVorabKomponentenAnsteuerung[wWand] := FALSE;
        steplSchritt := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Inputshuttle
      *)
      IF ( starrShuttleBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrShuttleBasisParameter[wStation].wFehlerNummer,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrShuttleBasisParameter[wStation].awFehlerInformationen );

        steplSchritt := STEP_900_E;
      END_IF

    // VORABKOMPONENETEN ===============================================
    STEP_900_E:
      blFreigabeVorabAuftrag := FALSE;
      bpFehler := TRUE;

    // VORABKOMPONENETEN ===============================================
    STEP_1000_E:
      bpDone := TRUE;
      blFreigabeVorabAuftrag := FALSE;
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

  // VORABKOMPONENETEN ===============================================
  END_CASE

END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpDone := FALSE;
  bpReset := FALSE;
  blFreigabeVorabAuftrag := FALSE;
  starrShuttleBasisParameter[wStation].bVorabKomponentenAnsteuerung[wWand] := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK