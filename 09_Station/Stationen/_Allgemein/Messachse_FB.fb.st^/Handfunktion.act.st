(* METADATA
{
  "v3Meta": {
    "objectGuid": "93a08298-272e-4cc3-bfce-90b6693b7ecb"
  }
}
*)
ACTION Handfunktion
(***************************************************************************************************)
(* AKTION: HANDBETRIEB *)
(***************************************************************************************************)
IF (      bpBetriebsartHand
     AND NOT bpPositionierung
     AND NOT bpReferenz
     AND NOT bpReset
     AND NOT bpHandReferenz
     AND NOT bpVermessen_Oberkante_1_Sensor
     AND NOT bpVermessen_OberUndUnterkante_2_Sensoren
     AND NOT bgVisuAntriebeVerfahrenAktiv )
THEN

  Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
  Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
  Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;

  IF( bpHandplus AND NOT bpHandminus ) THEN

    IF ( Antrieb.bpIstReferenziert ) THEN
      Antrieb.rpZielposition    := Antrieb.rpMaxPosition;
      Antrieb.wpBetriebsart     := ABSOLUT;
    ELSE
      Antrieb.wpBetriebsart := HANDPLUS;
    END_IF

  ELSIF( bpHandminus AND NOT bpHandplus)THEN

    IF ( Antrieb.bpIstReferenziert ) THEN
      Antrieb.rpZielposition    := Antrieb.rpMinPosition;
      Antrieb.wpBetriebsart     := ABSOLUT;
    ELSE
      Antrieb.wpBetriebsart := HANDMINUS;
    END_IF

  ELSIF( NOT bpHandplus AND NOT bpHandminus ) THEN
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
  END_IF

END_IF
END_ACTION