(* METADATA
{
  "v3Meta": {
    "objectGuid": "a1369c4f-ce6e-4f93-be02-29b3ba397902"
  }
}
*)
METHOD PRIVATE M_AmpelHinweisEingriff
VAR_INPUT
  bpAktiv : BOOL; // TRUE = Bedienereingriff am Faecherwagen erforderlich (Ampel blau blinkend)
END_VAR
VAR
  wlIndexAK    : WORD;
  wlAK         : WORD;
  wlIndexAmpel : WORD;
END_VAR

(* Hinweis:
   - Setzt den Hinweis an allen Ampeln der Automatikkreise, zu denen die Station laut MK gehoert
*)
FOR wlIndexAK := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO

  wlAK := TO_WORD( BasisStationsParameter.stMKs.eaAutomatikkreis[wlIndexAK] );

  IF PruefungWertImIntervall( wlAK, cERSTER_AUTOMATIKKREIS, cLETZTER_AUTOMATIKKREIS ) THEN
    FOR wlIndexAmpel := 1 TO cANZAHL_AMPELN DO
      Ampel_AK[wlAK, wlIndexAmpel].bpHinweisFWEingriffErforderlich := bpAktiv;
    END_FOR
  END_IF

END_FOR
END_METHOD