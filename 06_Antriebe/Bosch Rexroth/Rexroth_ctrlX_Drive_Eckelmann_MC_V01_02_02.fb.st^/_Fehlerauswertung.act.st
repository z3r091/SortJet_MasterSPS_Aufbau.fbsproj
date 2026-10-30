(* METADATA
{
	"v3Meta": {
		"objectGuid": "454009ed-4904-47be-a45e-86d01c03fc0f"
	}
}
*)
ACTION _Fehlerauswertung
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Fehlerauswertung
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
IF i_ui_Cia402_StatusWord.3 // Fehler am Umrichter aktiv
THEN
  Diagnose := DiagnoseAuswertung( wFehlernummer := udiErrorFromECat );
ELSE
  Diagnose := DiagnoseAuswertung( wFehlernummer := 0 );
END_IF

IF NOT i_ui_Cia402_StatusWord.3 AND NOT blInternerFehler AND blFehlerAktiv AND NOT blFreigabeEntziehenAktiv THEN
  Antriebsfehler.wlBausteinFehlerNr := cMotionFehler;
  blInternerFehler := TRUE;
END_IF

tonlFehlermeldungAusgeben(IN := ( blFehlerAktiv AND Diagnose.bError ) OR blInternerFehler , pt := T#1S);

rtl_Fehlermeldung(CLK := tonlFehlermeldungAusgeben.Q );

bpFehler := blFehlerAktiv AND ( Diagnose.bError (* OR Diagnose.bWarning *) OR blInternerFehler );

IF ( blInternerFehler ) THEN
  wlError := awlFehlerinformationen[4] := DWORD_TO_WORD(Antriebsfehler.wlBausteinFehlerNr);
ELSE
  awlFehlerinformationen[4] := DWORD_TO_WORD(Antriebsfehler.wlAntriebsFehler);
END_IF

IF ( rtl_Fehlermeldung.Q ) THEN

  awlFehlerinformationen[0] := stStationsNummern.NummerExtern;
  awlFehlerinformationen[1] := ppAntriebsInformationen.wpSchaltplanseite;
  awlFehlerinformationen[2] := ppAntriebsInformationen.wpSchaltplanReihe;
  awlFehlerinformationen[3] := ppAntriebsInformationen.wpSchaltschrank;

  IF ( blInternerFehler ) THEN
    SpsError(eFehler_Antrieb, wlError, stStationsNummern.NummerIntern, AutomatikkreisBestimmen(stStationsNummern.NummerIntern), awlFehlerinformationen);
  ELSE
    IF ( Diagnose.eType = eRexroth_Fehler_Error ) THEN
      SpsError( eFehler_Rexroth_Fehler + Diagnose.eErrorType , Diagnose.wFehlerNr , stStationsNummern.NummerIntern, AutomatikkreisBestimmen(stStationsNummern.NummerIntern), awlFehlerinformationen);
      // Wir loggen keine Warnungen
      // ELSIF ( Diagnose.eType = eRexroth_Fehler_Warning ) THEN
      //   SpsWarnung( eFehler_Rexroth_Warnung + Diagnose.eWarningType , Diagnose.wFehlerNr , stStationsNummern.NummerIntern, AutomatikkreisBestimmen(stStationsNummern.NummerIntern), awlErrorAdditional);
    END_IF
  END_IF

END_IF
END_ACTION