(* METADATA
{
  "v3Meta": {
    "objectGuid": "a1883415-9f03-4c87-8f27-9f4d98a23649"
  }
}
*)
ACTION PruefeFirmwareReferenzBit
// Start Read einmalig anstoßen
IF NOT blCoeS277ReadGestartet THEN
  blCoeS277ReadExecute := TRUE;
  blCoeS277ReadGestartet := TRUE;
END_IF

// FB aufrufen
l_fb_CoeS277Lesen
  (
    i_b_Execute   := blCoeS277ReadExecute,
    i_by_EcID     := 1000 + l_ts_MKAxisConfig.uiDeviceAddress,
    i_w_ObjectNum := 16#24A2,
    i_by_SubIndex := 1,
    i_w_DataTyp   := 7,
    i_p_Var       := ADR(udiEncoderProperties),
    i_w_BufSize   := SIZEOF(udiEncoderProperties)
  );

// Execute nur einen Zyklus TRUE
blCoeS277ReadExecute := FALSE;

// Wenn Read fertig ist, Ergebnis prüfen
IF blCoeS277ReadGestartet AND l_fb_CoeS277Lesen.o_b_Done THEN

  blCoeS277ReadGestartet := FALSE;
  blS277PruefungNotwendig := FALSE;

  IF NOT udiEncoderProperties.11 THEN
    awlFehlerinformationen[0] := stStationsNummern.NummerExtern;
    awlFehlerinformationen[1] := ppAntriebsInformationen.wpSchaltplanseite;
    awlFehlerinformationen[2] := ppAntriebsInformationen.wpSchaltplanReihe;
    awlFehlerinformationen[3] := ppAntriebsInformationen.wpSchaltschrank;
    SpsError( eFehler_Antrieb,
              999,
              stStationsNummern.NummerIntern,
              AutomatikkreisBestimmen(stStationsNummern.NummerSPS),
              awlFehlerinformationen );
  END_IF
END_IF
END_ACTION