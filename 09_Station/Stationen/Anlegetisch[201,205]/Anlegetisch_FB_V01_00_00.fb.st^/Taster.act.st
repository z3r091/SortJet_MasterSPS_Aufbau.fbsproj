(* METADATA
{
	"v3Meta": {
		"objectGuid": "249950ae-6eed-4666-b124-f690ffc1aced"
	}
}
*)
ACTION Taster
//-------------------------------------------------------------------------------------------------
// AKTION: TASTER
//-------------------------------------------------------------------------------------------------

tonlTasterGlasbruch( IN := in_bTasterGlasBruch,
                     PT := ZEITLICHE_VERZOEGERUNG_TASTER_GLASBRUCH );

rtlTasterGlasbruch(CLK := tonlTasterGlasbruch.Q );


(* Hinweis:
   - Nachrichten ans MMI absetzen .
*)
IF (  rtlTasterGlasbruch.Q
     AND BasisStationsParameter.bAnlegen )
THEN
  blGlasBruchMeldungSperren := TRUE;

  wSps2MmiStationsNummer      := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
  wSPS2MMIStationEventStatus := cEVENT_STATUS_GLASBRUCH;
  MsgToMmi(auftragsnr_w       := SBO_SPS_STATIONSEVENT);

END_IF

(* Hinweis:
   - Sicherstellen das der Taster nicht oefter und somit faelschlicherweise gedrueckt wird
*)
rtlGlasBruchSperren( CLK := blGlasBruchMeldungSperren );

toflZeitlicheSperrungGlasbruch( IN:= rtlGlasBruchSperren.Q,
                                PT:=ZEITLICHE_SPERRUNG_TASTER_GLASBRUCH);

blGlasBruchMeldungSperren := FALSE;


//-------------------------------------------------------------------------------------------------
// AKTION: GLAS-ABGENOMMEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Eingangsauswertung des Tasters "GlasAbgenommen"
*)
tonlTasterGlasAbgenommen( IN := in_bTasterGlasAbgenommen,
                          PT := ZEITLICHE_VERZOEGERUNG_TASTER_GLASABGENOMMEN );

rtlTasterGlasAbgenommen(CLK := tonlTasterGlasAbgenommen.Q );


(* Hinweis:
   - Nachrichten ans MMI absetzen .
*)
IF (  rtlTasterGlasAbgenommen.Q ) THEN

  wSps2MmiStationsNummer      := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
  wSPS2MMIStationsStatusWord1 := cEVENT_STATUS_GLASABGENOMMEN;
  MsgToMmi(auftragsnr_w := SB0_SPS_STATIONSTATUS);

END_IF

//-------------------------------------------------------------------------------------------------
// AKTION: Anschläge
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Default: Stationsoption bAnschlagAutomatischAusfahren (wird im ersten Zyklus uebernommen)
   - Jede Betaetigung des Tasters wechselt die Anschlaege (ausgefahren -> einfahren, eingefahren -> ausfahren)
     => Die Wahl gilt auch fuer die folgenden Anlegeauftraege
*)
rtlAnschlaegeAufAb(CLK := in_bTasterAnschlaege);

IF  NOT Anlegen.bpAnlegenInVorbereitung THEN
  IF rtlAnschlaegeAufAb.Q AND NOT blMerkerAnschlagTasterFahren THEN
    IF ( Anschlag.epStatusZylinder = eZylinderAusgefahren ) THEN
      blAnschlagAutomatischFahren := FALSE;
    ELSIF ( Anschlag.epStatusZylinder = eZylinderEingefahren ) THEN
      blAnschlagAutomatischFahren := TRUE;
    ELSE
      blAnschlagAutomatischFahren := NOT blAnschlagAutomatischFahren;
    END_IF
    Anschlag.bpStartAusfahren    := blAnschlagAutomatischFahren;
    Anschlag.bpStartEinfahren    := NOT blAnschlagAutomatischFahren;
    blMerkerAnschlagTasterFahren := TRUE;
  ELSIF ( ( Anschlag.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) AND blMerkerAnschlagTasterFahren ) THEN
    Anschlag.bpStartEinfahren    := FALSE;
    Anschlag.bpStartAusfahren    := FALSE;
    blMerkerAnschlagTasterFahren := FALSE;
    blNeustartAnschlag           := TRUE;
  ELSIF (blMerkerAnschlagTasterFahren AND Anschlag.bpFehler AND blBetriebsartHand) THEN
    Anschlag.bpStartEinfahren    := FALSE;
    Anschlag.bpStartAusfahren    := FALSE;
    blMerkerAnschlagTasterFahren := FALSE;
    Anschlag.bpReset             :=TRUE;
 
  END_IF
END_IF
END_ACTION