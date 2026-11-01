(* METADATA
{
  "v3Meta": {
    "objectGuid": "df2f5cbc-ac3c-4e22-b58a-e457a8a01efd"
  }
}
*)
ACTION A_Geblaese
//-------------------------------------------------------------------------------------------------
// AKTION GEBLÄSE
//-------------------------------------------------------------------------------------------------

// Gebläse starten durch den Einlaufsensor
rtlGeblaese( CLK := rtlAnlegen.Q OR ( Glastransport.bpSensorEinlauf AND blFreigabeGeblaeseStartenSensor ) );

// Gebläse starten durch Taster/Handfunktion
rtlTasterGeblaese( CLK := (    in_bTasterGeblaese1Ein
                            OR dwlHandfunktionen.0
                            OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );

// Gebläse starten durch Anlegeauftrag
rtlAnlegen( CLK := BasisStationsParameter.bAnlegen OR BasisStationsParameter.bEintransport[cWAND_1] );

ftlGeblaese( CLK:=(   dwlHandfunktionen.0
                    OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] ) );


tofGeblaeseFreigabeAusschalten ( IN := out_bGeblaese1Ein OR out_bGeblaese2Ein,
                                 PT := ZEIT_GEBLASE_FREIGABE_AUSSCHALTEN );

(* Hinweis:
   - Energiesparmodus: Geblaese bei längerer Inaktivität ausschalten
*)
toflGeblaeseEnergiesparModus( IN := ( rtlGeblaese.Q OR rtlTasterGeblaese.Q ),
                              PT := tgZeitAutoabschaltungEnergiesparModus );

ftTonGeblaesePowerSaving(CLK :=     toflGeblaeseEnergiesparModus.Q AND ( out_bGeblaese1Ein OR out_bGeblaese2Ein ) );


(* Anmerkung:
   - Abhandlung Automatik-Betrieb
   - Abhandlung Hand- Betrieb
*)
IF ( blBetriebsartAutomatik ) THEN

  IF (  ftTonGeblaesePowerSaving.Q
       OR  BasisStationsParameter.bReset
       OR NOT in_bSensorKippsicherungGeschlossen
       OR NOT in_bSensorKipptischUnten )
  THEN
    out_bGeblaese1Ein          := FALSE;
    out_bGeblaese2Ein          := FALSE;
    blMerkerDrosselklappeAuf   := FALSE;
    rtlGeblaese(CLK:= FALSE);
    rtlTasterGeblaese(CLK:=FALSE);

  ELSIF ( rtlTasterGeblaese.Q
          OR    rtlGeblaese.Q )
  THEN

    (* Hinweis:
       - Ist das Geblaese nicht aktiv wieder starten
    *)
    out_bGeblaese1Ein        := TRUE;
    out_bGeblaese2Ein        := TRUE;
    blMerkerDrosselklappeAuf := TRUE;
  END_IF

  (* Hinweis:
     - Geblaese kann erst ausgeschaltet werden wenn dieses
       eine bestimmte Zeit aktiv war
  *)
  IF (  rtlTasterGeblaese.Q
       AND tofGeblaeseFreigabeAusschalten.Q
       AND in_bDrehzahlErreicht )
  THEN
    out_bGeblaese1Ein        := FALSE;
    out_bGeblaese2Ein        := FALSE;
    blMerkerDrosselklappeAuf := FALSE;
  END_IF

ELSE

  // Das Sanftanlaufmodul gibt ein Signal raus, wenn die Drehzahl erreicht ist
  blMerkerDrosselklappeAuf := in_bDrehzahlErreicht;

  IF ( rtlGeblaese.Q
       OR ftlGeblaese.Q
       OR rtlTasterGeblaese.Q )
     AND
     ( ( in_bSensorKippsicherungGeschlossen
         AND in_bSensorKipptischUnten )
       OR NOT ( BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] ) )

  THEN

    IF ( NOT out_bGeblaese1Ein ) THEN
      out_bGeblaese1Ein := TRUE;
      out_bGeblaese2Ein := TRUE;
    ELSE
      out_bGeblaese1Ein := FALSE;
      out_bGeblaese2Ein := FALSE;
    END_IF

  END_IF

END_IF

// Ansteuerung der Drosselklappe
// Das Sanftanlaufmodul gibt ein Signal raus, wenn die Drehzahl erreicht ist
out_bDrosselklappeOeffnen := SEL( NOT in_bDrehzahlErreicht, blMerkerDrosselklappeAuf , FALSE );
END_ACTION