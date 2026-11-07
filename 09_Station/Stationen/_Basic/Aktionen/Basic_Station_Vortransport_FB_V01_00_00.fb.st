(* METADATA
{
	"v3Meta": {
		"objectGuid": "c848b7d7-6090-406c-80b4-f253ab82cb43"
	}
}
*)
FUNCTION_BLOCK Basic_Station_Vortransport_FB_V01_00_00 EXTENDS Basic_Station_Aktion_FB_V01_00_00
(* Hinweis:
   - Im Vortransport findet nur der Riemen-Vortransport statt
   - Alles ungleich 0 beim Modellversatz ist eine Modellscheibe: dann kein Vortransport
   - Nach dem Eintransport stoesst die Station den Vortransport intern an (Basic-Eintransport), parallel zum Kippen nach dem Eintransport
*)
VAR

  // BOOLEAN
  blVortransportStarten : BOOL; // Vortransport wird gefahren (Modellscheiben: nicht)

END_VAR
//-------------------------------------------------------------------------------------------------
// VORTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bVortransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // VORTRANSPORT =====================
    STEP_0_E:
      bpFehler := FALSE;
      BasisStationsParameter.bVortransportAbgeschlossen[wWand] := FALSE;

      blVortransportStarten := ( BasisStationsParameter.pAuftrag[wWand].rModellVersatzVorne = 0 );

      steplAktion := STEP_10_E;

    // VORTRANSPORT =====================
    STEP_10_E:
      (* Hinweis:
         - Starten des Vortransports
      *)
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[wWand];
      Glastransport.bpVortransport             := blVortransportStarten AND NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      Glastransport.bpVortransportRueckwaertig := blVortransportStarten AND     BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      steplAktion := STEP_20_E;

    // VORTRANSPORT =====================
    STEP_20_E:
      (* Hinweis:
         - Vortransport abgeschlossen
      *)
      IF ( Glastransport.bpDone OR NOT blVortransportStarten ) THEN
        Glastransport.bpVortransport             := FALSE;
        Glastransport.bpVortransportRueckwaertig := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

    // VORTRANSPORT =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // VORTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bVortransportAbgeschlossen[wWand] := TRUE;

  // VORTRANSPORT =====================
  END_CASE
ELSE

  IF (steplAktion > STEP_0_E) THEN
    bpFehler := FALSE;
    BasisStationsParameter.bVortransportAbgeschlossen[wWand] := FALSE;

    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK