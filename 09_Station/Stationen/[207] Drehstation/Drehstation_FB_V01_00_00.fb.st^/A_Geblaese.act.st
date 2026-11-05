(* METADATA
{
  "v3Meta": {
    "objectGuid": "cda4a395-9b7d-4fad-8723-3f1586f2af42"
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
rtlAutomatikActiv( CLK := blBetriebsartAutomatik );

IF ( rtlAutomatikActiv.Q ) THEN
  blNachSystemcheckMerker := FALSE;
END_IF

Geblaese.bpAutomatik        := ( blBetriebsartAutomatik OR blBetriebartCheck OR blNachSystemcheckMerker );
Geblaese.bpAktivitaet       := BasisStationsParameter.bAuftragAktiv;
Geblaese.bpAktivitaetFlanke := BasisStationsParameter.stMKs.stStationsOptionen.stAnlegetisch.bIstAnlegestation;
Geblaese.bpHandEin          := (     blBetriebsartHand
                                 AND NOT BasisStationsParameter.bVorabpositionieren
                                 AND ( dwlHandfunktionen.0 OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] OR toflGeblaeseHandfahren.Q ) );
Geblaese.bpSperre           := BasisStationsParameter.bReset;

// Nach dem Systemcheck laeuft das Geblaese bis zum Ende des Energiesparmodus
IF ( blNachSystemcheckMerker AND NOT Geblaese.bpStart ) THEN
  blNachSystemcheckMerker := FALSE;
END_IF

blGeblaeseAktiv := Geblaese.bpDone;
END_ACTION