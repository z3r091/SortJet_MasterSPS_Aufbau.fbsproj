(* METADATA
{
  "v3Meta": {
    "objectGuid": "1c89a038-43c8-45ac-ae17-8c8fe5411e58"
  }
}
*)
ACTION BETRIEBSART_Restweg_X_Flankenerkennung
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// RESTWEG - SUCHFAHRT
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
IF (  asteplSchritt[RESTWEG] < STEP_500_E
     AND asteplSchritt[RESTWEG] > STEP_399_E )
THEN

  IF wpRestwegMode.4 THEN // Steigende Flanke !!!

    IF ( wpRestwegMode.2 AND bRising[eSensoren.Sensor_1] )
       OR ( wpRestwegMode.3 AND bRising[eSensoren.Sensor_2] )
       OR ( wpRestwegMode.5 AND bRising[eSensoren.Sensor_3] )
       OR ( wpRestwegMode.6 AND bRising[eSensoren.Sensor_4] )
       OR ( wpRestwegMode.7 AND bRising[eSensoren.Sensor_5] )
       OR ( wpRestwegMode.8 AND bRising[eSensoren.Sensor_6] )
       OR ( wpRestwegMode.9 AND bRising[eSensoren.Sensor_7] )
       OR ( wpRestwegMode.10 AND bRising[eSensoren.Sensor_8] )
       OR ( wpRestwegMode.11 AND bRising[eSensoren.Sensor_9] )
    THEN
      lrlRestwegMessungMesstasterGefunden := lrlRestwegMesstasterGefunden := l_mc_ReadActualPosition.Position;
      blHelfer_RestwegMesung_Objekt_Gefunden := TRUE;
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RESTWEG] := STEP_500_E;
    END_IF

  ELSE // Fallende Flanke

    IF ( wpRestwegMode.2 AND bFalling[eSensoren.Sensor_1] )
       OR ( wpRestwegMode.3 AND bFalling[eSensoren.Sensor_2] )
       OR ( wpRestwegMode.5 AND bFalling[eSensoren.Sensor_3] )
       OR ( wpRestwegMode.6 AND bFalling[eSensoren.Sensor_4] )
       OR ( wpRestwegMode.7 AND bFalling[eSensoren.Sensor_5] )
       OR ( wpRestwegMode.8 AND bFalling[eSensoren.Sensor_6] )
       OR ( wpRestwegMode.9 AND bFalling[eSensoren.Sensor_7] )
       OR ( wpRestwegMode.10 AND bFalling[eSensoren.Sensor_8] )
       OR ( wpRestwegMode.11 AND bFalling[eSensoren.Sensor_9] )
    THEN
      lrlRestwegMessungMesstasterGefunden := lrlRestwegMesstasterGefunden := l_mc_ReadActualPosition.Position;
      blHelfer_RestwegMesung_Objekt_Gefunden := TRUE;
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RESTWEG] := STEP_500_E;
    END_IF

  END_IF

END_IF

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// AUSWERTUNG MESSUNG
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

