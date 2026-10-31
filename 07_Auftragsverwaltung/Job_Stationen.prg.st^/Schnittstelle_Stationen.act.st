(* METADATA
{
  "v3Meta": {
    "objectGuid": "2f0e1e2b-c489-43f6-919f-1d41b03fa1f2"
  }
}
*)
ACTION Schnittstelle_Stationen
(***************************************************************************************************)
(* SCHNITTSTELLE ZWISCHEN DEN STATIONEN *)
(***************************************************************************************************)

//  KOPPLUNGEN

//starrFremdanlageEinlaufStationBasisParameter[501].InGlasTransportNachfolger[cWAND_1] := starrStationBasisParameter[cSTATION_201].OutGlasTransport[cWAND_1];
//starrStationBasisParameter[cSTATION_201].InGlasTransportVorgaenger[cWAND_1] := starrFremdanlageEinlaufStationBasisParameter[501].OutGlasTransport[cWAND_1];

FOR wlIndex := cERSTE_STATION TO cLETZTE_FREMDANLAGE_EINLAUF DO

  // Struktur für die Zielstation der Kopplung finden
  stLokaleKopplungZielStation REF= getBasis(wlIndex);
  
  IF __ISVALIDREF(stLokaleKopplungZielStation) THEN

    // Kopplung Vorgänger
    stLokaleKopplungsStation REF= getBasis(stLokaleKopplungZielStation.stMKs.stSchnittstellendaten.wVorgaengerStation);
  
    IF __ISVALIDREF(stLokaleKopplungsStation) THEN
      FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
        stLokaleKopplungZielStation.InGlasTransportVorgaenger[wlIndexWand] := stLokaleKopplungsStation.OutGlasTransport[cWAND_1];
      END_FOR
    END_IF
  
    // Kopplung Nachfolger
    stLokaleKopplungsStation REF= getBasis(stLokaleKopplungZielStation.stMKs.stSchnittstellendaten.wNachfolgerStation);
  
    IF __ISVALIDREF(stLokaleKopplungsStation) THEN
      FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
        stLokaleKopplungZielStation.InGlasTransportNachfolger[wlIndexWand] := stLokaleKopplungsStation.OutGlasTransport[cWAND_1];
      END_FOR
    END_IF

  END_IF

END_FOR
END_ACTION