(* METADATA
{
	"v3Meta": {
		"objectGuid": "a1883415-9f03-4c87-8f27-9f4d98a23649"
	}
}
*)
ACTION PruefeFirmwareReferenzBit
// Nach fehlgeschlagenem Lesen erst nach Wartezeit erneut versuchen
tonlS277Wiederholen( IN := blS277LesenFehlgeschlagen, PT := cTIME_S277_WIEDERHOLEN );

// Start Read anstoßen (einmalig bzw. erneut nach Abbruch)
IF NOT blCoeS277ReadGestartet AND ( NOT blS277LesenFehlgeschlagen OR tonlS277Wiederholen.Q ) THEN
  blCoeS277ReadExecute := TRUE;
  blCoeS277ReadGestartet := TRUE;
  blS277LesenFehlgeschlagen := FALSE;
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

// Wenn Read fertig ist, Ergebnis prüfen; ein abgebrochenes Lesen liefert keinen gültigen Wert
IF blCoeS277ReadGestartet AND l_fb_CoeS277Lesen.o_b_Done THEN

  blCoeS277ReadGestartet := FALSE;

  IF l_fb_CoeS277Lesen.o_b_Aborted THEN
    blS277LesenFehlgeschlagen := TRUE;
  ELSE
    blS277PruefungNotwendig := FALSE;
  END_IF

  IF NOT blS277PruefungNotwendig AND NOT udiEncoderProperties.11 THEN
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