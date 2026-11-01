(* METADATA
{
  "v3Meta": {
    "objectGuid": "cc10e136-101c-4ae7-b0a5-83232002338e"
  }
}
*)
ACTION Systemcheck
(***************************************************************************************************)
(* AKTION SYSTEMCHECK *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bCheck AND NOT BasisStationsParameter.bReset ) THEN
  CASE steplCheck OF
    (*SYSTEM CHECK=========================*)
    STEP_0_E:

      BasisStationsParameter.bCheckAbgeschlossen := FALSE;

      IF ( NOT Glastransport.bpFehler ) THEN
        steplCheck := STEP_5_E;
      ELSE
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplCheck := STEP_900_E;
      END_IF

    (*SYSTEM CHECK=========================*)
    STEP_5_E:
      (* Hinweis:
         - Prüfen ob der Antrieb bereit für den Systemcheck ist      
      *)
      IF Glastransport.Antrieb.bpReglerBereit THEN

        steplCheck := STEP_10_E;

      ELSE

        BasisStationsParameter.awFehlerInformationen[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplCheck := STEP_900_E;

      END_IF

    (*SYSTEM CHECK=========================*)
    STEP_10_E:
      (* Anmerkung:
         - Starten des SystemChecks [Glastransport]
      *)
      Glastransport.pAuftrag                := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.wpSystemCheckMitStation := 0; (* wpSystemCheckMitStation;*)
      Glastransport.wpSystemCheckMitWand    := 0; (* wpSystemCheckMitWand;*)

      Glastransport.bpCheckMitVorgaenger    := FALSE; (* bpCheckMitVorgaenger;*)
      Glastransport.bpCheckMitNachfolger    := FALSE; (* bpCheckMitNachfolger; *)
      Glastransport.InGlasTransportVorgaenger  := BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1];
      Glastransport.InGlasTransportNachfolger  := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1];

      Glastransport.bpCheck := TRUE;

      steplCheck := STEP_20_E;

    (*SYSTEM CHECK=========================*)
    STEP_20_E:
      (* Hinweis:
         - SystemCheck erfolgreich
           => Glastransport
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpCheck := FALSE;
        steplCheck := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpCheck := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplCheck := STEP_900_E;
      END_IF


    (*SYSTEM CHECK=========================*)
    STEP_900_E:
      (* Fehlerschritt
      *)
      BasisStationsParameter.bFehler := TRUE;

    (*SYSTEM CHECK=========================*)
    STEP_1000_E:
      BasisStationsParameter.bCheckAbgeschlossen := TRUE;

  (*SYSTEM CHECK=========================*)
  END_CASE
ELSE
  IF ( steplCheck > STEP_0_E ) THEN
    BasisStationsParameter.bCheckAbgeschlossen := FALSE;
    Glastransport.bpCheck := FALSE;
    Glastransport.bpCheckMitVorgaenger    := FALSE;
    Glastransport.bpCheckMitNachfolger    := FALSE;
    steplCheck := STEP_0_E;
  END_IF
END_IF

(***************************************************************************************************)
(*E N D E - SystemCheck *)
(***************************************************************************************************)
END_ACTION