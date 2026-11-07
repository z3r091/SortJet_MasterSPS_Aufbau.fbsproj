(* METADATA
{
	"v3Meta": {
		"objectGuid": "2a926ca9-66ff-460d-90cd-a4c06345d8ed"
	}
}
*)
ACTION Vorsteuerung
FOR wlIndexAutomatikkreis := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  // Systemcheck aktiv, Zyklen aufteilen
  IF abpCheck[wlIndexAutomatikkreis] THEN

    // Systemcheck starten    
    IF NOT ablCheck[wlIndexAutomatikkreis, wlAktiverZyklus] THEN
      ablCheck[wlIndexAutomatikkreis, wlAktiverZyklus] := TRUE;
    END_IF
    // Systemcheck Fehler
    IF ablCheck[wlIndexAutomatikkreis, wlAktiverZyklus] AND abpFehler[wlIndexAutomatikkreis] THEN
      wSps2MmiCheckArea := wlIndexAutomatikkreis;
      wSps2MmiCheckSuccessful := 0;
      MsgToMmi(auftragsnr_w := SB0_SPS_SYSTEMCHECKFINISHED );
      ablCheck[wlIndexAutomatikkreis, wlAktiverZyklus] := FALSE;
      abpCheck[wlIndexAutomatikkreis] := FALSE;
    END_IF
    // Systemcheck abgeschlossen
    IF ablCheck[wlIndexAutomatikkreis, wlAktiverZyklus] AND NOT abpFehler[wlIndexAutomatikkreis] AND ablCheckDone[wlIndexAutomatikkreis, wlAktiverZyklus] THEN
      IF wlAktiverZyklus >= wgAnzahlSystemcheckZyklen THEN
        wSps2MmiCheckArea := wlIndexAutomatikkreis;
        wSps2MmiCheckSuccessful := 1;
        MsgToMmi(auftragsnr_w := SB0_SPS_SYSTEMCHECKFINISHED );
        ablCheck[wlIndexAutomatikkreis, wlAktiverZyklus] := FALSE;
        abpCheck[wlIndexAutomatikkreis] := FALSE;
      ELSE
        // Nächsten Zyklus starten
        ablCheck[wlIndexAutomatikkreis, wlAktiverZyklus] := FALSE;
        wlAktiverZyklus := wlAktiverZyklus + 1;
      END_IF
    END_IF
    
  // Systemcheck nicht aktiv, alles resetten
  ELSE
    wlAktiverZyklus := 1;
    FOR wlIndexSystemcheckZyklus := 1 TO wgAnzahlSystemcheckZyklen DO
      ablCheck[wlIndexAutomatikkreis, wlIndexSystemcheckZyklus] := FALSE;
    END_FOR
  END_IF

END_FOR
END_ACTION