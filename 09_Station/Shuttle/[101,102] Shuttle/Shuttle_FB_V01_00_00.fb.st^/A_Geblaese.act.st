(* METADATA
{
  "v3Meta": {
    "objectGuid": "807f3243-bd0e-4699-ab72-cd6f3f1341d1"
  }
}
*)
ACTION A_Geblaese
//-------------------------------------------------------------------------------------------------
// AKTION GEBLAESE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Die Steuerung des Geblaeses liegt im Geblaese-Baustein (Aktion Steuerung), die Station gibt nur die Signale vor
*)
rtlAutomatikActiv( CLK := BasisStationsParameter.bAutomatik );

IF ( rtlAutomatikActiv.Q ) THEN
  blNachSystemcheckMerker := FALSE;
END_IF

blDone := TRUE;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Geblaese[wlIndex].bpAutomatik        := ( blBetriebsartAutomatik OR blBetriebartCheck OR blNachSystemcheckMerker );
  Geblaese[wlIndex].bpAktivitaet       := BasisStationsParameter.bAuftragAktiv;
  Geblaese[wlIndex].bpAktivitaetFlanke := FALSE;
  Geblaese[wlIndex].bpHandEin          := blBetriebsartHand AND ( dwlHandfunktionen.0 OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, wlIndex] OR toflGeblaeseHandfahren[wlIndex].Q );
  Geblaese[wlIndex].bpSperre           := BasisStationsParameter.bReset;

  blDone := blDone AND Geblaese[wlIndex].bpDone;
END_FOR

// Nach dem Systemcheck laeuft das Geblaese bis zum Ende des Energiesparmodus
IF ( blNachSystemcheckMerker AND NOT Geblaese[cWAND_1].bpStart ) THEN
  blNachSystemcheckMerker := FALSE;
END_IF

blGeblaeseAktiv := blDone;
END_ACTION