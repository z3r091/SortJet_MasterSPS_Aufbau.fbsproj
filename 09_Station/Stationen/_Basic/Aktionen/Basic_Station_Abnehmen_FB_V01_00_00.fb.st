(* METADATA
{
	"v3Meta": {
		"objectGuid": "660d4460-1ddc-44b5-9e6a-0f9c596d74b5"
	}
}
*)
FUNCTION_BLOCK Basic_Station_Abnehmen_FB_V01_00_00 EXTENDS Basic_Station_Aktion_FB_V01_00_00
(* Hinweis:
   - Abnehmen: Station kippt, der Bediener nimmt die Scheiben ab und quittiert jede einzelne
   - Die Aktion schreibt nichts in den Glastransport
   - Kippen nur mit der Ausbaustufe bKippen
*)
VAR_INPUT

  // BOOLEAN
  bpFreigabeErhalten        : BOOL; // Station: Freigabe Si-Kreis (verzoegert) liegt an
  bpGlasAbgenommenQuittiert : BOOL; // Station: Bediener quittiert, dass die Scheibe abgenommen wurde (Taster oder Fusstaster gedrueckt)

  // Bausteine
  Kippen : REFERENCE TO Kippen_FB_V01_00_00;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpAbnehmenLampe        : BOOL; // Ampel gruen
  bpSignalScheibeAbnehmen : BOOL; // Taster Scheibe abnehmen (blinkt)
  bpSignalGlasbruch      : BOOL;

END_VAR
VAR

  // INT
  ilScheibenZaehler : INT; // Anzahl der Scheiben, die noch abzunehmen sind

END_VAR
//-------------------------------------------------------------------------------------------------
// ABNEHMEN
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bAbnehmen
     AND bpAutomatikAktiv )
THEN
  (* Fehlerbehandlung:
     - Kippen
  *)
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // ABNEHMEN =====================
    STEP_0_E:
      (* Hinweis:
         - Freigabe durch Quittierten Si-Kreis da ?
      *)
      bpFehler := FALSE;
      bpSignalScheibeAbnehmen := FALSE;
      BasisStationsParameter.bAbnehmenAbgeschlossen := FALSE;

      IF ( bpFreigabeErhalten ) THEN
        ilScheibenZaehler := WORD_TO_INT( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben );
        steplAktion := STEP_10_E;
      END_IF

    // ABNEHMEN =====================
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob das Geblase aktiv ist
           => Sicherung nicht ausgeloest
      *)
      IF ( bpGeblaeseFehler ) THEN
        bpDrosselklappeOeffnen := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAktion := STEP_900_E;

      ELSE
        bpDrosselklappeOeffnen := TRUE;
        steplAktion := STEP_20_E;

      END_IF

    // ABNEHMEN =====================
    STEP_20_E:
      IF ( NOT Kippen.bpFehler ) THEN
        bpDrosselklappeOeffnen := TRUE;

        Kippen.epZielPosition := eKippen_Position_84Grad;
        Kippen.bpPositionieren := TRUE;

        steplAktion := STEP_30_E;
      ELSE
        Kippen.bpPositionieren := FALSE;
        BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
        steplAktion := STEP_900_E;
      END_IF

    // ABNEHMEN =====================
    STEP_30_E:
      IF ( Kippen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] ) THEN
        bpDrosselklappeOeffnen := FALSE;
        Kippen.bpPositionieren := FALSE;

        bpAbnehmenLampe         := TRUE;
        bpSignalScheibeAbnehmen := TRUE;

        steplAktion := STEP_50_E;
      END_IF

    // ABNEHMEN =====================
    STEP_50_E:
      bpAbnehmenLampe         := gbFlashbit05sec;
      bpSignalScheibeAbnehmen := gbFlashbit05sec;

      (* Hinweis:
         - Erst die Lichtschranke unterbrechen und zur Station gehen
      *)
      IF ( bpFreigabeErhalten ) THEN
        steplAktion := STEP_60_E;
      END_IF

    // ABNEHMEN =====================
    STEP_60_E:
      bpAbnehmenLampe         := gbFlashbit05sec;
      bpSignalScheibeAbnehmen := gbFlashbit05sec;

      IF ( bpGlasAbgenommenQuittiert ) THEN
        ilScheibenZaehler := ( ilScheibenZaehler - 1 );

        IF ( ilScheibenZaehler > 0 ) THEN
          steplAktion := STEP_70_E;

        ELSE
          bpSignalGlasbruch       := FALSE;
          bpAbnehmenLampe         := FALSE;
          bpSignalScheibeAbnehmen := FALSE;

          steplAktion := STEP_1000_E;
        END_IF
      END_IF

    // ABNEHMEN =====================
    STEP_70_E:
      bpSignalGlasbruch := FALSE;

      IF ( NOT bpGlasAbgenommenQuittiert ) THEN
        steplAktion := STEP_60_E;
      END_IF

    // ABNEHMEN =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;
      Kippen.bpPositionieren := FALSE;

    // ABNEHMEN =====================
    STEP_1000_E:
      BasisStationsParameter.bAbnehmenAbgeschlossen := TRUE;

  // ABNEHMEN =====================
  END_CASE
ELSE
  IF ( steplAktion > STEP_0_E ) THEN
    bpFehler                := FALSE;
    bpDrosselklappeOeffnen  := FALSE;
    bpSignalScheibeAbnehmen := FALSE;
    bpAbnehmenLampe         := FALSE;
    bpSignalGlasbruch       := FALSE;

    Kippen.bpPositionieren  := FALSE;

    BasisStationsParameter.bAbnehmenAbgeschlossen := FALSE;

    steplAktion := STEP_0_E;
  END_IF
END_IF
END_FUNCTION_BLOCK