(* METADATA
{
  "v3Meta": {
    "objectGuid": "49e61962-d159-4127-bd8a-15e72a9d6a46"
  }
}
*)
ACTION Handfunktionen
(* HANDFUNKTIONEN *)
IF    NOT BasisStationsParameter.bEintransport[1] 
      AND NOT BasisStationsParameter.bAustransport[1] 
      AND NOT blBetriebsartCheck
THEN
  blGreiferOeffnen            := ( dwpHandfunktionen.11 OR bgVISUFWGreiferEinfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blGreiferSchliessen;
  blGreiferSchliessen         := ( dwpHandfunktionen.12 OR bgVISUFWGreiferAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blGreiferOeffnen;
  blEntriegelungSchliessen    := ( dwpHandfunktionen.2 OR bgVISUFWEntriegelungEinfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blEntriegelungOeffnen;
  blEntriegelungOeffnen       := ( dwpHandfunktionen.3 OR bgVISUFWEntriegelungAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blEntriegelungSchliessen;
  blGegenhalterOeffnen        := ( dwpHandfunktionen.0 OR bgVISUFWGegenhalterEinfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blGegenhalterSchliessen;
  blGegenhalterSchliessen     := ( dwpHandfunktionen.1 OR bgVISUFWGegenhalterAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blGegenhalterOeffnen;
  blLineareinheitVor          := ( dwpHandfunktionen.7 OR bgVISUFWLinearEinheitVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )  AND NOT blLineareinheitZurueck AND NOT blLineareinheitShuttle;
  blLineareinheitZurueck      := ( dwpHandfunktionen.8 OR bgVISUFWLinearEinheitZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )  AND NOT blLineareinheitVor AND NOT blLineareinheitShuttle;
  blLineareinheitShuttle      := ( dwpHandfunktionen.9 OR bgVISUFWLinearEinheitShuttle [BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] AND NOT blLineareinheitZurueck AND NOT blLineareinheitVor);
  blRolltorAuf                := ( dwpHandfunktionen.5  OR bgVISUFWRolltorHoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blRolltorAb;
  blRolltorAb                 := ( dwpHandfunktionen.6 OR bgVISUFWRolltorRunter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blRolltorAuf;
    
  IF dwpHandfunktionen <> 0 THEN
    eLetzterStatus := eLetzter_FW_Status.eKeine_Info;
  END_IF
  
END_IF

(* Hinweis:
   - Zurücksetzten bei Flanke Auto oder Flanke Hand
*)
rtlBetriebsartHand( CLK := blBetriebsartHand );
ftlBetriebsartAutomatik( CLK := blBetriebsartAutomatik );

IF rtlBetriebsartHand.Q OR
   ftlBetriebsartAutomatik.Q
THEN

  IF ( ( steplAusschleusen > STEP_0_E )
       OR ( steplEinschleusen > STEP_0_E ) )
  THEN
    steplAusschleusen           := STEP_0_E;
    steplEinschleusen           := STEP_0_E;
    blLineareinheitVor          := FALSE;
    blLineareinheitZurueck      := FALSE;
    blLineareinheitShuttle      := FALSE;
    blEntriegelungOeffnen       := FALSE;
    blEntriegelungSchliessen    := FALSE;
    blGegenhalterOeffnen        := FALSE;
    blGegenhalterSchliessen     := FALSE;
    blGreiferOeffnen            := FALSE;
    blGreiferSchliessen         := FALSE;
    blRolltorAuf                := FALSE;
    blRolltorAb                 := FALSE;
  END_IF

END_IF
END_ACTION