(* METADATA
{
  "v3Meta": {
    "objectGuid": "7937b9f7-5fc3-49e8-92a6-a4178f5f7724"
  }
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// HANDFUNKTIONEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Handbefehle (MMI-Bits, Rolltor auch Visu-Bits) nur im Handbetrieb wirksam
   - Bitverteilung: 0/1 Hubrahmen heben/senken, 2/3 Faecherwagen vor/zurueck, 5/6 Rolltor auf/ab,
                    7/8 Anschlag auf/ab, 9/10 Anschlag vor/zurueck (Option AGV),
                    11/12 Zentrierung oeffnen/schliessen
*)
blHandFreigabe := blBetriebsartHand;

IF    NOT BasisStationsParameter.bEintransport[cWAND_1]
      AND NOT BasisStationsParameter.bAustransport[cWAND_1]
      AND NOT blBetriebartCheck
      AND NOT blPositionskorrekturAktiv
THEN
  blHubrahmenHeben        := blHandFreigabe AND dwlHandfunktionen.0  AND NOT blHubrahmenSenken;
  blHubrahmenSenken       := blHandFreigabe AND dwlHandfunktionen.1  AND NOT blHubrahmenHeben;
  blFaecherwagenVor       := blHandFreigabe AND dwlHandfunktionen.2  AND NOT blFaecherwagenZurueck;
  blFaecherwagenZurueck   := blHandFreigabe AND dwlHandfunktionen.3  AND NOT blFaecherwagenVor;
  blRolltorAuf            := blHandFreigabe AND ( dwlHandfunktionen.5 OR bgVISUFWRolltorHoch[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )   AND NOT blRolltorAb;
  blRolltorAb             := blHandFreigabe AND ( dwlHandfunktionen.6 OR bgVISUFWRolltorRunter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) AND NOT blRolltorAuf;
  blAnschlagAuf           := blHandFreigabe AND dwlHandfunktionen.7  AND NOT blAnschlagAb;
  blAnschlagAb            := blHandFreigabe AND dwlHandfunktionen.8  AND NOT blAnschlagAuf;
  blAnschlagVor           := blHandFreigabe AND dwlHandfunktionen.9  AND NOT blAnschlagZurueck;
  blAnschlagZurueck       := blHandFreigabe AND dwlHandfunktionen.10 AND NOT blAnschlagVor;
  blZentrierungOeffnen    := blHandFreigabe AND dwlHandfunktionen.11 AND NOT blZentrierungSchliessen;
  blZentrierungSchliessen := blHandFreigabe AND dwlHandfunktionen.12 AND NOT blZentrierungOeffnen;

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
    blHubrahmenHeben        := FALSE;
    blHubrahmenSenken       := FALSE;
    blFaecherwagenVor       := FALSE;
    blFaecherwagenZurueck   := FALSE;
    blZentrierungOeffnen    := FALSE;
    blZentrierungSchliessen := FALSE;
    blAnschlagAuf           := FALSE;
    blAnschlagAb            := FALSE;
    blAnschlagVor           := FALSE;
    blAnschlagZurueck       := FALSE;
    blRolltorAuf            := FALSE;
    blRolltorAb             := FALSE;
  END_IF

END_IF

HandfunktionenStatus();
END_ACTION