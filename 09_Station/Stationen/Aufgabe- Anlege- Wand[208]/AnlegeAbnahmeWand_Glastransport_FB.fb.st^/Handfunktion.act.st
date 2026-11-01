(* METADATA
{
  "v3Meta": {
    "objectGuid": "8bce7a83-0a56-4602-b604-8b690a6ebca1"
  }
}
*)
ACTION Handfunktion
(***************************************************************************************************)
(* Handfunktionen *)
(***************************************************************************************************)
// Aufruf Basic_Station Aktion
SUPER^.Handfunktionen();

ftlScheibeZurueckFahren ( CLK := bpScheibeZurueckFahren );

IF ( (  bpScheibeZurueckFahren )
     AND bpAnforderungHandfunktion )
THEN
  (* Anmerkung:
   - Knebel Glastransport zurueck 
  *)
  IF NOT bpSensorEinlauf THEN
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit ;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.wpBetriebsart := HANDMINUS;
  ELSE
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
  END_IF

ELSIF ( ftlScheibeZurueckFahren.Q) THEN
  bpScheibeZurueckFahren := FALSE;
  Antrieb.wpBetriebsart := KEINE_FUNKTION;

END_IF
END_ACTION