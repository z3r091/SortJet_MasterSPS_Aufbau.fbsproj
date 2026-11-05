(* METADATA
{
  "v3Meta": {
    "objectGuid": "72d4c0e2-2638-4550-ae99-6e972629df44"
  }
}
*)
ACTION Handfunktionen
//-------------------------------------------------------------------------------------------------
// HANDFUNKTIONEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Bitverteilung aus der Oberfläche (einheitlich fuer alle Stationen, 4 Seiten zu 7 Knoepfen):
     Seite 1:  1/2 Glastransport vor/zurueck, 5 Riemen anheben
     Seite 2:  11/12/13 Querfahrt vor/zurueck/Referenz
     Seite 3:  17 Zentralschmierung
     Seite 4:  21/22 Luftsensoren Einlauf anheben/ein, 23/24 Luftsensoren Auslauf anheben/ein
*)
IF ( NOT  BasisStationsParameter.bAutomatik
     AND NOT BasisStationsParameter.bReset
     AND NOT BasisStationsParameter.bCheck
     AND NOT BasisStationsParameter.bReferenz
     AND NOT bpScheibenNeuAusrichten )
THEN

  (* Anmerkung:
     - Transfershuttle [Glastransport] heben / senken
  *)
  Glastransport.bpHandGlastransportAnheben := dwlHandfunktionen.5 OR bgVisuTFSRiemenAnheben[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

  // Handfunktion:
  //   - Glastransport vor / zurück
  Glastransport.bpHandfahrenPositiv  := ((dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) AND NOT
                                          (dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]));  // Bit 1 = Glastransport vor

  Glastransport.bpHandfahrenNegativ  := ((dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) AND NOT
                                          (dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]));  // Bit 2 = Glastransport zurück

  (* Anmerkung:
     - Luftssensoren [Scheibenkontrolle] heben / senken
     - Einlauf / Auslauf
  *)
  Glastransport.bpHandScheibenKontrolleEinlaufseiteAnheben := dwlHandfunktionen.21 OR bgVisuTFSAbfrageEinlaufAuf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];
  Glastransport.bpHandScheibenKontrolleAuslaufseiteAnheben := dwlHandfunktionen.23 OR bgVisuTFSAbfrageAuslaufAuf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

  (* Anmerkung:
     - Luftssensoren [Scheibenkontrolle] aktivieren / deaktivieren
  *)
  Glastransport.bpHandScheibenKontrolleEinlaufseiteEin := dwlHandfunktionen.22 OR bgVisuTFSAbfrageEinlaufEin[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];
  Glastransport.bpHandScheibenKontrolleAuslaufseiteEin := dwlHandfunktionen.24 OR bgVisuTFSAbfrageAuslaufEin[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

  (* Hinweis:
     - Querfahrt
       => Erst aktivieren wenn nötig
  *)
  Querfahrt.bpStartReferenz := (( dwlHandfunktionen.13 OR bgVisuTFSQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                                 AND NOT (   dwlHandfunktionen.11
                                           OR dwlHandfunktionen.12
                                           OR bgVisuTFSQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                           OR bgVisuTFSQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandplus      := ((  dwlHandfunktionen.11 OR bgVisuTFSQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT (   dwlHandfunktionen.12
                                           OR dwlHandfunktionen.13
                                           OR bgVisuTFSQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                           OR bgVisuTFSQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandminus     := (( dwlHandfunktionen.12 OR bgVisuTFSQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                 AND NOT (   dwlHandfunktionen.11
                                           OR dwlHandfunktionen.13
                                           OR bgVisuTFSQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                           OR bgVisuTFSQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  // Starten der Zentralschmierung
  Zentralschmierung.bpStartSchmierungHand := ( dwlHandfunktionen.17 OR bgVisuTFSZentralschmierungStarten[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );
  

  (* Anmerkung [BREITE ABFRAGEN]:
     - Optional
  *)
  Glastransport.bpGlastransportTest := bgVisuTFSGlastransporttestAktivieren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

ELSE
  Zentralschmierung.bpStartSchmierungHand := FALSE;
END_IF

HandfunktionenStatus();
END_ACTION