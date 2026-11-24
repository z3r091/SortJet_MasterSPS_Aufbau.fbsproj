(* METADATA
{
	"v3Meta": {
		"objectGuid": "12ac65a5-1cd6-4642-b3fa-93f61ca51287"
	}
}
*)
ACTION Handbetrieb
//-------------------------------------------------------------------------------------------------
// HANDBETRIEB
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Plus faehrt absolut auf 90 Grad, Minus absolut auf 0 Grad (nur wenn referenziert)
   - Bei belegtem Einlauf- oder Auslaufsensor wird keine Betriebsart gesetzt, die Freigabe bleibt erhalten
*)
IF (  NOT bpAutomatikAktiv
     AND NOT bpReferenz
     AND NOT bpPositionieren
     AND NOT bpReset
     AND NOT bgVisuAntriebeVerfahrenAktiv )
THEN

  Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
  Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
  Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;

  IF ( bpSensorEinlauf OR bpSensorAuslauf OR NOT Antrieb.bpIstReferenziert ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

  ELSIF ( bpHandfahrenPlus AND NOT bpHandfahrenMinus ) THEN
    Antrieb.rpZielposition := ppParameterBaustein.rPosition90Grad;
    Antrieb.wpBetriebsart  := ABSOLUT;

  ELSIF ( bpHandfahrenMinus AND NOT bpHandfahrenPlus ) THEN
    Antrieb.rpZielposition := ppParameterBaustein.rPosition0Grad;
    Antrieb.wpBetriebsart  := ABSOLUT;

  ELSE
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

  END_IF

END_IF
END_ACTION