(* METADATA
{
  "v3Meta": {
    "objectGuid": "df2f5cbc-ac3c-4e22-b58a-e457a8a01efd"
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
(* Hinweis:
   - Anlegestation: die Flanke des Auftrags (bzw. der belegte Einlaufsensor beim Anlegen) startet, danach laeuft die Abschaltzeit
   - Sperre: Kippsicherung offen oder Kipptisch nicht unten
*)
Geblaese.bpAutomatik        := blBetriebsartAutomatik;
Geblaese.bpAktivitaet       := (    BasisStationsParameter.bAnlegen
                                 OR BasisStationsParameter.bEintransport[cWAND_1]
                                 OR ( Glastransport.bpSensorEinlauf AND Anlegen.bpGeblaeseStartenSensor ) );
Geblaese.bpAktivitaetFlanke := BasisStationsParameter.stMKs.stStationsOptionen.stAnlegetisch.bIstAnlegestation;
Geblaese.bpTaster           := in_bTasterGeblaese1Ein;
Geblaese.bpHandEin          := ( dwlHandfunktionen.0 OR bgVISUGeblaese[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1] );
Geblaese.bpSperre           := (    BasisStationsParameter.bReset
                                 OR (     ( NOT in_bSensorKippsicherungGeschlossen OR NOT in_bSensorKipptischUnten )
                                      AND ( blBetriebsartAutomatik OR BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] ) ) );
Geblaese.tpMindestlaufzeit  := ZEIT_GEBLASE_FREIGABE_AUSSCHALTEN;

(* Hinweis:
   - Drosselklappe: oeffnet, sobald das Geblaese laeuft (Drehzahl erreicht), und schliesst, wenn es steht
     (die Aktionen fordern sie zusaetzlich an)
*)
rtlGeblaeseLaeuft( CLK := Geblaese.bpDone );
ftlGeblaeseLaeuft( CLK := Geblaese.bpDone );

IF ( NOT blBetriebsartAutomatik ) THEN
  blMerkerDrosselklappeAuf := Geblaese.bpDone;
ELSIF ( rtlGeblaeseLaeuft.Q ) THEN
  blMerkerDrosselklappeAuf := TRUE;
ELSIF ( ftlGeblaeseLaeuft.Q ) THEN
  blMerkerDrosselklappeAuf := FALSE;
END_IF

(* Hinweis:
   - Geblaese-Baustein: Schuetz, Motorschutz, Wiederanlaufsperre, Hochlauf und Drosselklappe
   - Das Sanftanlaufmodul gibt ein Signal raus, wenn die Drehzahl erreicht ist: erst dann laeuft das Geblaese
     und die Drosselklappe darf oeffnen
*)
Geblaese( stStationsNummern          := BasisStationsParameter.stMKs.stStationsNummern,
          bpFreigabe                 := BasisStationsParameter.bFreigabe,
          bpIOsBoschDrive            := TRUE,
          bpMotorschutzschalter_OK   := in_bMotorschutzGeblaese_Ok,
          bpDrehzahlErreicht         := in_bDrehzahlErreicht,
          bpDrosselklappeAnforderung := blMerkerDrosselklappeAuf );

out_bGeblaese1Ein         := Geblaese.bpStarteGeblaese;
out_bGeblaese2Ein         := Geblaese.bpStarteGeblaese;
out_bDrosselklappeOeffnen := Geblaese.bpDrosselklappeOeffnen;
END_ACTION