(* METADATA
{
  "v3Meta": {
    "objectGuid": "fa5f8a33-e206-4f1c-8f52-9ec08cda9b33"
  }
}
*)
ACTION Auftraege_Shuttle_Generieren
(***************************************************************************************************)
(* AKTION: AUFTRAEGE FUER SHUTTLE GENERIEREN *)
(***************************************************************************************************)


(* ---------------------------------------------------------------------------------------
//  ABSETZEN DES AUFTRAGS ZUM POSITIONIEREN [QUERFAHRT]
//         
//  Hinweis:
// - Absetzen des Auftrags
// ---------------------------------------------------------------------------------------*)
IF ( bgShuttleVerfahren ) THEN
  bgShuttleVerfahren := FALSE;

  (* SHUTTLE *)
  IF bgShuttleAuswahl_101 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_101;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_102 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_102;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_103 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_103;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_104 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_104;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_105 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_105;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_106 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_106;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  (* TRANSFERSHUTTLE *)
  ELSIF bgShuttleAuswahl_151 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_151;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_152 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_152;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_153 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_153;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_154 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_154;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_155 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_155;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_156 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_156;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_157 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_157;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSIF bgShuttleAuswahl_158 THEN
    wlInbetriebnahmeShuttlenummer := cSHUTTLE_158;
    bgInbetriebnahmeShuttelverfahrAuftrag := TRUE;

  ELSE
    bgInbetriebnahmeShuttelverfahrAuftrag := FALSE;

  END_IF

END_IF

(* ---------------------------------------------------------------------------------------
//  ABSETZEN DES AUFTRAGS 
//         
//  Hinweis:
// - Absetzen des Auftrags
// ---------------------------------------------------------------------------------------*)
IF ( bgButtonShuttleAuftragSetzen ) THEN

  bgButtonShuttleAuftragSetzen := FALSE;

  (* SHUTTLE *)
  IF ( bgShuttleAuswahl_101 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_101;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  ELSIF ( bgShuttleAuswahl_102 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_102;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  ELSIF ( bgShuttleAuswahl_103 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_103;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  ELSIF ( bgShuttleAuswahl_104 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_104;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  ELSIF ( bgShuttleAuswahl_105 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_105;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  ELSIF ( bgShuttleAuswahl_106 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_106;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  (* TRANSFERSHUTTLE *)
  ELSIF ( bgShuttleAuswahl_151 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_151;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  ELSIF ( bgShuttleAuswahl_152 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_152;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF
      
  ELSIF ( bgShuttleAuswahl_153 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_153;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  ELSIF ( bgShuttleAuswahl_154 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_154;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF
      
  ELSIF ( bgShuttleAuswahl_155 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_155;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  ELSIF ( bgShuttleAuswahl_156 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_156;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  ELSIF ( bgShuttleAuswahl_157 ) THEN

    IF (( bgInbetriebnahmeShuttleEintransportAuftrag AND bgInbetriebnahmeShuttleAustransportAuftrag  )
         OR NOT ( bgInbetriebnahmeShuttleEintransportAuftrag OR bgInbetriebnahmeShuttleAustransportAuftrag ))
    THEN
      bgInbetriebnahmeShuttleEintransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleAustransportAuftrag   := FALSE;
      bgInbetriebnahmeShuttleDurchtransportAuftrag := FALSE;

    ELSE
      wlInbetriebnahmeShuttlenummer := cSHUTTLE_157;
      bgInbetriebnahmeShuttelAuftrag := TRUE;

    END_IF

  END_IF

END_IF
END_ACTION