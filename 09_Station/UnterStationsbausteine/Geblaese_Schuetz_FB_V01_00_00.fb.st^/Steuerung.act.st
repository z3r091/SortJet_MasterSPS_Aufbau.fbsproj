(* METADATA
{
  "v3Meta": {
    "objectGuid": "f5d38f69-142e-4a4e-b92a-456c5a95c061"
  }
}
*)
ACTION Steuerung
//-------------------------------------------------------------------------------------------------
// AKTION: STEUERUNG (WANN DAS GEBLAESE LAUFEN SOLL)
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Automatik: Das Geblaese laeuft, solange die Station es braucht (bpAktivitaet), danach noch die Abschaltzeit
     des Energiesparmodus. An Anlegestationen startet nur die Flanke, danach laeuft die Abschaltzeit
   - Taster: schaltet aus, wenn das Geblaese die Mindestlaufzeit laeuft (und die Drehzahl erreicht ist), sonst ein.
     Ausgeschaltet bleibt es bis zur naechsten Aktivitaet
   - Handbetrieb: Geblaese laeuft, solange die Handfunktion gesetzt ist, der Taster schaltet um
   - Sperre: sofort aus
*)
rtlAutomatik( CLK := bpAutomatik );
rtlAktivitaet( CLK := bpAktivitaet );
rtlTaster( CLK := bpTaster );

tonlMindestlaufzeit( IN := out_bStarteGeblaese, PT := tpMindestlaufzeit );

IF ( bpSperre ) THEN
  blTasterAus  := FALSE;
  blHandTaster := FALSE;
  toflEnergiesparModus( IN := FALSE, PT := T#0S );
  bpStart := FALSE;

ELSIF ( bpAutomatik ) THEN
  blHandTaster := FALSE;

  IF ( rtlTaster.Q ) THEN
    blTasterAus := ( out_bStarteGeblaese AND tonlMindestlaufzeit.Q AND bpDrehzahlErreicht );
  END_IF

  // Neue Aktivitaet hebt das Ausschalten per Taster wieder auf
  IF ( rtlAktivitaet.Q OR rtlAutomatik.Q ) THEN
    blTasterAus := FALSE;
  END_IF

  toflEnergiesparModus( IN := (    SEL( bpAktivitaetFlanke, bpAktivitaet, rtlAktivitaet.Q )
                                OR rtlAutomatik.Q
                                OR ( rtlTaster.Q AND NOT blTasterAus ) ),
                        PT := tgZeitAutoabschaltungEnergiesparModus );

  bpStart := toflEnergiesparModus.Q AND bpFreigabe AND NOT blTasterAus;

ELSE
  blTasterAus := FALSE;

  IF ( rtlTaster.Q ) THEN
    blHandTaster := NOT blHandTaster;
  END_IF

  toflEnergiesparModus( IN := FALSE, PT := tgZeitAutoabschaltungEnergiesparModus );

  bpStart := ( bpHandEin OR blHandTaster );

END_IF
END_ACTION