(* METADATA
{
	"v3Meta": {
		"objectGuid": "7822e00b-4a52-4924-81fc-ee7f3816fa4f"
	}
}
*)
ACTION A_Geblaese
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
  wSPS2MMIStationsNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
  IF BasisStationsParameter.bStationBelegt[cWAND_1] THEN
    wSPS2MMIStationsStatusWord1 := cSTATUS_STATION_BELEGT;
  ELSE
    wSPS2MMIStationsStatusWord1 := cSTATUS_STATION_FREI;
  END_IF
  MsgToMmi( auftragsnr_w := SB0_SPS_STATIONSTATUS);
END_IF

(* Hinweis:
   - Die Steuerung des Geblaeses liegt im Geblaese-Baustein (Aktion Steuerung), die Station gibt nur die Signale vor
   - Anlegestation: die Flanke des Auftrags startet, danach laeuft die Abschaltzeit
*)
Geblaese.bpAutomatik        := blBetriebsartAutomatik;
Geblaese.bpAktivitaet       := (    BasisStationsParameter.bAnlegen
                                 OR BasisStationsParameter.bEintransport[cWAND_1]
                                 OR BasisStationsParameter.bAustransport[cWAND_1]
                                 OR BasisStationsParameter.bGlaslaengenmessung
                                 OR BasisStationsParameter.bGlashoehenmessung
                                 OR BasisStationsParameter.bCheck
                                 OR Anlegen.bpGeblaeseAnforderung );
Geblaese.bpAktivitaetFlanke := BasisStationsParameter.stMKs.stStationsOptionen.stAnlegetisch.bIstAnlegestation;
Geblaese.bpTaster           := in_bTasterGeblaeseEin;
Geblaese.bpHandEin          := ( BasisStationsParameter.dwHandfunktionen.0 OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] );
Geblaese.bpSperre           := BasisStationsParameter.bReset;

(* Hinweis:
   - Drosselklappe: oeffnet, sobald das Geblaese laeuft, und schliesst, wenn es steht (die Aktionen fordern sie zusaetzlich an)
*)
rtlGeblaeseLaeuft( CLK := Geblaese.bpDone );
ftlGeblaeseLaeuft( CLK := Geblaese.bpDone );

IF ( NOT blBetriebsartAutomatik ) THEN
  out_bDrosselklappeOeffnen := Geblaese.bpDone;
ELSIF ( rtlGeblaeseLaeuft.Q ) THEN
  out_bDrosselklappeOeffnen := TRUE;
ELSIF ( ftlGeblaeseLaeuft.Q ) THEN
  out_bDrosselklappeOeffnen := FALSE;
END_IF

(* Hinweis:
   - Geblaese-Baustein: Schuetz, Motorschutz, Wiederanlaufsperre, Hochlauf und Drosselklappe
*)
Geblaese( stStationsNummern          := BasisStationsParameter.stMKs.stStationsNummern,
          bpFreigabe                 := BasisStationsParameter.bFreigabe,
          bpIOsBoschDrive            := TRUE,
          bpMotorschutzschalter_OK   := in_bMotorschutzGeblaese_Ok,
          bpDrosselklappeAnforderung := out_bDrosselklappeOeffnen );

out_bGeblaeseEin := Geblaese.bpStarteGeblaese;
END_ACTION