(* METADATA
{
	"v3Meta": {
		"objectGuid": "e0f07ebf-dbdd-40bf-b153-485917c57576"
	}
}
*)
ACTION WegErkennung
 (* Hinweis:
   - Aenderung der aktuellen Shuttleposition 
   - Bei einer Positionsänderung um mehr als 100mm, wird dieser Wert in die lokalen und globalen Variablen (RETAIN) übernommen 
     => Der Wert 10000 wurde gewählt um bei einer Referenzpunktfahrt einen großen IstPositionssprung auszugrenzen
*)
IF dipAktuelleAntriebsPosition > diAltePosition THEN
  diPositionsUnterschied := dipAktuelleAntriebsPosition - diAltePosition;
ELSE
  diPositionsUnterschied := diAltePosition - dipAktuelleAntriebsPosition;
END_IF

IF (diPositionsUnterschied > 0 ) AND (diPositionsUnterschied < 100000 ) THEN (* größer 0mm und kleiner 100m (100000mm) ; somit jede Fahrbewegung abspeichern *)
  diAltePosition := dipAktuelleAntriebsPosition;
  adiGefahrenerWeg[cSCHMIERKREIS_1] := ( adiGefahrenerWeg[cSCHMIERKREIS_1] + diPositionsUnterschied );
  adiGefahrenerWeg[cSCHMIERKREIS_2]	:= ( adiGefahrenerWeg[cSCHMIERKREIS_2] + diPositionsUnterschied );
ELSE
  diAltePosition := dipAktuelleAntriebsPosition;
END_IF

FOR wlIndex := cSCHMIERKREIS_1 TO cSCHMIERKREIS_2 DO
  (* Alle 100 Meter die entspr. Retain Variable aktualisieren  *)
  IF stStationsNummern.NummerSPS < cERSTES_TRANSFERSHUTTLE THEN
    IF ( ABS(adiGefahrenerWeg[wlIndex]/1000 - PersistentVars.digGefahrenerWegShuttle[wlIndex, stStationsNummern.NummerSPS] ) > 100 ) THEN
      PersistentVars.digGefahrenerWegShuttle[wlIndex, stStationsNummern.NummerSPS]:= (adiGefahrenerWeg[wlIndex]/1000);
    END_IF
  ELSE
    IF ( ABS(adiGefahrenerWeg[wlIndex]/1000 - PersistentVars.digGefahrenerWegTransferShuttle[wlIndex, stStationsNummern.NummerSPS] ) > 100 ) THEN
      PersistentVars.digGefahrenerWegTransferShuttle[wlIndex, stStationsNummern.NummerSPS]:= (adiGefahrenerWeg[wlIndex]/1000);
    END_IF
  END_IF
  (*Erkennung für die Schmierkreise, dass Zeit zum schmieren ist *)
  IF stStationsNummern.NummerSPS < cERSTES_TRANSFERSHUTTLE THEN
    IF ( adiGefahrenerWeg[wlIndex] >= ppParameterBaustein.adiZuFahrenderWegBisSchmierung[wlIndex] ) THEN
      ablStarteKreis[wlIndex]	 := TRUE;
      PersistentVars.digGefahrenerWegShuttle[wlIndex, stStationsNummern.NummerSPS] := 0;
      adiGefahrenerWeg[wlIndex]:= 0;
    END_IF
  ELSE
    IF ( adiGefahrenerWeg[wlIndex] >= ppParameterBaustein.adiZuFahrenderWegBisSchmierung[wlIndex] ) THEN
      ablStarteKreis[wlIndex]	 := TRUE;
      PersistentVars.digGefahrenerWegTransferShuttle[wlIndex, stStationsNummern.NummerSPS] := 0;
      adiGefahrenerWeg[wlIndex]:= 0;
    END_IF
  END_IF
END_FOR
END_ACTION