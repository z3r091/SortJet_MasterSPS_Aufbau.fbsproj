(* METADATA
{
	"v3Meta": {
		"objectGuid": "008eb84c-ed0d-4cb0-9376-462b0a38bc1c"
	}
}
*)
PROGRAM StatusAnlage
VAR

  // WORD
  wlIndex          : WORD;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  abpDruckluftOK    : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;
  bpAnlageOK        : BOOL;
END_VAR
VAR

  // TIMER
  toflDruckluftShuttleOK           : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF TOF;
  toflDruckluftTSShuttleOK         : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF TOF;
  toflDruckluft101_OK              : TOF;
  toflDruckluft102_OK              : TOF;
  toflDruckluftFW_OK               : TOF;

END_VAR

VAR

  // Druckluft
  in_bDruckluft_FW_OK                                  : BOOL; // Wartungseinheit
  in_bDruckluft_101_OK                        AT %I*   : BOOL; // Wartungseinheit
  in_bDruckluft_102_OK                        AT %I*   : BOOL; // Wartungseinheit

  // CAB 2
  in_bCAB2_KlimaGeraet_OK                     AT %I* : BOOL;
  in_bCAB2_LS_Netzteil_24V_OK                 AT %I* : BOOL;
  in_bCAB2_LS_24V_Schaltschrank_OK            AT %I* : BOOL;
  in_bCAB2_LS_24V_Boxen_OK                    AT %I* : BOOL;
  in_bCAB2_LS_400V_OK                         AT %I* : BOOL;
  in_bCAB2_LS_Netzfilter_400V_OK              AT %I* : BOOL;
  in_bCAB2_LS_230V_OK                         AT %I* : BOOL;
  in_bCAB2_Sicherheitsrelais_201_Kippen_OK    AT %I* : BOOL; // Sicherheitsrelais 201 Hydraulik / kippen OK

END_VAR

VAR CONSTANT

  // TIME
  ZEIT_DRUCKWAECHTERSIGNAL_ENTPRELLT : TIME := T#3s;

END_VAR
//-------------------------------------------------------------------------------------------------
// STATUS DER BASIS-KOMPONENTEN INHERHALB DER ANLAGE
//-------------------------------------------------------------------------------------------------

// Entprellen des Druckwaechter- Einheit => SHUTTLE
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  toflDruckluftShuttleOK[wlIndex]( IN := aShuttle[wlIndex].in_bDruckluft_OK OR starrShuttleBasisParameter[wlIndex].stMKs.bDeaktivieren ,
                                   PT := ZEIT_DRUCKWAECHTERSIGNAL_ENTPRELLT );
END_FOR

// Entprellen des Druckwaechter- Einheit => TRANSFERSHUTTLE
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  toflDruckluftTSShuttleOK[wlIndex]( IN := aTransfershuttles[wlIndex].in_bDruckluftWartungseinheitOK OR starrTransfershuttleBasisParameter[wlIndex].stMKs.bDeaktivieren ,
                                     PT := ZEIT_DRUCKWAECHTERSIGNAL_ENTPRELLT );
END_FOR

toflDruckluft101_OK( In := in_bDruckluft_101_OK, PT := ZEIT_DRUCKWAECHTERSIGNAL_ENTPRELLT );
toflDruckluft102_OK( In := in_bDruckluft_102_OK, PT := ZEIT_DRUCKWAECHTERSIGNAL_ENTPRELLT );
toflDruckluftFW_OK( In := in_bDruckluft_FW_OK OR %MX1.1, PT := ZEIT_DRUCKWAECHTERSIGNAL_ENTPRELLT ); // TODO wenn Wartungseinheit verbaut

// Auswertung und hier pruefen ob Betriebsstopp ausgeloest werden muss
// AK1 = Shuttle-Bereich (101, 102, 151, 152, Faecherwagen)
abpDruckluftOK[cAUTOMATIKKREIS_1] := (   ( toflDruckluftShuttleOK[cSHUTTLE_101].Q OR starrShuttleBasisParameter[cSHUTTLE_101].stMKs.bDeaktivieren OR NOT starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stStationsAufbau.bDruckluft )
                                       AND ( toflDruckluftShuttleOK[cSHUTTLE_102].Q OR starrShuttleBasisParameter[cSHUTTLE_102].stMKs.bDeaktivieren OR NOT starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stStationsAufbau.bDruckluft )
                                       AND ( toflDruckluftTSShuttleOK[cSHUTTLE_151].Q OR starrTransfershuttleBasisParameter[cSHUTTLE_151].stMKs.bDeaktivieren)
                                       AND ( toflDruckluftTSShuttleOK[cSHUTTLE_152].Q OR starrTransfershuttleBasisParameter[cSHUTTLE_152].stMKs.bDeaktivieren)
                                       AND toflDruckluft101_OK.Q
                                       AND toflDruckluft102_OK.Q
									   AND toflDruckluftFW_OK.Q
                                     ) OR bgInbetriebnahmeBit;

// AK2 = Foerderstrecke (201 - 208), keine gemeinsame Druckluftueberwachung
abpDruckluftOK[cAUTOMATIKKREIS_2] := ( TRUE
                                     ) OR bgInbetriebnahmeBit;


bpAnlageOK := ( ( in_bCAB2_LS_Netzteil_24V_OK
                  AND in_bCAB2_LS_24V_Schaltschrank_OK
                  AND in_bCAB2_LS_24V_Boxen_OK
                  AND in_bCAB2_LS_400V_OK
                  AND in_bCAB2_LS_Netzfilter_400V_OK )
                OR bgInbetriebnahmeBit) ;

// Meldungen CAB 2
WatchIo(NOT bgInbetriebnahmeBit AND NOT in_bCAB2_KlimaGeraet_OK,  ioccCAB2_Klimageraet_Nicht_OK);
WatchIo(NOT in_bCAB2_LS_Netzteil_24V_OK,                          ioccCAB2_Netzteil_24V_Nicht_Ok);
WatchIo(NOT in_bCAB2_LS_24V_Schaltschrank_OK,                     ioccCAB2_LS_24V_Schaltschrank_Nicht_OK);
WatchIo(NOT in_bCAB2_LS_24V_Boxen_OK,                             ioccCAB2_LS_24V_Boxen_Nicht_OK);
WatchIo(NOT in_bCAB2_LS_400V_OK,                                  ioccCAB2_LS_400V_Nicht_OK_);
WatchIo(NOT in_bCAB2_LS_Netzfilter_400V_OK,                       ioccCAB2_LS_Netzfilter_400V_Nicht_OK);
WatchIo(NOT in_bCAB2_Sicherheitsrelais_201_Kippen_OK,             ioccCAB2_Sicherheitsrelais_201_Kippen_Nicht_OK);
WatchIo(NOT in_bCAB2_LS_230V_OK,                                  ioccCAB2_LS_230V_Nicht_OK);

WatchIo(NOT bgInbetriebnahmeBit AND NOT toflDruckluft101_OK.Q,  ioccDruckluft1);
WatchIo(NOT bgInbetriebnahmeBit AND NOT toflDruckluft102_OK.Q,  ioccDruckluft2);
WatchIo(NOT bgInbetriebnahmeBit AND NOT toflDruckluftFW_OK.Q,   ioccDruckluft3);
END_PROGRAM