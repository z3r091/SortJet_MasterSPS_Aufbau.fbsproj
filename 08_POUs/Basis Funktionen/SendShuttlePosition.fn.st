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
  wlNummer : WORD;
  wlSlot   : WORD;
END_VAR
VAR CONSTANT
  cANZAHL_SLOTS_TELEGRAMM : WORD := 12; // Positionen die SB0_SPS_SORTIERUNGSHUTTLEPOS transportiert
END_VAR

//########################################## Changelog ################################################
//
//  2017-11-26 KV - Erstellt
//     => Function to send the current actual position of shuttle
//
//########################################## Changelog ################################################

(* Hinweis:
   - Die Position steht im MMI-Telegramm an einer festen Stelle (Slot), die Reihenfolge ist fest:
     1. Shuttles, 2. Transfershuttles, 3. Stationen die ein Shuttle sind [bStationIstShuttle]
   - Jede MK belegt einen Slot, auch wenn sie deaktiviert ist
   - Was nicht mehr ins Telegramm passt, wird nicht gesendet
*)
FOR wlSlot := 0 TO cANZAHL_SLOTS_TELEGRAMM - 1 DO
  rSps2MmiShuttlePosition[wlSlot] := 0.0;
END_FOR

wlSlot := 0;

// SHUTTLE
FOR wlNummer := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  IF wlSlot < cANZAHL_SLOTS_TELEGRAMM THEN
    rSps2MmiShuttlePosition[wlSlot] := starrShuttleBasisParameter[wlNummer].rAktuellePositionQuerfahrt;
    wlSlot := wlSlot + 1;
  END_IF
END_FOR

// TRANSFERSHUTTLE
FOR wlNummer := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  IF wlSlot < cANZAHL_SLOTS_TELEGRAMM THEN
    rSps2MmiShuttlePosition[wlSlot] := starrTransferShuttleBasisParameter[wlNummer].rAktuellePositionQuerfahrt;
    wlSlot := wlSlot + 1;
  END_IF
END_FOR

// STATIONEN die ein Shuttle sind
FOR wlNummer := cERSTE_STATION TO cLETZTE_STATION DO
  IF starrStationBasisParameter[wlNummer].stMKs.stSchnittstellendaten.bStationIstShuttle THEN
    IF wlSlot < cANZAHL_SLOTS_TELEGRAMM THEN
      rSps2MmiShuttlePosition[wlSlot] := starrStationBasisParameter[wlNummer].rAktuellePositionQuerfahrt;
      wlSlot := wlSlot + 1;
    END_IF
  END_IF
END_FOR

MsgToMmi(auftragsnr_w := SB0_SPS_SORTIERUNGSHUTTLEPOS);

SendShuttlePosition := TRUE;
END_FUNCTION