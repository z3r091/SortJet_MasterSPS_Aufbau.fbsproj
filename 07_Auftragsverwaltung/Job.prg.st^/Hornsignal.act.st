(* METADATA
{
  "v3Meta": {
    "objectGuid": "71af4b94-9d1f-41d2-9206-b6f46e84ab17"
  }
}
*)
ACTION Hornsignal
(***************************************************************************************************)
(* HORNSIGNAL (AUSNAHMESITUATION) *)
(***************************************************************************************************)
(* Hinweis:
   - Akustisches Signal wenn ein Fehler in der Einlauf- Strecke anliegt
*)
     
FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  
  rtlFehlerAutomatikkreis[wlIndex]( CLK := Stop_Baustein.abpBetriebsstop[wlIndex] );

  IF (  rtlFehlerAutomatikkreis[wlIndex].Q ) THEN
    FOR wlSubIndex := 1 TO cANZAHL_HUPEN DO
      Horn_AK[wlIndex,wlSubIndex].wpStatusArt      := 1;
      Horn_AK[wlIndex,wlSubIndex].tpHornZeit       := T#5S;
      Horn_AK[wlIndex,wlSubIndex].bpHornAktivieren := TRUE;
    END_FOR
    
  END_IF
  
END_FOR
END_ACTION