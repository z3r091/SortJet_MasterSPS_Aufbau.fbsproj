(* METADATA
{
	"v3Meta": {
		"objectGuid": "6b034301-f479-45bd-ad09-2cefefa1cbc8"
	}
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// HANDFUNKTIONEN
//-------------------------------------------------------------------------------------------------

IF (  NOT bpAutomatikAktiv
     AND NOT bpVerfahreShuttle
     AND NOT bpReferenz
     AND NOT bpReset
     AND NOT bgVISUVerfahreShuttle[stStationsNummern.NummerSPS]
     AND NOT bgVisuAntriebeVerfahrenAktiv )
THEN

  IF ( bpHandfahrenPlus AND NOT bpHandfahrenMinus ) THEN

    Antrieb.bpFreigabe := blFreigabeGesetzt := bpFreigabe AND bpVerfahrfreigabe;

    IF NOT bgVISUQuerfahrtVor[stStationsNummern.NummerSPS] THEN
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpHandGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpRuckzeit         := 500.0;
    END_IF

    IF ( Antrieb.bpIstReferenziert ) THEN
      Antrieb.rpZielposition := Antrieb.rpMaxPosition;
      Antrieb.wpBetriebsart  := ABSOLUT;
    ELSE
      Antrieb.wpBetriebsart := HANDPLUS;
    END_IF

  ELSIF ( bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN

    Antrieb.bpFreigabe := blFreigabeGesetzt := bpFreigabe AND bpVerfahrfreigabe;

    IF NOT bgVISUQuerfahrtZurueck[stStationsNummern.NummerSPS] THEN
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpHandGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpRuckzeit         := 500.0;
    END_IF

    IF ( Antrieb.bpIstReferenziert ) THEN
      Antrieb.rpZielposition := Antrieb.rpMaxPosition;
      Antrieb.wpBetriebsart  := ABSOLUT;
    ELSE
      Antrieb.wpBetriebsart := HANDPLUS;
    END_IF

  ELSIF ( NOT bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN
    blFreigabeGesetzt := FALSE;
    Antrieb.bpFreigabe := tofAntriebFreigabe.Q; // Zeitverzögert abschalten
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

  END_IF

END_IF
END_ACTION