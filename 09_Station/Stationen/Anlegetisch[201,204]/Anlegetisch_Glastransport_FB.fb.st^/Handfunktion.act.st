(* METADATA
{
  "v3Meta": {
    "objectGuid": "ec09d6f3-db6e-4802-bacf-591f1d66beb0"
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
ftlScheibeVorFahren ( CLK := bpScheibeVorFahren );

IF ( (  bpScheibeZurueckFahren )
     AND bpAnforderungHandfunktion )
THEN
  (* Anmerkung:
   - Knebel Glastransport zurueck 
  *)
  IF NOT bpSensorEinlauf THEN
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.wpBetriebsart     := HANDMINUS;

    // Am Ende langsam fahren
    IF bpSensorEinlaufVorAb THEN
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10 ;
    END_IF

  ELSE
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
  END_IF
  
ELSIF ( (  bpScheibeVorFahren )
        AND bpAnforderungHandfunktion )
THEN
  (* Anmerkung:
   - Knebel Glastransport vor 
  *)
  IF NOT bpSensorAuslauf THEN
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.wpBetriebsart     := HANDPLUS;

    // Am Ende langsam fahren
    IF bpSensorAuslaufVorAb THEN
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
    END_IF

  ELSE
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
  END_IF  
  
ELSIF ( ftlScheibeZurueckFahren.Q 
        OR ftlScheibeVorFahren.Q ) 
THEN
  bpScheibeZurueckFahren := FALSE;
  bpScheibeVorFahren     := FALSE;
  Antrieb.wpBetriebsart  := KEINE_FUNKTION;

END_IF
END_ACTION