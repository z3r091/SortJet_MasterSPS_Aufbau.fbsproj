(* METADATA
{
  "v3Meta": {
    "objectGuid": "ea1c32ee-fbe3-43e2-abd3-8d97254c3ec1"
  }
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// HANDBETRIEB
//-------------------------------------------------------------------------------------------------
IF (  bpHand
     AND NOT bpScheibenNeuAusrichten
     AND NOT bpGlastransportTest
     AND NOT bpSlaveKopplung
     AND NOT bpStarteHebeVorgang )
THEN

  bpOutBereitZumEintransport := FALSE;
  bpOutBereitZumAustransport := FALSE;

  // Glastransport verfahren
  //   - Plus - Minus
  Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
  Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
  
  IF NOT bgVisuAntriebeVerfahrenAktiv then
    IF ( bpHandfahrenPositiv AND NOT bpHandfahrenNegativ ) AND Antrieb.bpReglerBereit THEN
      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
      Antrieb.wpBetriebsart     := HANDPLUS;
    
    ELSIF ( bpHandfahrenNegativ AND NOT bpHandfahrenPositiv ) AND Antrieb.bpReglerBereit THEN
      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
      Antrieb.wpBetriebsart     := HANDMINUS;
    
    ELSIF ( NOT bpHandfahrenNegativ AND NOT bpHandfahrenPositiv ) THEN
      Antrieb.rpGeschwindigkeit := REAL#0;
      Antrieb.wpBetriebsart     := KEINE_FUNKTION;
    
    END_IF
  END_IF

  // Glastransport anheben
  //   - Transfershuttle hebt
  IF ( bpHandGlastransportAnheben ) THEN
    out_bShuttleAnheben := TRUE;
  ELSE
    out_bShuttleAnheben := FALSE;
  END_IF

  // Handfunktion:
  //   - (default Luftabfragen) ScheibenKontrolle anheben
  IF ( bpHandScheibenKontrolleEinlaufseiteAnheben ) THEN
    out_bScheibenKontrolleEinlaufSeiteAuf := TRUE;
  ELSE
    out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
  END_IF

  IF ( bpHandScheibenKontrolleAuslaufseiteAnheben ) THEN
    out_bScheibenKontrolleAuslaufSeiteAuf := TRUE;
  ELSE
    out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
  END_IF

  // Handfunktion:
  //   - ScheibenKontrolle Luftsensoren aktivieren
  blScheibenKontrolleEinlaufseiteEin := bpHandScheibenKontrolleEinlaufseiteEin;
  blScheibenKontrolleAuslaufseiteEin := bpHandScheibenKontrolleAuslaufseiteEin;

END_IF
END_ACTION