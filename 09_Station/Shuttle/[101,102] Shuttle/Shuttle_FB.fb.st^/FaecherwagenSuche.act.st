(* METADATA
{
	"v3Meta": {
		"objectGuid": "ece63cde-c6ef-4e39-82d7-9ffb2b26b3fc"
	}
}
*)
ACTION FaecherwagenSuche
(***************************************************************************************************)
(* AUTOMATISIERTE FÄCHERWAGENSUCHE Mittels Sensor  *)
(***************************************************************************************************)

IF bpStarteFaecherwagensuche THEN

  // Ausnahmebehandlung
  IF ( Querfahrt.bpFehler ) THEN
    Querfahrt.bpVerfahreShuttle  := FALSE;
    BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
    steplFaecherwagensuche := STEP_900_E;
  END_IF

  CASE steplFaecherwagensuche OF

(*FÄCHERWAGENSUCHE ==============================*)
    STEP_0_E:
      // Init
      rpAktuelleFaecherwagenPosition := -100000;
      bpFaecherwagenGefunden := FALSE;
      rlLetztePosition := Querfahrt.rpAktPosition;

      Querfahrt.bpShuttleFaecherwagenSuche := TRUE;

      steplFaecherwagensuche := STEP_5_E;
	  
(*FÄCHERWAGENSUCHE ==============================*)
    STEP_5_E:
      // Shuttle auf 90 Grad stellen
      IF( Kippen.epKippStatus = eKippen_Position_90Grad ) THEN
	      steplFaecherwagensuche := STEP_10_E;
		    Kippen.bpPositionieren := FALSE;
	    ELSE
	      Kippen.epZielPosition := eKippen_Position_90Grad;
		    Kippen.bpPositionieren := TRUE;
	    END_IF
	  
	  
(*FÄCHERWAGENSUCHE ==============================*)
    STEP_10_E:
      // FW mit FaecherwagenSuchSensor suchen 
      rtlRackPositionGefunden( CLK:= in_bFaecherwagenSuchSensor );
      IF rtlRackPositionGefunden.Q THEN

        bpFaecherwagenGefunden := TRUE;
        rpAktuelleFaecherwagenPosition := Querfahrt.rpAktPosition;

        //steplFaecherwagensuche := STEP_20_E;
      END_IF

		  // Wenn die Ist Position sich um 1mm aendert -> MSG an MMI (nur fuer LOG)
		  IF ( NOT IsInRange(Querfahrt.rpAktPosition, rlLetztePosition, 1) ) THEN

        rlLetztePosition := Querfahrt.rpAktPosition;

        (* Hinweis:
           - Nachricht an das HMI
        *)
        wSps2MmiMeasureShuttleNummer   := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        rSPS2MMIFachaufnahmePosition   := rlLetztePosition;
        wSPS2MMIFachaufnahmeAnalogwert := BOOL_TO_WORD(in_bFaecherwagenSuchSensor);
        MsgToMmi( auftragsnr_w := SB0_SPS_FACHAUFNAHMEDATEN );

      END_IF

(*CHERWAGENSUCHE ==============================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*FÄCHERWAGENSUCHE ==============================*)
    STEP_1000_E:
      ;

(*FÄCHERWAGENSUCHE ==============================*)
  END_CASE
ELSE
  IF (steplFaecherwagensuche > STEP_0_E) THEN
    bpFaecherwagenGefunden               := FALSE;
    Querfahrt.bpShuttleFaecherwagenSuche := FALSE;
    steplFaecherwagensuche := STEP_0_E;
  END_IF
END_IF
END_ACTION