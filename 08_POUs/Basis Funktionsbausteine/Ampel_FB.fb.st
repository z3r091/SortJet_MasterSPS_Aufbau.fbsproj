(* METADATA
{
  "v3Meta": {
    "objectGuid": "3b447e4d-6caa-4c98-ad2d-e4c3e81f2c59"
  }
}
*)
FUNCTION_BLOCK Ampel_FB
VAR_INPUT

  // BOOL
  bpAutomatikAktiv                : BOOL;
  bpSystemcheckAktiv              : BOOL;
  bpBetriebsstoppAktiv            : BOOL;
  bpInternerBetriebsstopp         : BOOL;
  bpHinweisFWEingriffErforderlich : BOOL;
  bpSignalExtern                  : BOOL; // Blau Dauerlicht (z. B. Faecherwagen bald voll); Eingriff erforderlich hat Vorrang (blinkt)

END_VAR
VAR_OUTPUT
END_VAR
VAR

  //BOOL
  blFlashbit    : BOOL;

  // BYTE
  bylShiftByte  : BYTE :=1;

  // WORD
  wlModus       : WORD;
  wlInitAmpel   : WORD;

  // INT
  ilIndex       : INT;

  // TRIGGER 
  rtlInitAmpel  : R_TRIG;

  // BLINK
  Flasher       : BLINK;

END_VAR
VAR

  // HARDWARE AUSGAENGE
  out_bAmpelLeuchteRot     AT%Q* : BOOL;
  out_bAmpelLeuchteGelb    AT%Q* : BOOL;
  out_bAmpelLeuchteGruen   AT%Q* : BOOL;
  out_bAmpelLeuchteBlau    AT%Q* : BOOL;

END_VAR
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: ANSTEUERUNG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Baustein zum Ansteuern der optischen Signale des Sortjet : AMPELN
*)
Flasher(ENABLE:= TRUE , TIMELOW:= t#0.2s, TIMEHIGH:= t#0.2s , OUT=> blFlashbit);
rtlInitAmpel(CLK:= blFlashbit );

out_bAmpelLeuchteBlau := SEL( bpHinweisFWEingriffErforderlich, bpSignalExtern, gbFlashbit02sec );

//  Zentral den OperatingMode bestimmen
IF ( NOT NotHalt.bpNotHaltOK) THEN // NotAus nicht OK
  wlModus := 3;
ELSIF ( bpBetriebsstoppAktiv  ) THEN // Betriebsstop gesetzt
  wlModus := 8;
ELSIF ( Visu_Start_Auto ) THEN // VisuAuto aktiv
  wlModus := 7;
ELSIF ( bgInbetriebnahmeBit ) THEN // Inbetriebnahmebit gesetzt
  wlModus := 5;
ELSIF ( bpInternerBetriebsstopp ) THEN // Fehler/interner betriebsstop gesetzt
  wlModus := 0;
ELSIF ( Initialisierung.bpInitialisierungAktiv ) THEN // Initialiesierung aktiv
  wlModus := 5;
ELSIF ( bpSystemcheckAktiv ) THEN // Checkroutine aktiv
  wlModus := 6;
ELSIF ( bpAutomatikAktiv ) THEN // automatik aktiv
  wlModus := 2;
ELSE // Handbetrieb aktiv
  wlModus := 4;
END_IF

CASE wlModus OF
  // ======================================================
  0 : // Faliure active
    out_bAmpelLeuchteRot    := blFlashbit;
    out_bAmpelLeuchteGelb   := NOT out_bAmpelLeuchteRot;
    out_bAmpelLeuchteGruen  := FALSE;

  // ======================================================
  1:  // Service Mode
    out_bAmpelLeuchteRot    := FALSE;
    out_bAmpelLeuchteGelb   := TRUE;
    out_bAmpelLeuchteGruen  := FALSE;

  // ======================================================
  2:  // Automatic Running
    out_bAmpelLeuchteRot    := FALSE;
    out_bAmpelLeuchteGelb   := FALSE;
    out_bAmpelLeuchteGruen  := TRUE;

  // ======================================================
  3:  // Emergency Stop Active
    out_bAmpelLeuchteRot    := TRUE;
    out_bAmpelLeuchteGelb   := FALSE;
    out_bAmpelLeuchteGruen  := FALSE;

  // ======================================================
  4:   // Manual Mode
    out_bAmpelLeuchteRot    := FALSE;
    out_bAmpelLeuchteGelb   := TRUE;
    out_bAmpelLeuchteGruen  := FALSE;

  // ======================================================
  5: // Initialisation Mode
    out_bAmpelLeuchteRot    := ((wlInitAmpel AND Maske_Bit_2)<>0);
    out_bAmpelLeuchteGelb   :=((wlInitAmpel AND Maske_Bit_1)<>0);
    out_bAmpelLeuchteGruen  :=((wlInitAmpel AND Maske_Bit_0)<>0);

  // ======================================================
  6:   // Check Routine wurde gestartet
    out_bAmpelLeuchteRot    := FALSE;
    out_bAmpelLeuchteGelb   := FALSE;
    out_bAmpelLeuchteGruen  := blFlashbit;

  // ======================================================
  7:   // VisuAuto aktiv
    out_bAmpelLeuchteRot    := FALSE;
    out_bAmpelLeuchteGelb   := NOT blFlashbit;
    out_bAmpelLeuchteGruen  := TRUE;
  // ======================================================
  8:   // Betriebsstoptaster betätigt
    out_bAmpelLeuchteRot    := FALSE;
    out_bAmpelLeuchteGelb   := blFlashbit;
    out_bAmpelLeuchteGruen  := bpAutomatikAktiv;

// ======================================================
END_CASE

IF ( wlModus = 5) THEN

  IF ( rtlInitAmpel.Q ) THEN

    wlInitAmpel :=SHL(bylShiftByte, ilIndex);
    ilIndex := ilIndex + 1;

    IF ( ilIndex = 3 ) THEN
      ilIndex := 0;
    END_IF;

  END_IF;

ELSE
  wlInitAmpel := 0;

END_IF
END_FUNCTION_BLOCK