(* METADATA
{
	"v3Meta": {
		"objectGuid": "6ee3252f-feb6-4406-8c9a-7362fc521e88"
	}
}
*)
ACTION RFID_Schreiben
(* RFID Schreiben *)
IF blRFID_Schreiben THEN
  CASE steplRFID_Schreiben OF

  (* RFID Schreiben *)
  STEP_0_E:

    out_bRFID_Sensor_Start_RW := FALSE;
    wlIndexByte := 1;
    wlIndexZiffer := 0;
    tonlWarteSchritt(IN := FALSE);

    IF BasisStationsParameter.stMKs.stStationsAufbau.bRFID AND bpBoxInHomePosition THEN
      IF blTagPresent THEN
        (* Umstellen auf den Schreib-Modus *)
        blRFID_Sensor_ModusBit_0 := FALSE;
        blRFID_Sensor_ModusBit_1 := TRUE;
        blRFID_Sensor_ModusBit_2 := FALSE;
        blRFID_Sensor_ModusBit_3 := FALSE;
        blRFID_Sensor_ModusBit_4 := FALSE;
        blRFID_Sensor_ModusBit_5 := FALSE;
        blRFID_Sensor_ModusBit_6 := FALSE;
        blRFID_Sensor_ModusBit_7 := FALSE;

        steplRFID_Schreiben := STEP_50_E;
      END_IF
    ELSE
      steplRFID_Schreiben := STEP_1000_E;
    END_IF


  STEP_50_E:
    (* ---------------------------------------------------------------------------------------
       OPTION - DEFAULT FAECHERWAGENSTATION
       Hinweis:
       - Vorbereiten der Daten
       --------------------------------------------------------------------------------------- *)

    FOR wlIndexByte := ERSTES_ZEICHEN TO (ERSTE_ZIFFER_RFID - 1) DO
      SysMemCpy(
        ADR(abylBytesRFID_out[wlIndexByte]),
        ADR(VERGLEICH_RFID_VALID[wlIndexByte - ERSTES_ZEICHEN]),
        1
      );
    END_FOR

    slRFID_Nummer := WORD_TO_STRING(wlRFID_Nummer_Schreiben);

    (* Anzahl fehlender Stellen berechnen *)
    FOR wlIndex_STRING := 1 TO ((ANZAHL_ZIFFERN_RFID) - INT_TO_WORD(LEN(WORD_TO_STRING(wlRFID_Nummer_Schreiben)))) DO
      slRFID_Nummer := CONCAT('0', slRFID_Nummer);
    END_FOR

    wlIndexZiffer := 0;

    FOR wlIndexByte := ERSTE_ZIFFER_RFID TO (ERSTE_ZIFFER_RFID + (INT_TO_WORD(LEN(slRFID_Nummer) - 1))) DO
      SysMemCpy(
        ADR(abylBytesRFID_out[wlIndexByte]),
        ADR(slRFID_Nummer[wlIndexZiffer]),
        1
      );
      wlIndexZiffer := wlIndexZiffer + 1;
    END_FOR

    steplRFID_Schreiben := STEP_100_E;


  (* RFID Schreiben *)
  STEP_100_E:
    (* ---------------------------------------------------------------------------------------
       Hinweis:
       - Werte auf Ausgang schreiben
       --------------------------------------------------------------------------------------- *)

    FOR wlIndexByte := ERSTES_ZEICHEN TO (ERSTE_ZIFFER_RFID + ANZAHL_ZIFFERN_RFID - 1) DO
      ablRFID_out[wlIndexByte,0] := abylBytesRFID_out[wlIndexByte].0;
      ablRFID_out[wlIndexByte,1] := abylBytesRFID_out[wlIndexByte].1;
      ablRFID_out[wlIndexByte,2] := abylBytesRFID_out[wlIndexByte].2;
      ablRFID_out[wlIndexByte,3] := abylBytesRFID_out[wlIndexByte].3;
      ablRFID_out[wlIndexByte,4] := abylBytesRFID_out[wlIndexByte].4;
      ablRFID_out[wlIndexByte,5] := abylBytesRFID_out[wlIndexByte].5;
      ablRFID_out[wlIndexByte,6] := abylBytesRFID_out[wlIndexByte].6;
      ablRFID_out[wlIndexByte,7] := abylBytesRFID_out[wlIndexByte].7;
    END_FOR

    steplRFID_Schreiben := STEP_110_E;


  (* Deaktivieren der Antenne um den Chip neu zu erfassen *)
  STEP_110_E:

    tonlWarteSchritt(IN := TRUE, PT := T#1S);
    out_bDeactivateAntenna := TRUE;

    IF tonlWarteSchritt.Q THEN
      tonlWarteSchritt(IN := FALSE);
      out_bDeactivateAntenna := FALSE;
      steplRFID_Schreiben := STEP_120_E;
    END_IF


  STEP_120_E:

    tonlWarteSchritt(IN := TRUE, PT := T#1S);
    out_bDeactivateAntenna := FALSE;

    IF tonlWarteSchritt.Q THEN
      tonlWarteSchritt(IN := FALSE);
      out_bDeactivateAntenna := FALSE;
      steplRFID_Schreiben := STEP_130_E;
    END_IF


  STEP_130_E:

    IF blTagPresent THEN
      steplRFID_Schreiben := STEP_140_E;
    END_IF


  STEP_140_E:

    blRFID_Sensor_ModusBit_0 := FALSE;
    blRFID_Sensor_ModusBit_1 := TRUE;
    blRFID_Sensor_ModusBit_2 := FALSE;
    blRFID_Sensor_ModusBit_3 := FALSE;
    blRFID_Sensor_ModusBit_4 := FALSE;
    blRFID_Sensor_ModusBit_5 := FALSE;
    blRFID_Sensor_ModusBit_6 := FALSE;
    blRFID_Sensor_ModusBit_7 := FALSE;

    steplRFID_Schreiben := STEP_150_E;


  (* RFID Schreiben *)
  STEP_150_E:
    (* ---------------------------------------------------------------------------------------
       OPTION - DEFAULT FAECHERWAGENSTATION
       Hinweis:
       - Sensor schreiben auslösen und warten bis abgeschlossen
       --------------------------------------------------------------------------------------- *)

    out_bRFID_Sensor_Start_RW := TRUE;

    IF blCMD_END THEN
      out_bRFID_Sensor_Start_RW := FALSE;
      steplRFID_Schreiben := STEP_200_E;

      tonlWarteSchritt(IN := FALSE);

      FOR wlIndexByte := ERSTES_ZEICHEN TO (ERSTE_ZIFFER_RFID + ANZAHL_ZIFFERN_RFID - 1) DO
        ablRFID_out[wlIndexByte,0] := 0;
        ablRFID_out[wlIndexByte,1] := 0;
        ablRFID_out[wlIndexByte,2] := 0;
        ablRFID_out[wlIndexByte,3] := 0;
        ablRFID_out[wlIndexByte,4] := 0;
        ablRFID_out[wlIndexByte,5] := 0;
        ablRFID_out[wlIndexByte,6] := 0;
        ablRFID_out[wlIndexByte,7] := 0;
      END_FOR
    END_IF


  STEP_200_E:

    out_bDeactivateAntenna := FALSE;
    tonlWarteSchritt(IN := FALSE);

    (* Umschalten auf AUTO_READ Modus *)
    out_bRFID_Sensor_Start_RW := FALSE;

    blRFID_Sensor_ModusBit_0 := TRUE;
    blRFID_Sensor_ModusBit_1 := FALSE;
    blRFID_Sensor_ModusBit_2 := FALSE;
    blRFID_Sensor_ModusBit_3 := FALSE;
    blRFID_Sensor_ModusBit_4 := FALSE;
    blRFID_Sensor_ModusBit_5 := FALSE;
    blRFID_Sensor_ModusBit_6 := FALSE;
    blRFID_Sensor_ModusBit_7 := FALSE;

    steplRFID_Schreiben := STEP_300_E;


  (* Deaktivieren der Antenne um den Chip neu zu erfassen *)
  STEP_300_E:

    tonlWarteSchritt(IN := TRUE, PT := T#1S);
    out_bDeactivateAntenna := TRUE;
    out_bRFID_Sensor_Start_RW := FALSE;

    IF tonlWarteSchritt.Q THEN
      tonlWarteSchritt(IN := FALSE);
      out_bDeactivateAntenna := FALSE;
      steplRFID_Schreiben := STEP_400_E;
    END_IF


  STEP_400_E:

    tonlWarteSchritt(IN := TRUE, PT := T#1S);
    out_bDeactivateAntenna := FALSE;

    IF tonlWarteSchritt.Q THEN
      tonlWarteSchritt(IN := FALSE);
      out_bDeactivateAntenna := FALSE;

      tonlTimeoutReadRFID(IN := FALSE);

      wlRFID_Nummer := 000;
      slRFID_Validierung := '';
      slRFID_Nummer := '';

      steplRFID_Schreiben := STEP_450_E;
    END_IF


  STEP_450_E:
    (* Auslesen des geschriebenen Wertes *)

    blRFID_Auslesen := TRUE;
    tonlTimeoutReadRFID(IN := TRUE, PT := T#10S);

    IF blRFID_DataValid THEN

      wlRFID_NummerMerker := wlRFID_Nummer;
      blRFID_Auslesen := FALSE;
      steplRFID_Schreiben := STEP_500_E;

    ELSIF tonlTimeoutReadRFID.Q AND BasisStationsParameter.stMKs.stStationsAufbau.bRFID THEN

      steplRFID_Schreiben := STEP_900_E;

    END_IF


  STEP_500_E:

    igRackStationNumber := WORD_TO_INT(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern);
    igRackNumber := WORD_TO_INT(wlRFID_NummerMerker);
    wgWriteSuccess := 1;

    MsgToMmi(auftragsnr_w := SB0_SPS_STATUSRACKSTATION);

    steplRFID_Schreiben := STEP_1000_E;


  STEP_900_E:

    igRackStationNumber := WORD_TO_INT(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern);
    igRackNumber := 0;
    wgWriteSuccess := 2;

    MsgToMmi(auftragsnr_w := SB0_SPS_STATUSRACKSTATION);


  STEP_1000_E:

    blRFID_Schreiben := FALSE;

  END_CASE
END_IF


IF NOT blRFID_Schreiben THEN
  IF steplRFID_Schreiben <> 0 THEN

    tonlTimeoutReadRFID(IN := FALSE);
    blRFID_DataValid := FALSE;

    wlRFID_Nummer_Schreiben := 0;

    steplRFID_Schreiben := STEP_0_E;

  END_IF
END_IF
END_ACTION