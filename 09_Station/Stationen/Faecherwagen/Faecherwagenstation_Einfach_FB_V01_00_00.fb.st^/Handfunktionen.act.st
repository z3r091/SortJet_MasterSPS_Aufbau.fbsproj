(* METADATA
{
  "v3Meta": {
    "objectGuid": "83a12dd4-1c19-48f5-84f9-c64958df1fb4"
  }
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// HANDFUNKTIONEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Handbefehle (MMI-Bits, Rolltor auch Visu-Bits) nur im Handbetrieb wirksam
   - Bitverteilung: 1/2 Arretierung auf/zu, 5/6 Rolltor auf/ab
*)
blHandFreigabe := blBetriebsartHand;

IF    NOT BasisStationsParameter.bEintransport[cWAND_1]
      AND NOT BasisStationsParameter.bAustransport[cWAND_1]
      AND NOT blBetriebartCheck
THEN
  blArretierungOeffnen    := blHandFreigabe AND dwlHandfunktionen.1 AND NOT blArretierungSchliessen;
  blArretierungSchliessen := blHandFreigabe AND dwlHandfunktionen.2 AND NOT blArretierungOeffnen;
  blRolltorAuf            := blHandFreigabe AND ( dwlHandfunktionen.5 OR bgVISUFWRolltorHoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )   AND NOT blRolltorAb;
  blRolltorAb             := blHandFreigabe AND ( dwlHandfunktionen.6 OR bgVISUFWRolltorRunter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blRolltorAuf;

  // Nach einer Handfunktion ist der Zustand der Station nicht mehr sicher bekannt
  IF blHandFreigabe AND ( dwlHandfunktionen <> 0 ) THEN
    eLetzterStatus := eLetzter_FW_Status.eKeine_Info;
  END_IF

END_IF

(* Hinweis:
   - Zuruecksetzen bei Flanke Hand oder fallender Flanke Automatik
*)
rtlBetriebsartHand( CLK := blBetriebsartHand );
ftlBetriebsartAutomatik( CLK := blBetriebsartAutomatik );

IF rtlBetriebsartHand.Q OR
   ftlBetriebsartAutomatik.Q
THEN

  IF ( ( steplAusschleusen > STEP_0_E )
       OR ( steplEinschleusen > STEP_0_E ) )
  THEN
    steplAusschleusen       := STEP_0_E;
    steplEinschleusen       := STEP_0_E;
    blArretierungOeffnen    := FALSE;
    blArretierungSchliessen := FALSE;
    blRolltorAuf            := FALSE;
    blRolltorAb             := FALSE;
  END_IF

END_IF

HandfunktionenStatus();
END_ACTION