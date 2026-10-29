(* METADATA
{
	"v3Meta": {
		"objectGuid": "ae4df5c9-767a-4a7b-9255-9e391537b93e"
	}
}
*)
ACTION _214_Zu_217

FOR i := 0 TO 15 DO

  IF NOT amsAuftraege[i].blAuftragAktiv THEN

    (* Ablauf als große Scheibe mit SETNEXT von 214 auf 216 ohne 215 *)
    IF ( amsAuftraege[i].wlSource = cMMI_DREHSTATION_214 ) AND ( amsAuftraege[i].wlDestination = cMMI_DREHSTATION_217 ) AND amsAuftraege[i].blDrehen THEN

      (* Scheibe steht auf 214 und soll auf 216 *)
      IF ( amsAuftraege[i].ilAktuelleStation = cMMI_DREHSTATION_214 ) AND ( amsAuftraege[i].wlNextStation = cMMI_SENKRECHTFOERDERER_215 ) AND NOT
         Job_Auslaufstrecke.AuftragsSpeicher[216].bpNaechsterAuftrag THEN

        tMmi2SpsInfo.wStationsNr := 216;
        tMmi2SpsInfo.wStationBeschichtungsseite.0 := FALSE;
        tMmi2SpsInfo.rStationAuftragsLaenge := amsAuftraege[i].wlLaenge;
        tMmi2SpsInfo.rStationAuftragsBreite := amsAuftraege[i].wlHoehe;
        tMmi2SpsInfo.wStationAuftragsScheibenanzahl := 1;
        tMmi2SpsInfo.wStationErsteScheibe := 1;
        tMmi2SpsInfo.wStationLetzteScheibe := 1;
        tMmi2SpsInfo.wStationAuftragZielWand := 1;
        tMmi2SpsInfo.wStationAuftragZielEbene := 1;
        tMmi2SpsInfo.wStationAuftragQuellEbene := 1;
        tMmi2SpsInfo.wStationBeladungsStatus := 1;
        tMmi2SpsInfo.wStationsQuelle := 214;
        tMmi2SpsInfo.wStationsZiel := 216;
        tMmi2SpsInfo.wStationAuftragsTyp := 0;
        tMmi2SpsInfo.wStationFWScheibenLuecke := 0;
        tMmi2SpsInfo.rStationAuftragsDicke := GlasBreiteBestimmen(amsAuftraege[i].wlBreite);
        M_SB0_MMI_SETNEXTBATCHFORSTATION := TRUE;

        amsAuftraege[i].blAuftragAktiv := TRUE;
        i := 15;

      END_IF

      (* Scheibe steht auf 216 und soll auf 217 *)
      IF ( amsAuftraege[i].ilAktuelleStation = cMMI_HUBSENKRECHTFOERDERER_216 ) AND ( amsAuftraege[i].wlNextStation = cMMI_DREHSTATION_217 ) AND NOT
         Job_Auslaufstrecke.AuftragsSpeicher[217].bpNaechsterAuftrag THEN

        tMmi2SpsInfo.wStationsNr := 217;
        tMmi2SpsInfo.wStationBeschichtungsseite.0 := FALSE;
        tMmi2SpsInfo.rStationAuftragsLaenge := amsAuftraege[i].wlLaenge;
        tMmi2SpsInfo.rStationAuftragsBreite := amsAuftraege[i].wlHoehe;
        tMmi2SpsInfo.wStationAuftragsScheibenanzahl := 1;
        tMmi2SpsInfo.wStationErsteScheibe := 1;
        tMmi2SpsInfo.wStationLetzteScheibe := 1;
        tMmi2SpsInfo.wStationAuftragZielWand := 1;
        tMmi2SpsInfo.wStationAuftragZielEbene := 1;
        tMmi2SpsInfo.wStationAuftragQuellEbene := 1;
        tMmi2SpsInfo.wStationBeladungsStatus := 1;
        tMmi2SpsInfo.wStationsQuelle := 215;
        tMmi2SpsInfo.wStationsZiel := 217;
        tMmi2SpsInfo.wStationAuftragsTyp := 0;
        tMmi2SpsInfo.wStationFWScheibenLuecke := 0;
        tMmi2SpsInfo.rStationAuftragsDicke := GlasBreiteBestimmen(amsAuftraege[i].wlBreite);
        M_SB0_MMI_SETNEXTBATCHFORSTATION := TRUE;

        amsAuftraege[i].blAuftragAktiv := TRUE;
        i := 15;

      END_IF

    END_IF

    (* Ablauf als normale Scheibe mit SETNEXT von 214 auf 215 und 216 *)
    IF ( amsAuftraege[i].wlSource = cMMI_DREHSTATION_214 ) AND ( amsAuftraege[i].wlDestination = cMMI_DREHSTATION_217 ) AND NOT amsAuftraege[i].blDrehen THEN

      (* Scheibe steht auf 214 und soll auf 215 *)
      IF ( amsAuftraege[i].ilAktuelleStation = cMMI_DREHSTATION_214 ) AND ( amsAuftraege[i].wlNextStation = cMMI_SENKRECHTFOERDERER_215 )AND NOT
         Job_Auslaufstrecke.AuftragsSpeicher[215].bpNaechsterAuftrag THEN

        tMmi2SpsInfo.wStationsNr := 215;
        tMmi2SpsInfo.wStationBeschichtungsseite.0 := FALSE;
        tMmi2SpsInfo.rStationAuftragsLaenge := amsAuftraege[i].wlLaenge;
        tMmi2SpsInfo.rStationAuftragsBreite := amsAuftraege[i].wlHoehe;
        tMmi2SpsInfo.wStationAuftragsScheibenanzahl := 1;
        tMmi2SpsInfo.wStationErsteScheibe := 1;
        tMmi2SpsInfo.wStationLetzteScheibe := 1;
        tMmi2SpsInfo.wStationAuftragZielWand := 1;
        tMmi2SpsInfo.wStationAuftragZielEbene := 1;
        tMmi2SpsInfo.wStationAuftragQuellEbene := 1;
        tMmi2SpsInfo.wStationBeladungsStatus := 1;
        tMmi2SpsInfo.wStationsQuelle := 214;
        tMmi2SpsInfo.wStationsZiel := 215;
        tMmi2SpsInfo.wStationAuftragsTyp := 0;
        tMmi2SpsInfo.wStationFWScheibenLuecke := 0;
        tMmi2SpsInfo.rStationAuftragsDicke := GlasBreiteBestimmen(amsAuftraege[i].wlBreite);
        M_SB0_MMI_SETNEXTBATCHFORSTATION := TRUE;

        amsAuftraege[i].blAuftragAktiv := TRUE;
        i := 15;

      END_IF

      (* Scheibe steht auf 215 und soll auf 216 *)
      IF ( amsAuftraege[i].ilAktuelleStation = cMMI_SENKRECHTFOERDERER_215 ) AND ( amsAuftraege[i].wlNextStation = cMMI_HUBSENKRECHTFOERDERER_216 ) AND NOT
         Job_Auslaufstrecke.AuftragsSpeicher[216].bpNaechsterAuftrag THEN

        tMmi2SpsInfo.wStationsNr := 216;
        tMmi2SpsInfo.wStationBeschichtungsseite.0 := FALSE;
        tMmi2SpsInfo.rStationAuftragsLaenge := amsAuftraege[i].wlLaenge;
        tMmi2SpsInfo.rStationAuftragsBreite := amsAuftraege[i].wlHoehe;
        tMmi2SpsInfo.wStationAuftragsScheibenanzahl := 1;
        tMmi2SpsInfo.wStationErsteScheibe := 1;
        tMmi2SpsInfo.wStationLetzteScheibe := 1;
        tMmi2SpsInfo.wStationAuftragZielWand := 1;
        tMmi2SpsInfo.wStationAuftragZielEbene := 1;
        tMmi2SpsInfo.wStationAuftragQuellEbene := 1;
        tMmi2SpsInfo.wStationBeladungsStatus := 1;
        tMmi2SpsInfo.wStationsQuelle := 215;
        tMmi2SpsInfo.wStationsZiel := 216;
        tMmi2SpsInfo.wStationAuftragsTyp := 0;
        tMmi2SpsInfo.wStationFWScheibenLuecke := 0;
        tMmi2SpsInfo.rStationAuftragsDicke := GlasBreiteBestimmen(amsAuftraege[i].wlBreite);
        M_SB0_MMI_SETNEXTBATCHFORSTATION := TRUE;

        amsAuftraege[i].blAuftragAktiv := TRUE;
        i := 15;

      END_IF

      (* Scheibe steht auf 216 und soll auf 217 *)
      IF ( amsAuftraege[i].ilAktuelleStation = cMMI_HUBSENKRECHTFOERDERER_216 ) AND ( amsAuftraege[i].wlNextStation = cMMI_DREHSTATION_217 ) AND NOT
         Job_Auslaufstrecke.AuftragsSpeicher[217].bpNaechsterAuftrag THEN

        tMmi2SpsInfo.wStationsNr := 217;
        tMmi2SpsInfo.wStationBeschichtungsseite.0 := FALSE;
        tMmi2SpsInfo.rStationAuftragsLaenge := amsAuftraege[i].wlLaenge;
        tMmi2SpsInfo.rStationAuftragsBreite := amsAuftraege[i].wlHoehe;
        tMmi2SpsInfo.wStationAuftragsScheibenanzahl := 1;
        tMmi2SpsInfo.wStationErsteScheibe := 1;
        tMmi2SpsInfo.wStationLetzteScheibe := 1;
        tMmi2SpsInfo.wStationAuftragZielWand := 1;
        tMmi2SpsInfo.wStationAuftragZielEbene := 1;
        tMmi2SpsInfo.wStationAuftragQuellEbene := 1;
        tMmi2SpsInfo.wStationBeladungsStatus := 1;
        tMmi2SpsInfo.wStationsQuelle := 215;
        tMmi2SpsInfo.wStationsZiel := 217;
        tMmi2SpsInfo.wStationAuftragsTyp := 0;
        tMmi2SpsInfo.wStationFWScheibenLuecke := 0;
        tMmi2SpsInfo.rStationAuftragsDicke := GlasBreiteBestimmen(amsAuftraege[i].wlBreite);
        M_SB0_MMI_SETNEXTBATCHFORSTATION := TRUE;

        amsAuftraege[i].blAuftragAktiv := TRUE;
        i := 15;

      END_IF

    END_IF

  END_IF

END_FOR
END_ACTION