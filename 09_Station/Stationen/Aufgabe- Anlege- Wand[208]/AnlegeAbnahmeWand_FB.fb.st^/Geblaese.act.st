(* METADATA
{
  "v3Meta": {
    "objectGuid": "7822e00b-4a52-4924-81fc-ee7f3816fa4f"
  }
}
*)
ACTION Geblaese
//-------------------------------------------------------------------------------------------------
// AKTION GEBLÄSE
//-------------------------------------------------------------------------------------------------


// Möglichkeit, dem MMI mitzuteilen, dass eine im Systemcheck erkannte Scheibe abgenommen wurde,
//   damit neue Scheiben zum abnehmen herausgefahren werden.
//   Sollte im Sys-Check eine Scheibe erkannt werden, wird der Abnahmeprozess nicht neu gestartet
//   und die Station meldet belegt, aber niemals mehr frei - einzige Lösung wäre STOP -> START
//   Um das zu vermeiden, hier 7 Sekunden lang den Taster gedrückt halten, um ein geforced Frei/Belegt zu
//   schicken!
tonlQuittierungGlasAbgenommen( IN := in_bTasterQuittierungGlasAbgenommen OR in_bFussTaster, PT := T#7S );
IF tonlQuittierungGlasAbgenommen.Q THEN
  BasisStationsParameter.bStationBelegt[cWAND_1] := (Glastransport.bpSensorEinlauf OR Glastransport.bpSensorAuslaufVorAb OR Glastransport.bpSensorAuslauf OR Glastransport.bpSensorEinlaufVorAb );
  wSPS2MMIStationsNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
  IF BasisStationsParameter.bStationBelegt[cWAND_1] THEN
    wSPS2MMIStationsStatusWord1 := cSTATUS_STATION_BELEGT;
  ELSE
    wSPS2MMIStationsStatusWord1 := cSTATUS_STATION_FREI;
  END_IF
  MsgToMmi( auftragsnr_w := SB0_SPS_STATIONSTATUS);
END_IF

(* Hinweis:
   - Energiesparmodus: Geblaese bei laengerer Inaktivitaet ausschalten
*)
rtlGeblaese( CLK:=     BasisStationsParameter.bAnlegen
             OR BasisStationsParameter.bEintransport[cWAND_1]
             OR BasisStationsParameter.bAustransport[cWAND_1]
             OR BasisStationsParameter.bGlaslaengenmessung
             OR BasisStationsParameter.bGlashoehenmessung
             OR BasisStationsParameter.bGlaslaengenmessung
             OR BasisStationsParameter.bCheck
             OR ( BasisStationsParameter.bGlaslaengenmessung AND (steplGlaslaengenmessung = STEP_240_E) OR  (steplGlaslaengenmessung = STEP_10_E) OR (steplGlaslaengenmessung = STEP_110_E) )
             OR ( BasisStationsParameter.bAnlegen AND (steplAnlegen = STEP_20_E OR steplAnlegen = STEP_50_E )));

rtlTasterGeblaese(CLK:=    in_bTasterGeblaeseEin
                   OR BasisStationsParameter.dwHandfunktionen.0
                   OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]);

ftlGeblaese(CLK:=(BasisStationsParameter.dwHandfunktionen.0 OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]));


rtlDrosselklappeOeffnen(CLK:= tonlGeblaseLauft.Q );

toflGeblaeseEnergiesparModus(IN := (rtlGeblaese.Q),
                              PT := tgZeitAutoabschaltungEnergiesparModus );

ftEnergiesparmodusGeblaese(CLK:= toflGeblaeseEnergiesparModus.Q);

tofGeblaeseWirdAusGeschaltet(IN:= out_bGeblaeseEin ,PT:=t#500ms);

tonlGeblaseLauft(IN:= out_bGeblaeseEin, PT:=t#500ms);

IF ( blBetriebsartAutomatik ) THEN

  IF ( rtlDrosselklappeOeffnen.Q ) THEN
    out_bDrosselklappeOeffnen := TRUE;
  END_IF

  IF (  ftEnergiesparmodusGeblaese.Q
       OR  BasisStationsParameter.bReset )
  THEN
    out_bGeblaeseEin := FALSE;
    out_bDrosselklappeOeffnen:= FALSE;
    rtlGeblaese(CLK:= FALSE);
    rtlTasterGeblaese(CLK:=FALSE);


  ELSIF (rtlTasterGeblaese.Q
          OR rtlGeblaese.Q )
        AND NOT tofGeblaeseWirdAusGeschaltet.Q
  THEN
    out_bGeblaeseEin := TRUE;

  END_IF

  IF ( rtlTasterGeblaese.Q
       AND tofGeblaeseWirdAusGeschaltet.Q )
  THEN
    out_bGeblaeseEin := FALSE;
    out_bDrosselklappeOeffnen:= FALSE;
  END_IF

(* Hinweis:
   - alles ausser Automatikbetrieb
*)
ELSE
  out_bDrosselklappeOeffnen := tonlGeblaseLauft.Q;

  IF ( rtlGeblaese.Q
       OR ftlGeblaese.Q
       OR rtlTasterGeblaese.Q )
  THEN

    IF ( NOT out_bGeblaeseEin ) THEN
      out_bGeblaeseEin:=TRUE;
    ELSE
      out_bGeblaeseEin:=FALSE;
    END_IF

  END_IF

END_IF
END_ACTION