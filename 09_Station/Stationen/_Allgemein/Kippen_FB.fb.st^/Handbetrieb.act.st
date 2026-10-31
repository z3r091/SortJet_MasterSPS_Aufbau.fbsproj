(* METADATA
{
  "v3Meta": {
    "objectGuid": "12ac65a5-1cd6-4642-b3fa-93f61ca51287"
  }
}
*)
ACTION Handbetrieb
(***************************************************************************************************)
(* HANDBETRIEB *)
(***************************************************************************************************)

IF (  NOT bpAutomatikAktiv
  AND NOT bpReferenz
  AND NOT bpPositionieren
  AND NOT bpReset )
THEN

  Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
  Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
  Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;

  IF ( bpHandfahrenPlus AND NOT bpHandfahrenMinus ) THEN
    Antrieb.wpBetriebsart    := HANDPLUS;

  ELSIF ( bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN
    Antrieb.wpBetriebsart    := HANDMINUS;

  ELSIF ( NOT bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;

  END_IF

END_IF
END_ACTION