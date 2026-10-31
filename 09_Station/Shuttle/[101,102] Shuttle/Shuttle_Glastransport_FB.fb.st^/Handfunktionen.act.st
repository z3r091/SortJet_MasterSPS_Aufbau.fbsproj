(* METADATA
{
  "v3Meta": {
    "objectGuid": "a2bbfebd-7248-4b3d-9c29-f36aff6540f7"
  }
}
*)
ACTION Handfunktionen
(***************************************************************************************************)
(* AKTION HANDFUNKTION *)
(***************************************************************************************************)
IF (  NOT bpAutomatikAktiv
  AND NOT bpCheck
  AND NOT bpReset
  AND NOT bpFahreReferenz
  AND NOT bgVisuAntriebeVerfahrenAktiv  )
THEN

  (* Handplus oder Handminus den Glastransport verfahren
     Uebergabe an den Antrieb:
      - Geschwindigkeit 
      - Beschleunigung  
      - Verzoegerung    
  *)

  Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
  Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

  IF ( bpHandfahrenPlus AND NOT bpHandfahrenMinus ) AND ( NOT bpSlaveAntriebVorhanden OR blAntriebsKopplungAktiv ) THEN
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
    Antrieb.wpBetriebsart     := HANDPLUS;

  ELSIF ( bpHandfahrenMinus AND NOT bpHandfahrenPlus ) AND ( NOT bpSlaveAntriebVorhanden OR blAntriebsKopplungAktiv ) THEN
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
    Antrieb.wpBetriebsart     := HANDMINUS;

  ELSIF ( NOT bpHandfahrenMinus AND NOT bpHandfahrenPlus ) OR NOT ( NOT bpSlaveAntriebVorhanden OR blAntriebsKopplungAktiv ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

  END_IF

END_IF
END_ACTION