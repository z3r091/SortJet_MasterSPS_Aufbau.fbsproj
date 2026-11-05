(* METADATA
{
  "v3Meta": {
    "objectGuid": "fa8fcfc4-6584-4f5b-b504-18c3b608a83d"
  }
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// AKTION: HANDBETRIEB
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Nur ohne Automatik und ohne laufenden Reset / Systemcheck / Referenz / Grundstellungsfahrt
   - Greiferachse: Plus faehrt Richtung Uebergabeposition Auslaufseite, Minus Richtung Einlaufseite
   - Greiferzange: alle vorhandenen Zangen gemeinsam (nicht vorhandene sind deaktiviert)
   - Glasrueckhalter: alle vorhandenen, solange angewaehlt
   - Beim Verlassen des Handbetriebs werden die Handbefehle zurueckgenommen
*)
IF (     NOT bpAutomatikAktiv
     AND NOT bpStartGrundstellungsfahrt
     AND NOT bpCheck
     AND NOT bpReset
     AND NOT bpFahreReferenz )
THEN

  blHandAktiv := TRUE;

  // Handfunktion:
  //   - Greiferachse verfahren
  IF NOT bgVisuAntriebeVerfahrenAktiv THEN
    IF ( bpHandfahrenPlus AND NOT bpHandfahrenMinus ) THEN
      M_Fahren( epBetriebsart     := ABSOLUT,
                rpZielPosition    := ppParameterGreifer.rUebergabePosition_Auslauf,
                rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit );
      bpVorpositioniertEintransport := FALSE;

    ELSIF ( bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN
      M_Fahren( epBetriebsart     := ABSOLUT,
                rpZielPosition    := ppParameterGreifer.rUebergabePosition_Einlauf,
                rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit );
      bpVorpositioniertEintransport := FALSE;

    ELSE
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

    END_IF
  END_IF

  // Handfunktion:
  //   - Greifer aus- / einfahren
  GreiferHub.bpStartAusfahren := bpHandGreiferAusfahren AND NOT bpHandGreiferEinfahren;
  GreiferHub.bpStartEinfahren := bpHandGreiferEinfahren AND NOT bpHandGreiferAusfahren;

  // Handfunktion:
  //   - Greiferzange schliessen / oeffnen 16 / 23 / 29 mm
  IF ( bpHandZangeSchliessen AND NOT ( bpHandZangeOeffnen16mm OR bpHandZangeOeffnen23mm OR bpHandZangeOeffnen29mm ) ) THEN
    Zange[cZANGE_EINLAUF].epSollZylinderStellung  := eZylinderGeschlossen;
    Zange[cZANGE_AUSLAUF].epSollZylinderStellung  := eZylinderGeschlossen;
    Zange[cZANGE_EINLAUF].bpStartZylinderBewegung := TRUE;
    Zange[cZANGE_AUSLAUF].bpStartZylinderBewegung := TRUE;

  ELSIF ( bpHandZangeOeffnen16mm AND NOT ( bpHandZangeSchliessen OR bpHandZangeOeffnen23mm OR bpHandZangeOeffnen29mm ) ) THEN
    Zange[cZANGE_EINLAUF].epSollZylinderStellung  := eZylinderStellung16mm;
    Zange[cZANGE_AUSLAUF].epSollZylinderStellung  := eZylinderStellung16mm;
    Zange[cZANGE_EINLAUF].bpStartZylinderBewegung := TRUE;
    Zange[cZANGE_AUSLAUF].bpStartZylinderBewegung := TRUE;

  ELSIF ( bpHandZangeOeffnen23mm AND NOT ( bpHandZangeSchliessen OR bpHandZangeOeffnen16mm OR bpHandZangeOeffnen29mm ) ) THEN
    Zange[cZANGE_EINLAUF].epSollZylinderStellung  := eZylinderStellung23mm;
    Zange[cZANGE_AUSLAUF].epSollZylinderStellung  := eZylinderStellung23mm;
    Zange[cZANGE_EINLAUF].bpStartZylinderBewegung := TRUE;
    Zange[cZANGE_AUSLAUF].bpStartZylinderBewegung := TRUE;

  ELSIF ( bpHandZangeOeffnen29mm AND NOT ( bpHandZangeSchliessen OR bpHandZangeOeffnen16mm OR bpHandZangeOeffnen23mm ) ) THEN
    Zange[cZANGE_EINLAUF].epSollZylinderStellung  := eZylinderStellung29mm;
    Zange[cZANGE_AUSLAUF].epSollZylinderStellung  := eZylinderStellung29mm;
    Zange[cZANGE_EINLAUF].bpStartZylinderBewegung := TRUE;
    Zange[cZANGE_AUSLAUF].bpStartZylinderBewegung := TRUE;

  ELSE
    Zange[cZANGE_EINLAUF].bpStartZylinderBewegung := FALSE;
    Zange[cZANGE_AUSLAUF].bpStartZylinderBewegung := FALSE;

  END_IF

  // Handfunktion:
  //   - Glasrueckhalter ausfahren
  ablRueckhalterAusfahren[cZANGE_EINLAUF] := bpHandGlasRueckhalterAusfahren;
  ablRueckhalterAusfahren[cZANGE_AUSLAUF] := bpHandGlasRueckhalterAusfahren;

ELSIF ( blHandAktiv ) THEN

  (* Hinweis:
     - Handbefehle beim Verlassen des Handbetriebs zuruecknehmen
  *)
  Antrieb.wpBetriebsart := KEINE_FUNKTION;

  GreiferHub.bpStartAusfahren                   := FALSE;
  GreiferHub.bpStartEinfahren                   := FALSE;
  Zange[cZANGE_EINLAUF].bpStartZylinderBewegung := FALSE;
  Zange[cZANGE_AUSLAUF].bpStartZylinderBewegung := FALSE;

  ablRueckhalterAusfahren[cZANGE_EINLAUF] := FALSE;
  ablRueckhalterAusfahren[cZANGE_AUSLAUF] := FALSE;

  blHandAktiv := FALSE;

END_IF
END_ACTION