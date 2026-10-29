(* METADATA
{
	"v3Meta": {
		"objectGuid": "a308ba42-2e7f-4cae-9e94-a40831a46027"
	}
}
*)
ACTION Status_ISO_Linie
(***************************************************************************************************)
(* AKTION: STATUS DER ISO-LINIE *)
(***************************************************************************************************)
(* Hinweis:
   - Anzeige ob ISO Linie in Automatik ist
*)
rtlAutomatik( CLK:= BasisStationsParameter.bAutomatik );
rtlGlasAbruf( CLK:= blBereitZumEintransport );
ftlGlasAbruf( CLK:= blBereitZumEintransport );

(* Hinweis:
   - Initiieren der Schrittkette
*)
IF ( rtlAutomatik.Q OR rtlGlasAbruf.Q OR ftlGlasAbruf.Q ) THEN
  blStartISOLinie:=TRUE;
  steplStartIsolinie := STEP_0_E;
END_IF

IF ( blStartISOLinie ) THEN
 CASE steplStartIsolinie OF
(*START ISO-LINIE ==================*)
   STEP_0_E:
     (*  Anmerkung:
         - Wort 0: Stationsnr
         - Wort 1: 0 = Iso Linie nicht bereit; 1 Iso Bereit
         - Wort 2: 1 = Output-Shuttle-Nr 
         - Wort 3: 0 = nichts , 1 = Auftrag wurde abgebrochen
         - Wort 4: 0 = Senkrechtförderer frei  / 1 = Senkrechtförderer belegt
     *)
     wSps2MmiStationsNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
	  wSPS2MMIStationsStatusWord1.0 := in_bGlasAbruf;
     MsgToMmi( auftragsnr_w := SB0_SPS_STATIONSTATUS );

     steplStartIsolinie:=STEP_50_E;

(*START ISO-LINIE ==================*)
    STEP_50_E:
      blStartISOLinie := FALSE;
      steplStartIsolinie:=STEP_0_E;

(*START ISO-LINIE ==================*)
  END_CASE
END_IF
IF NOT blStartISOLinie THEN
  IF (steplStartIsolinie > STEP_0_E) THEN
    steplStartIsolinie:=STEP_0_E;
  END_IF
END_IF
END_ACTION