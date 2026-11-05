(* METADATA
{
  "v3Meta": {
    "objectGuid": "5978a36a-9375-4d46-b7b2-10dc4e26b7df"
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
Geblaese.bpHandEin          := blBetriebsartHand AND ( dwlHandfunktionen.0 OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] );
Geblaese.bpSperre           := BasisStationsParameter.bReset;

// Nach dem Systemcheck laeuft das Geblaese bis zum Ende des Energiesparmodus
IF ( blNachSystemcheckMerker AND NOT Geblaese.bpStart ) THEN
  blNachSystemcheckMerker := FALSE;
END_IF

blGeblaeseAktiv := Geblaese.bpDone;
END_ACTION