IF ( asteplSchritt[RESTWEG] >= STEP_500_E ) THEN

  // (neues) Objekt wurde gefunden
  IF blHelfer_RestwegMesung_Objekt_Gefunden THEN

    // Restweg ursprünglich auf steigende Flanke - jetzt auf fallende Flanke warten
    IF wpRestwegMode.4 THEN // Steigende Flanke !!!

      IF ( wpRestwegMode.2 AND bFalling[eSensoren.Sensor_1] )
         OR ( wpRestwegMode.3 AND bFalling[eSensoren.Sensor_2] )
         OR ( wpRestwegMode.5 AND bFalling[eSensoren.Sensor_3] )
         OR ( wpRestwegMode.6 AND bFalling[eSensoren.Sensor_4] )
         OR ( wpRestwegMode.7 AND bFalling[eSensoren.Sensor_5] )
         OR ( wpRestwegMode.8 AND bFalling[eSensoren.Sensor_6] )
         OR ( wpRestwegMode.9 AND bFalling[eSensoren.Sensor_7] )
         OR ( wpRestwegMode.10 AND bFalling[eSensoren.Sensor_8] )
         OR ( wpRestwegMode.11 AND bFalling[eSensoren.Sensor_9] )
      THEN
        lrlMessErgebnis := ABS(l_mc_ReadActualPosition.Position - lrlRestwegMessungMesstasterGefunden);
        rpMessErgebnis := TO_REAL(lrlMessErgebnis);
        bpMessungOk := TRUE;
        blHelfer_RestwegMesung_Objekt_Gefunden := FALSE;
      END_IF

    // Restweg ursprünglich auf fallende Flanke - jetzt auf steigende Flanke warten
    ELSE // Fallende Flanke

      IF ( wpRestwegMode.2 AND bRising[eSensoren.Sensor_1] )
         OR ( wpRestwegMode.3 AND bRising[eSensoren.Sensor_2] )
         OR ( wpRestwegMode.5 AND bRising[eSensoren.Sensor_3] )
         OR ( wpRestwegMode.6 AND bRising[eSensoren.Sensor_4] )
         OR ( wpRestwegMode.7 AND bRising[eSensoren.Sensor_5] )
         OR ( wpRestwegMode.8 AND bRising[eSensoren.Sensor_6] )
         OR ( wpRestwegMode.9 AND bRising[eSensoren.Sensor_7] )
         OR ( wpRestwegMode.10 AND bRising[eSensoren.Sensor_8] )
         OR ( wpRestwegMode.11 AND bRising[eSensoren.Sensor_9] )
      THEN
        lrlMessErgebnis := ABS(l_mc_ReadActualPosition.Position - lrlRestwegMessungMesstasterGefunden);
        rpMessErgebnis := TO_REAL(lrlMessErgebnis);
        bpMessungOk := TRUE;
        blHelfer_RestwegMesung_Objekt_Gefunden := FALSE;
      END_IF

    END_IF

  // Objekt noch nicht gefunden
  ELSE

    IF wpRestwegMode.4 THEN // Steigende Flanke !!!

      IF ( wpRestwegMode.2 AND bRising[eSensoren.Sensor_1] )
         OR ( wpRestwegMode.3 AND bRising[eSensoren.Sensor_2] )
         OR ( wpRestwegMode.5 AND bRising[eSensoren.Sensor_3] )
         OR ( wpRestwegMode.6 AND bRising[eSensoren.Sensor_4] )
         OR ( wpRestwegMode.7 AND bRising[eSensoren.Sensor_5] )
         OR ( wpRestwegMode.8 AND bRising[eSensoren.Sensor_6] )
         OR ( wpRestwegMode.9 AND bRising[eSensoren.Sensor_7] )
         OR ( wpRestwegMode.10 AND bRising[eSensoren.Sensor_8] )
         OR ( wpRestwegMode.11 AND bRising[eSensoren.Sensor_9] )
      THEN
        lrlMessErgebnis := rpMessErgebnis := 0;
        bpMessungOk := FALSE;
        blHelfer_RestwegMesung_Objekt_Gefunden := TRUE;
        lrlRestwegMessungMesstasterGefunden := l_mc_ReadActualPosition.Position;
      END_IF

    ELSE // Fallende Flanke

      IF ( wpRestwegMode.2 AND bFalling[eSensoren.Sensor_1] )
         OR ( wpRestwegMode.3 AND bFalling[eSensoren.Sensor_2] )
         OR ( wpRestwegMode.5 AND bFalling[eSensoren.Sensor_3] )
         OR ( wpRestwegMode.6 AND bFalling[eSensoren.Sensor_4] )
         OR ( wpRestwegMode.7 AND bFalling[eSensoren.Sensor_5] )
         OR ( wpRestwegMode.8 AND bFalling[eSensoren.Sensor_6] )
         OR ( wpRestwegMode.9 AND bFalling[eSensoren.Sensor_7] )
         OR ( wpRestwegMode.10 AND bFalling[eSensoren.Sensor_8] )
         OR ( wpRestwegMode.11 AND bFalling[eSensoren.Sensor_9] )
      THEN
        lrlMessErgebnis := rpMessErgebnis := 0;
        bpMessungOk := FALSE;
        blHelfer_RestwegMesung_Objekt_Gefunden := TRUE;
        lrlRestwegMessungMesstasterGefunden := l_mc_ReadActualPosition.Position;
      END_IF

    END_IF

  END_IF

END_IF
END_ACTION