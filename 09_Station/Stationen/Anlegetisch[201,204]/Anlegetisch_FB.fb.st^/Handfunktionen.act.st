(* METADATA
{
  "v3Meta": {
    "objectGuid": "cb3e3db0-85d3-41f2-b24d-496b71bb3d99"
  }
}
*)
ACTION Handfunktionen
(***************************************************************************************************)
(* AKTION: HANDFUNKTIONEN *)
(***************************************************************************************************)
IF( blBetriebsartHand )THEN

  (* Handfunktionen
     - Riemen vor
     - Riemen zurück
     - Anschlaege auf/ab
     - Hubpalette heben / senken
     - Geblaese
  *)

  (* Handfunktion:
     - Handplus
  *)
  IF (      ( dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] OR in_bKnebelRiemenVor )
       AND NOT ( dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
       AND ( Hubrahmen.epStatusZylinder = eZylinderAusgefahren ) )
  THEN
    Glastransport.bpHandfahrenPlus := TRUE;

  (* Handfunktion:
     - Handminus
  *)
  ELSIF (   ( dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] OR in_bKnebelRiemenZurueck )
          AND NOT ( dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
          AND ( Hubrahmen.epStatusZylinder = eZylinderAusgefahren ) )
  THEN
    Glastransport.bpHandfahrenMinus := TRUE;

  (* Handfunktion:
     - Handminus / Handplus zuruecksetzen
  *)
  ELSE
    Glastransport.bpHandfahrenPlus := FALSE;
    Glastransport.bpHandfahrenMinus:= FALSE;

  END_IF

  (* Hinweis:
     - Anschlaege heben / senken
       => Impuls Ventil
  *)
  IF NOT blMerkerAnschlagTasterFahren THEN
    Anschlag.bpStartAusfahren := (        ( dwlHandfunktionen.3 OR bgVISUAnschlaegeAuf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                                   AND NOT ( dwlHandfunktionen.4 OR bgVISUAnschlaegeAb[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])  );
    
    Anschlag.bpStartEinfahren := (        ( dwlHandfunktionen.4 OR bgVISUAnschlaegeAb[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                                   AND NOT ( dwlHandfunktionen.3 OR bgVISUAnschlaegeAuf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])  );
  END_IF

  (* Hinweis:
     - Hubrahmen heben / senken
       => Federrueckstell- Ventil
     - Trigger zum senken der Hubrahmen 1 und 2 wenn diese mittels Handfunktionen verfahren wurden
  *)
  ftlHubrahmenAbsenken( CLK := in_bKnebelRiemenZurueck OR in_bKnebelRiemenVor );

  (* Handfunktion:
     - Hoehenkontrolle 
       => Handplus / Handminus
       => Referenz
  *)

  (* Neue Version ab dem 25.05.2022 mit neuen angelegten Visu globalen Variablen: EBENE 1 und EBENE 2*)

  (**********************  EBENE 1    ******************************************************)
  (* Korrektur 18.10.2026:
     - Klammerung: Die Verriegelungen (AND NOT ...) galten wegen der Operator-Rangfolge (AND vor OR)
       nur fuer das jeweils letzte ODER-Glied. Jetzt gelten sie fuer alle Heben- bzw. Senken-Befehle.
     - Senken: Verriegelung auf Riemen vor (Bit 1) statt Anschlag auf (Bit 3), Knebel "Riemen vor" ergaenzt
       -> symmetrisch zu den Heben-Befehlen
  *)
  Hubrahmen.bpStartAusfahren := (    dwlHandfunktionen.5
                                  OR dwlHandfunktionen.1
                                  OR dwlHandfunktionen.2
                                  OR in_bKnebelRiemenZurueck
                                  OR in_bKnebelRiemenVor
                                  OR bgVISUHubrahmenAuf_Ebene1[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                  OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]
                                  OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] )
                                AND NOT ( bgVISUHubrahmenAb_Ebene1[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] OR dwlHandfunktionen.6 )
                                AND NOT ( Hubrahmen.epStatusZylinder = eZylinderAusgefahren );

  Hubrahmen.bpStartEinfahren := (    dwlHandfunktionen.6
                                  OR bgVISUHubrahmenAb_Ebene1[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                  OR ftlHubrahmenAbsenken.Q )
                                AND NOT (  dwlHandfunktionen.5
                                          OR dwlHandfunktionen.1
                                          OR dwlHandfunktionen.2
                                          OR in_bKnebelRiemenZurueck
                                          OR in_bKnebelRiemenVor
                                          OR bgVISUHubrahmenAuf_Ebene1[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                          OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]
                                          OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]
                                          OR ( Hubrahmen.epStatusZylinder = eZylinderEingefahren ) );

  (*Hoehenkontrolle*)
  Messachse.bpHandplus := ( (  dwlHandfunktionen.7
                              OR bgVISUHoehenkontrolleVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                            AND NOT(  dwlHandfunktionen.8
                                     OR dwlHandfunktionen.9
                                     OR bgVISUHoehenkontrolleZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                     OR bgVISUHoehenkontrolleReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));


  Messachse.bpHandminus := ( ( dwlHandfunktionen.8
                               OR bgVISUHoehenkontrolleZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                             AND NOT(  dwlHandfunktionen.7
                                      OR dwlHandfunktionen.9
                                      OR bgVISUHoehenkontrolleVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                      OR bgVISUHoehenkontrolleReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));


  Messachse.bpReferenz  := ( ( dwlHandfunktionen.9
                               OR bgVISUHoehenkontrolleReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                             AND NOT(  dwlHandfunktionen.7
                                      OR dwlHandfunktionen.8
                                      OR bgVISUHoehenkontrolleZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                      OR bgVISUHoehenkontrolleVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

END_IF

HandfunktionenStatus();
END_ACTION