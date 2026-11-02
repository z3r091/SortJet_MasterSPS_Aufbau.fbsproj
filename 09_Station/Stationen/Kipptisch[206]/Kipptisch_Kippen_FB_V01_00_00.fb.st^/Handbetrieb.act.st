(* METADATA
{
  "v3Meta": {
    "objectGuid": "0a60150a-316d-42cd-8145-e14c8d6bc118"
  }
}
*)
ACTION Handbetrieb
//-------------------------------------------------------------------------------------------------
// AKTION HANDFUNKTIONEN
//-------------------------------------------------------------------------------------------------

IF (      bpBetriebsartHand
     AND bpFreigabe
     AND NOT bpStartKippenAuf
     AND NOT bpStartKippenAb
     AND NOT bpReferenz
     AND NOT bgVisuAntriebeVerfahrenAktiv  )
THEN

  Antrieb.rpBeschleunigung  := (ppAntriebsInformationen.rpMaxBeschleunigung);
  Antrieb.rpVerzoegerung    := (ppAntriebsInformationen.rpMaxVerzoegerung);
  Antrieb.rpGeschwindigkeit := (ppAntriebsInformationen.rpHandGeschwindigkeit);

  IF ( bpHandfahrenPlus AND NOT bpHandfahrenMinus ) THEN
    IF ( Antrieb.bpIstReferenziert ) THEN
      Antrieb.rpZielposition    := ppParameterBaustein.rPosition90Grad;
      Antrieb.wpBetriebsart     := ABSOLUT;
    END_IF

  ELSIF ( bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN
    IF ( Antrieb.bpIstReferenziert ) THEN
      Antrieb.rpZielposition    := ppParameterBaustein.rPosition0Grad;
      Antrieb.wpBetriebsart     := ABSOLUT;

    END_IF

  ELSIF ( NOT bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;

  END_IF

END_IF
END_ACTION