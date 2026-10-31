(* METADATA
{
  "v3Meta": {
    "objectGuid": "72d4c0e2-2638-4550-ae99-6e972629df44"
  }
}
*)
ACTION Handfunktionen
(***************************************************************************************************)
(* HANDFUNKTIONEN *)
(***************************************************************************************************)
IF ( NOT  BasisStationsParameter.bAutomatik
  AND NOT BasisStationsParameter.bReset
  AND NOT BasisStationsParameter.bCheck
  AND NOT BasisStationsParameter.bReferenz
  AND NOT bpScheibenNeuAusrichten )
THEN

  dwlHandfunktionen := dwlHandfunktionen;

  (* Anmerkung:
     - Transfershuttle [Glastransport] heben / senken
  *)
  Glastransport.bpHandGlastransportAnheben := dwlHandfunktionen.0 OR bgVisuTFSRiemenAnheben[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

  (* Handfunktion:
     - Glastransport vor / zurück
  *)
  Glastransport.bpHandfahrenPositiv  := ((dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) AND NOT
                                  (dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]));  (* Bit 1 = Glastransport vor *)

  Glastransport.bpHandfahrenNegativ  := ((dwlHandfunktionen.2 OR bgVISUGlastransportZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]) AND NOT
                                  (dwlHandfunktionen.1 OR bgVISUGlastransportVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, cWAND_1]));  (* Bit 2 = Glastransport zurück *)

  (* Anmerkung:
     - Luftssensoren [Scheibenkontrolle] heben / senken
     - Einlauf / Auslauf
  *)
  Glastransport.bpHandScheibenKontrolleEinlaufseiteAnheben := dwlHandfunktionen.3 OR bgVisuTFSAbfrageEinlaufAuf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];
  Glastransport.bpHandScheibenKontrolleAuslaufseiteAnheben := dwlHandfunktionen.5 OR bgVisuTFSAbfrageAuslaufAuf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

  (* Anmerkung:
     - Luftssensoren [Scheibenkontrolle] aktivieren / deaktivieren    
  *)
  Glastransport.bpHandScheibenKontrolleEinlaufseiteEin := dwlHandfunktionen.4 OR bgVisuTFSAbfrageEinlaufEin[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];
  Glastransport.bpHandScheibenKontrolleAuslaufseiteEin := dwlHandfunktionen.6 OR bgVisuTFSAbfrageAuslaufEin[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

  (* Hinweis:
     - Querfahrt
       => Erst aktivieren wenn nötig
  *)
  Querfahrt.bpStartReferenz := (( dwlHandfunktionen.16 OR bgVisuTFSQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS])
                                       AND NOT (   dwlHandfunktionen.14
                                                OR dwlHandfunktionen.15
                                                OR bgVisuTFSQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                                OR bgVisuTFSQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandplus      := ((  dwlHandfunktionen.14 OR bgVisuTFSQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                       AND NOT (   dwlHandfunktionen.15
                                                OR dwlHandfunktionen.16
                                                OR bgVisuTFSQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                                OR bgVisuTFSQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  Querfahrt.bpHandminus     := (( dwlHandfunktionen.15 OR bgVisuTFSQuerfahrtZurueck[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] )
                                       AND NOT (   dwlHandfunktionen.14
                                                OR dwlHandfunktionen.16
                                                OR bgVisuTFSQuerfahrtReferenz[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]
                                                OR bgVisuTFSQuerfahrtVor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ));

  (* Starten der Zentralschmierung *)
  Zentralschmierung.bpStartSchmierungHand := ( dwlHandfunktionen.20 OR bgVisuTFSZentralschmierungStarten[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] );
  

  (* Anmerkung[BREITE ABFRAGEN]:
     - Optional   
  *)
  Glastransport.bpGlastransportTest := bgVisuTFSGlastransporttestAktivieren[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

ELSE
  Zentralschmierung.bpStartSchmierungHand := FALSE;
END_IF
END_ACTION