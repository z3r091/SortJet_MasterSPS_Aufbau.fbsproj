(* METADATA
{
	"v3Meta": {
		"objectGuid": "c29c4d6f-14de-4fcd-9304-9129c3305729"
	}
}
*)
ACTION Ampelsignal
(***************************************************************************************************)
(* AKTION: AMPEL ZUWEISUNGEN [BETRIEBSZUSTAND] *)
(***************************************************************************************************)

FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

   FOR wlSubIndex := 1 TO cANZAHL_AMPELN DO
      Ampel_AK[wlIndex,wlSubIndex]( bpAutomatikAktiv        := ( M_Automatik_Aktiv[wlIndex] OR Visu_Start_Auto ),
                                    bpSystemcheckAktiv      := Systemcheck.abpCheck[wlIndex],
                                    bpBetriebsstoppAktiv    := Stop_Baustein.abpBetriebsstop[wlIndex],
                                    bpInternerBetriebsstopp := FALSE );
   END_FOR
                    
   FOR wlSubIndex := 1 TO cANZAHL_HUPEN DO
      Horn_AK[wlIndex,wlSubIndex]( bpAktiv := bgHornAktivieren );
   END_FOR
  
END_FOR
END_ACTION