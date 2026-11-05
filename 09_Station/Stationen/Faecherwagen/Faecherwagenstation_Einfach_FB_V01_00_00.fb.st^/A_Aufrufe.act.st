(* METADATA
{
  "v3Meta": {
    "objectGuid": "ba4713a0-895f-4932-a248-fc06bbb5eaab"
  }
}
*)
ACTION A_Aufrufe
//-------------------------------------------------------------------------------------------------
// AUFRUFE: ARRETIERUNG
//-------------------------------------------------------------------------------------------------
// Ausgefahren = Faecherwagen arretiert, eingefahren = Faecherwagen freigegeben
Arretierung.in_bStatusZylinderAusgefahren := in_bArretierungAusgefahren;
Arretierung.in_bStatusZylinderEingefahren := in_bArretierungEingefahren;
Arretierung.bpStartAusfahren              := blArretierungSchliessen AND NOT blArretierungOeffnen;
Arretierung.bpStartEinfahren              := blArretierungOeffnen AND NOT blArretierungSchliessen;

Arretierung();

out_bArretierungAusfahren := Arretierung.out_bZylinderAusfahren;
out_bArretierungEinfahren := Arretierung.out_bZylinderEinfahren;

blArretierungSchliessenDone := Arretierung.bpStartAusfahren AND Arretierung.bpDone AND blArretierungGeschlossen;
blArretierungOeffnenDone    := Arretierung.bpStartEinfahren AND Arretierung.bpDone AND blArretierungOffen;

(* Fehlerbehandlung:
   - Endlage der Arretierung nicht in der Zeit erreicht (Ueberwachung im Arretierung_FB)
*)
rtlArretierungFehler( CLK := Arretierung.bpFehler );

IF ( rtlArretierungFehler.Q ) THEN

  IF ( blArretierungSchliessen ) THEN
    wpFehlerNr := cMELDUNG_FAECHERWAGEN_UEBERWACHUNG_ZENTRIERUNG_SCHLIESSEN;
  ELSE
    wpFehlerNr := cMELDUNG_FAECHERWAGEN_UEBERWACHUNG_ZENTRIERUNG_OEFFNEN;
  END_IF

  SpsError( eFehler_Station,
            wpFehlerNr,
            BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
            AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
            BasisStationsParameter.awFehlerInformationen );

  BasisStationsParameter.wFehlerNummer := wpFehlerNr;
  BasisStationsParameter.bFehler       := TRUE;

END_IF
END_ACTION