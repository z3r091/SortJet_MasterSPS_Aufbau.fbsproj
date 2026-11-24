(* METADATA
{
	"v3Meta": {
		"objectGuid": "c29c4d6f-14de-4fcd-9304-9129c3305729"
	}
}
*)
ACTION Ampelsignal
//-------------------------------------------------------------------------------------------------
// AKTION: AMPEL ZUWEISUNGEN [BETRIEBSZUSTAND]
//-------------------------------------------------------------------------------------------------

// Ampel blau: Faecherwagen laut MMI bald voll (Dauerlicht) bzw. Bedienereingriff am Faecherwagen erforderlich (blinkend)
//   - an allen Ampeln der Automatikkreise, zu denen die Station laut MK gehoert, ODER ueber alle Faecherwagenstationen
FOR wlAK := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  FOR wlSubIndex := 1 TO cANZAHL_AMPELN DO
    Ampel_AK[wlAK, wlSubIndex].bpSignalExtern                   := FALSE;
    Ampel_AK[wlAK, wlSubIndex].bpHinweisFWEingriffErforderlich := FALSE;
  END_FOR
END_FOR

FOR wlFaecherwagen := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO

  FOR wlIndexAK := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
    wlAK := TO_WORD( starrFaecherwagenBasisParameter[wlFaecherwagen].stMKs.eaAutomatikkreis[wlIndexAK] );

    IF PruefungWertImIntervall( wlAK, cERSTER_AUTOMATIKKREIS, cLETZTER_AUTOMATIKKREIS ) THEN
      FOR wlSubIndex := 1 TO cANZAHL_AMPELN DO
        IF ( aFaecherwagenstation[wlFaecherwagen].bpMMIFWBaldVoll ) THEN
          Ampel_AK[wlAK, wlSubIndex].bpSignalExtern := TRUE;
        END_IF

        IF ( aFaecherwagenstation[wlFaecherwagen].bpHinweisEingriffErforderlich ) THEN
          Ampel_AK[wlAK, wlSubIndex].bpHinweisFWEingriffErforderlich := TRUE;
        END_IF
      END_FOR
    END_IF
  END_FOR

END_FOR

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