(* METADATA
{
	"v3Meta": {
		"objectGuid": "487c06bf-c3e1-409d-bb2c-ab52f09a8275"
	}
}
*)
ACTION Eintransport
(***************************************************************************************************)
(* AKTION: EINTRANSPORT *)
(***************************************************************************************************)
IF( BasisStationsParameter.bEintransport[cWAND_1]
  AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF Hubrahmen.bpFehler THEN
    Hubrahmen.bpStartAusfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF Anschlag.bpFehler THEN
    Anschlag.bpStartEinfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Anschlag.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF Messachse.bpFehler THEN
    Messachse.bpPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF

  
  CASE steplEintransport OF
(* EINTRANSPORT ==================================*)
    STEP_0_E:

      tlZeitBereitAnzulegen := TIME();

      BasisStationsParameter.eStatusAuftrag   := eAuftragAktiv;

      IF ( in_bMotorschutzGeblaese_Ok ) THEN

        steplEintransport := STEP_10_E;

      ELSE
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplEintransport := STEP_900_E;

      END_IF

(* EINTRANSPORT ==================================*)
    STEP_10_E:

      (* Anmerkung:
          - Glastransport Ausfahren
          - Anschläge einfahren
          - Messachse positionieren
      *)
      Hubrahmen.bpStartAusfahren := TRUE;
      Anschlag.bpStartEinfahren  := TRUE;

      IF Messachse.Antrieb.rpMaxPosition < ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) THEN
        Messachse.rpZielPosition := Messachse.Antrieb.rpMaxPosition;
      ELSE
        Messachse.rpZielPosition := ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset );
      END_IF
      Messachse.bpPositionierung := TRUE;

      steplEintransport := STEP_20_E;

(* EINTRANSPORT ==================================*)
    STEP_20_E:

      (* Anmerkung:
          - Glastransport Ausfahren
          - Anschläge einfahren
          - Messachse.positionieren
      *)
      IF Hubrahmen.bpDone AND Messachse.bpDone AND Anschlag.bpDone THEN
        Anschlag.bpStartEinfahren        := FALSE;
        Hubrahmen.bpStartAusfahren       := FALSE;
        Messachse.bpPositionierung := FALSE;
        steplEintransport := STEP_30_E;
      END_IF

(* EINTRANSPORT ==================================*)
    STEP_30_E:

      (* Anmerkung:
          - Drosselklappe öffnen, damit auch sehr schweres Glas transportiert werden kann, indem die Luft das Glas leicht anhebt
      *)
      blMerkerDrosselklappeAuf := TRUE;

      (* Anmerkung:
          - Glastransport Eintransport starten
      *)
      Glastransport.eGlastyp := BasisStationsParameter.wGlastyp[cWAND_1];
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpEintransport := TRUE;

      steplEintransport := STEP_40_E;

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF Glastransport.bpFehler THEN
        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplEintransport := STEP_900_E;
      END_IF

(* EINTRANSPORT ==================================*)
    STEP_40_E:

      out_bAmpelSignalGruenScheibeAnlegen  := TRUE;

      (* Scheibe wird nicht Eintransportiert sondern soll angelegt werden *)
      IF rtlFussleisteStart.Q OR ftlVSGAutomatikBetriebBeendet.Q THEN
        out_bAmpelSignalGruenScheibeAnlegen := FALSE;
        BasisStationsParameter.bAnlegen := TRUE;
		  BasisStationsParameter.bEintransport[cWAND_1] := FALSE;
      END_IF

      (* Anmerkung:
          - Auf den Glastransport warten
      *)
      IF Glastransport.bpDone THEN

        out_bAmpelSignalGruenScheibeAnlegen  := FALSE;

        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.eStatusAuftrag   := eAuftragErfolgreich;
        steplEintransport := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
         - Anschlag
      *)
      IF Glastransport.bpFehler THEN
        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplEintransport := STEP_900_E;
      END_IF
      IF Anschlag.bpFehler THEN
        Anschlag.bpStartAusfahren := FALSE;
        BasisStationsParameter.wFehlerNummer := Anschlag.wpFehlerNr;
        steplEintransport := STEP_900_E;
      END_IF

(* EINTRANSPORT ==================================*)
    STEP_900_E:
      BasisStationsParameter.eStatusAuftrag   := eAuftragFehler;
      BasisStationsParameter.bFehler := TRUE;

(* EINTRANSPORT ==================================*)
    STEP_1000_E:
      BasisStationsParameter.dwWartezeit[cWAND_1] := 0;
      epTypeHoehenmessung := Modus_Vermessen_OberUndUnterkante_2_Sensoren;
      BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := TRUE;

(* EINTRANSPORT ==================================*)
  END_CASE
ELSE

  IF( steplEintransport > STEP_0_E )THEN
    Glastransport.bpEintransport          := FALSE;
    Anschlag.bpStartEinfahren             := FALSE;
    Anschlag.bpStartAusfahren             := FALSE;
    out_bAmpelSignalGruenScheibeAnlegen   := FALSE;
    Hubrahmen.bpStartAusfahren            := FALSE;
    Messachse.bpPositionierung      := FALSE;
    Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := FALSE;
    BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;
    steplEintransport := STEP_0_E;
  END_IF

END_IF
END_ACTION