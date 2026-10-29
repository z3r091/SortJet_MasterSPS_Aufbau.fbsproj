(* METADATA
{
	"v3Meta": {
		"objectGuid": "2dd67d59-9d65-422a-a9a5-a54784296135"
	}
}
*)
PROGRAM AutomatischeFachaufnahme
VAR_INPUT

 (* BOOLEAN *)
 bpStarteFachaufnahme : BOOL := FALSE;
 bpAktiv              : BOOL := TRUE;

 (* WORD *)
 wpMMINummer  : WORD;

 (* POINTER *)
 ptQuerfahrtShuttle : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_01;

 // REF
 Shuttle : REFERENCE TO Shuttle_FB;

END_VAR

VAR

  (* STEP *)
  steplAufnahme            : STEPS_TE;

  (* WORD *)

  (* REAL *)
  rlLetztePosition         : REAL;
  rlMerkerGeschwindigkeit  : real;


  (* POINTER *)
  ptlAnalogwertChannel1  : REFERENCE TO INT;
  ptlAnalogwertChannel2  : REFERENCE TO INT;

END_VAR

VAR CONSTANT

  (* WORD *)
  wGeschwindigkeitFachaufnahme : WORD := 5;
  wDefaultHandgeschwindigkeit  : WORD := 300;

END_VAR



(***************************************************************************************************)
(* AUTOMATISIERTE FACHAUFNAHME  *)
(***************************************************************************************************)
(*Anmerkung:
   - Shuttle-Koordinationsbaustein zur Fachaufnahme
*)
IF ( bpAktiv ) THEN

  (* Hinweis:
     - Starten der Fachaufnahme
  *)
  Shuttle REF= aShuttle[wpMMINummer];
  IF NOT __ISVALIDREF(Shuttle) THEN
    RETURN;
  ELSE
    ptQuerfahrtShuttle    REF= Shuttle.Querfahrt.Antrieb;
    ptlAnalogwertChannel1 REF= Shuttle.in_iAnalogwertChannel1;
    ptlAnalogwertChannel2 REF= Shuttle.in_iAnalogwertChannel2;
  END_IF

  (* Hinweis:
     - Starten der Fachaufnahme
  *)
  IF ( bpStarteFachaufnahme ) THEN


    IF ( __ISVALIDREF(ptQuerfahrtShuttle) ) THEN

      CASE steplAufnahme OF

        (* ----------------------------------------------------------------------- *)
        STEP_0_E:
          rlMerkerGeschwindigkeit :=  ptQuerfahrtShuttle.ppAntriebsInformationen.rpHandGeschwindigkeit;
          ptQuerfahrtShuttle.ppAntriebsInformationen.rpHandGeschwindigkeit := wGeschwindigkeitFachaufnahme;

          steplAufnahme:= STEP_10_E;

        (* ----------------------------------------------------------------------- *)
        STEP_10_E:
			    IF (  ( ptQuerfahrtShuttle.rpIstPosition <> rlLetztePosition )
            AND ( ptQuerfahrtShuttle.rpIstPosition <> 0 ) )
          THEN

            rlLetztePosition := ptQuerfahrtShuttle.rpIstPosition;

            (* Hinweis:
               - Nachricht an das HMI
            *)
            rSPS2MMIFachaufnahmePosition   := rlLetztePosition;
            wSPS2MMIFachaufnahmeAnalogwert := TO_WORD(ptlAnalogwertChannel1);
            MsgToMmi( SB0_SPS_FACHAUFNAHMEDATEN );
          END_IF

      END_CASE

    ELSE
     ;

    END_IF

  END_IF

  IF ( NOT bpStarteFachaufnahme ) THEN

    IF ( steplAufnahme > STEP_0_E ) THEN
      steplAufnahme := STEP_0_E;
      ptQuerfahrtShuttle.ppAntriebsInformationen.rpHandGeschwindigkeit := SEL( rlMerkerGeschwindigkeit <> 0, wDefaultHandgeschwindigkeit, rlMerkerGeschwindigkeit ) ;
      rlMerkerGeschwindigkeit := 0;
    END_IF

  END_IF

END_IF
END_PROGRAM