(* METADATA
{
  "v3Meta": {
    "objectGuid": "33333473-e459-491c-a043-28f329bb58b7"
  }
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// MELDUNGEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - WatchIO
*)
FOR wlIndexAutomatikkreis := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  WatchIo( (abpCheck[wlIndexAutomatikkreis] ) AND NOT M_Init_Ok, ioccCheckWaitInit);
  // -1 da die ioccKonstante bei AK 1 anfängt (Konstante AK1 = 1 ; somit würde die ioccKonstante + AK einen AK zu weit melden)
  WatchIo( ( abpCheck[wlIndexAutomatikkreis] ) AND NOT checkSafetyCircuitsClosedFromAutomaticCircuit(wlIndexAutomatikkreis), ( ioccCheckWaitSK_AK1 + wlIndexAutomatikkreis - 1) );
END_FOR

WatchIo( blCheckAktiv AND NOT M_Init_Ok, ioccCheckWaitInit);
END_ACTION