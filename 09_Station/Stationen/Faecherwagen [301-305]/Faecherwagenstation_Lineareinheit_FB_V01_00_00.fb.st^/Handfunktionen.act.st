(* METADATA
{
	"v3Meta": {
		"objectGuid": "49e61962-d159-4127-bd8a-15e72a9d6a46"
	}
}
*)
ACTION Handfunktionen
// HANDFUNKTIONEN
(* Hinweis:
   - Handbefehle (MMI-Bits und Visu-Bits) nur im Handbetrieb wirksam
   - Ausserhalb des Handbetriebs werden die Befehle auf FALSE gehalten
   - Bitverteilung aus der Oberfläche (4 Seiten zu 7 Knoepfen):
     Seite 1:  0/1 Gegenhalter auf/zu, 2/3 Entriegelung zu/auf, 5/6 Rolltor auf/ab
     Seite 2:  7/8/9 Lineareinheit vor/zurueck/Shuttle, 11/12 Greifer auf/zu
*)
blHandFreigabe := blBetriebsartHand;

IF    NOT BasisStationsParameter.bEintransport[1]
      AND NOT BasisStationsParameter.bAustransport[1]
      AND NOT blBetriebartCheck
THEN
  blGreiferOeffnen            := blHandFreigabe AND ( dwlHandfunktionen.11 OR bgVISUFWGreiferEinfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blGreiferSchliessen;
  blGreiferSchliessen         := blHandFreigabe AND ( dwlHandfunktionen.12 OR bgVISUFWGreiferAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blGreiferOeffnen;
  blEntriegelungSchliessen    := blHandFreigabe AND ( dwlHandfunktionen.2 OR bgVISUFWEntriegelungEinfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blEntriegelungOeffnen;
  blEntriegelungOeffnen       := blHandFreigabe AND ( dwlHandfunktionen.3 OR bgVISUFWEntriegelungAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blEntriegelungSchliessen;
  blGegenhalterOeffnen        := blHandFreigabe AND ( dwlHandfunktionen.0 OR bgVISUFWGegenhalterEinfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blGegenhalterSchliessen;
  blGegenhalterSchliessen     := blHandFreigabe AND ( dwlHandfunktionen.1 OR bgVISUFWGegenhalterAusfahren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blGegenhalterOeffnen;
  blLineareinheitVor          := blHandFreigabe AND ( dwlHandfunktionen.7 OR bgVISUFWLinearEinheitVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )     AND NOT blLineareinheitZurueck AND NOT blLineareinheitShuttle;
  blLineareinheitZurueck      := blHandFreigabe AND ( dwlHandfunktionen.8 OR bgVISUFWLinearEinheitZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blLineareinheitVor AND NOT blLineareinheitShuttle;
  blLineareinheitShuttle      := blHandFreigabe AND ( dwlHandfunktionen.9 OR bgVISUFWLinearEinheitShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blLineareinheitZurueck AND NOT blLineareinheitVor;
  blRolltorAuf                := blHandFreigabe AND ( dwlHandfunktionen.5 OR bgVISUFWRolltorHoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )   AND NOT blRolltorAb;
  blRolltorAb                 := blHandFreigabe AND ( dwlHandfunktionen.6 OR bgVISUFWRolltorRunter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blRolltorAuf;

  IF blHandFreigabe AND ( dwlHandfunktionen <> 0 ) THEN
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

HandfunktionenStatus();
END_ACTION