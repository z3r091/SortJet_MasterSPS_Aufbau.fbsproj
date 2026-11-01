(* METADATA
{
  "v3Meta": {
    "objectGuid": "c483e306-5c35-4c51-98d1-e5f41e8e1930"
  }
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// AKTION: HANDFUNKTIONEN
//-------------------------------------------------------------------------------------------------
IF (  NOT bpAutomatikAktiv
     AND NOT bpCheck
     AND NOT bpReset
     AND NOT bpReferenz
     AND NOT bgVisuAntriebeVerfahrenAktiv )
THEN

  // Handplus oder Handminus den Glastransport verfahren
  //   Uebergabe an den Antrieb:
  //     - Geschwindigkeit / Beschleunigung / Verzoegerung
  Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
  Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
  Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;

  IF   bpHandfahrenPlus
       AND NOT bpHandfahrenMinus
       AND blAntriebsKopplungAktiv
  THEN
    Antrieb.wpBetriebsart := HANDPLUS;

  ELSIF bpHandfahrenMinus
        AND NOT bpHandfahrenPlus
        AND blAntriebsKopplungAktiv
  THEN
    Antrieb.wpBetriebsart := HANDMINUS;

  ELSIF ( NOT bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

  END_IF

END_IF
END_ACTION