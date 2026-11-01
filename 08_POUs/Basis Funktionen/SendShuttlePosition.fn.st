(* METADATA
{
  "v3Meta": {
    "objectGuid": "61256a4f-f80b-4fab-9669-5735e5c0be34"
  }
}
*)
FUNCTION SendShuttlePosition : BOOL
VAR_INPUT
END_VAR
VAR
END_VAR

//########################################## Changelog ################################################
//
//  2017-11-26 KV - Erstellt
//     => Function to send the current actual position of shuttle
//
//########################################## Changelog ################################################

// SHUTTLE
rSps2MmiShuttlePosition[0]  := starrShuttleBasisParameter[cSHUTTLE_101].rAktuellePositionQuerfahrt;
rSps2MmiShuttlePosition[1]  := starrShuttleBasisParameter[cSHUTTLE_102].rAktuellePositionQuerfahrt;

// TRANSFERSHUTTLE
rSps2MmiShuttlePosition[2]  := starrTransferShuttleBasisParameter[cSHUTTLE_151].rAktuellePositionQuerfahrt;
rSps2MmiShuttlePosition[3]  := starrTransferShuttleBasisParameter[cSHUTTLE_152].rAktuellePositionQuerfahrt;

// STATIONEN
; // keine stationen vorhanden die Positionen melden müssen

(* Hinweis:
   - Merken der zuletzt quittierten Position
*)
argZuletztQuittiertePositionShuttle[cSHUTTLE_101]  := starrShuttleBasisParameter[cSHUTTLE_101].rAktuellePositionQuerfahrt;
argZuletztQuittiertePositionShuttle[cSHUTTLE_102]  := starrShuttleBasisParameter[cSHUTTLE_102].rAktuellePositionQuerfahrt;

argZuletztQuittiertePositionShuttle[cSHUTTLE_151]  := starrTransferShuttleBasisParameter[cSHUTTLE_151].rAktuellePositionQuerfahrt;
argZuletztQuittiertePositionShuttle[cSHUTTLE_152]  := starrTransferShuttleBasisParameter[cSHUTTLE_152].rAktuellePositionQuerfahrt;

MsgToMmi(auftragsnr_w := SB0_SPS_SORTIERUNGSHUTTLEPOS);

SendShuttlePosition := TRUE;
END_FUNCTION