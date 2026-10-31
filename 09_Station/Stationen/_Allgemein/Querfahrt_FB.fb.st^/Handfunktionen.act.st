(* METADATA
{
  "v3Meta": {
    "objectGuid": "ffc0751e-13a9-4d1f-8741-648c241a9afd"
  }
}
*)
ACTION Handfunktionen
(***************************************************************************************************)
(*  HANDFUNKTIONEN *)
(***************************************************************************************************)

IF (  NOT bpAutomatikAktiv
  AND NOT bpReferenz
  AND NOT bpPositionieren
  AND NOT bpReset
  AND NOT bgVisuAntriebeVerfahrenAktiv  )
THEN

  IF ( bpHandfahrenPlus AND NOT bpHandfahrenMinus ) THEN

    IF ( Antrieb.bpFreigabe ) THEN
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpHandGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpZielPosition     := Antrieb.rpMaxPosition;
      Antrieb.wpBetriebsart      := ABSOLUT;
    END_IF

  ELSIF ( bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN

    IF ( Antrieb.bpFreigabe) THEN
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpHandGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpZielPosition     := Antrieb.rpMinPosition;
      Antrieb.wpBetriebsart      := ABSOLUT;

    END_IF

  ELSIF ( NOT bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

  END_IF

END_IF
END_ACTION