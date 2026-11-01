(* METADATA
{
  "v3Meta": {
    "objectGuid": "1fc5ffc2-022f-40cb-89a8-869cde770942"
  }
}
*)
ACTION Visu
bgVISUWatchIOAktiv := GetBitStatus(wgVISUWatchIONr);
rtlChangeWatchIOStatus( CLK := bgVISUSetWatchIO );
IF rtlChangeWatchIOStatus.Q THEN
  WatchIo( NOT bgVISUWatchIOAktiv, wgVISUWatchIONr );
END_IF

// Station 1
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  IF aStation1Wand[wlIndex] THEN
    bgVISUGlastransportVor[iGewaehlteStation1, wlIndex]     := bgVisu2StationenVor;
    bgVISUGlastransportZurueck[iGewaehlteStation1, wlIndex] := bgVisu2StationenZurueck;
  END_IF
END_FOR

// Station 2 – je nach Drehrichtung
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  IF aStation2Wand[wlIndex] THEN
        
    IF NOT bgVisu2StationenDrehrichtungWechsel THEN
      // normale Richtung
      bgVISUGlastransportVor[iGewaehlteStation2, wlIndex]     := bgVisu2StationenVor;
      bgVISUGlastransportZurueck[iGewaehlteStation2, wlIndex] := bgVisu2StationenZurueck;

    ELSE
      // Richtung vertauscht
      bgVISUGlastransportVor[iGewaehlteStation2, wlIndex]     := bgVisu2StationenZurueck;
      bgVISUGlastransportZurueck[iGewaehlteStation2, wlIndex] := bgVisu2StationenVor;
    END_IF

  END_IF
END_FOR

IF bgBerechnen THEN
  biDurchmesserSoll := ((biDurchmesserIst/biWegSoll )*biWegIst);
END_IF
END_ACTION