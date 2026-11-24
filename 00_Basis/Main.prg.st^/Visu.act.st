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

// Wandauswahl aus der Visu (Anlagen_Funktionen: bgStation1W1/W2, bgStation2W1/W2)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  aStation1Wand[wlIndex] := SEL( wlIndex = cWAND_1, bgStation1W2, bgStation1W1 );
  aStation2Wand[wlIndex] := SEL( wlIndex = cWAND_1, bgStation2W2, bgStation2W1 );
END_FOR

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