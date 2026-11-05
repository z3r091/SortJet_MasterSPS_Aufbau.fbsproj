(* METADATA
{
  "v3Meta": {
    "objectGuid": "9a338ae0-ff6b-4706-9348-3df612293565"
  }
}
*)
ACTION A_Aufrufe
//-------------------------------------------------------------------------------------------------
// AUFRUFE: ANSCHLAG
//-------------------------------------------------------------------------------------------------
// Ausgefahren = Anschlag oben; ohne Anschlag (MK) meldet der Zylinder kein Done
Anschlag.in_bStatusZylinderAusgefahren := in_bAnschlagOben;
Anschlag.in_bStatusZylinderEingefahren := in_bAnschlagUnten;
Anschlag.bpStartAusfahren              := blAnschlagAuf AND NOT blAnschlagAb;
Anschlag.bpStartEinfahren              := blAnschlagAb AND NOT blAnschlagAuf;

Anschlag();

out_bAnschlagAuf := Anschlag.out_bZylinderAusfahren;
out_bAnschlagAb  := Anschlag.out_bZylinderEinfahren;

blAnschlagAufDone :=     blAnschlagAuf
                     AND (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag
                           OR ( Anschlag.bpDone AND Anschlag.epStatusZylinder = eZylinderAusgefahren ) );
blAnschlagAbDone  :=     blAnschlagAb
                     AND (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag
                           OR ( Anschlag.bpDone AND Anschlag.epStatusZylinder = eZylinderEingefahren ) );

(* Fehlerbehandlung:
   - Endlage des Anschlags nicht in der Zeit erreicht (Ueberwachung im ZylinderPneumatik_FB)
*)
rtlAnschlagFehler( CLK := Anschlag.bpFehler );

IF ( rtlAnschlagFehler.Q ) THEN
  wpFehlerNr := Anschlag.wpFehlerNr;
  SpsError( eFehler_Station,
            wpFehlerNr,
            BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
            AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
            BasisStationsParameter.awFehlerInformationen );

  BasisStationsParameter.wFehlerNummer := wpFehlerNr;
  BasisStationsParameter.bFehler       := TRUE;
END_IF

//-------------------------------------------------------------------------------------------------
// AUFRUFE: ANSCHLAG HORIZONTAL (OPTION AGV)
//-------------------------------------------------------------------------------------------------
// Ausgefahren = Anschlag vorne; ohne Anschlag oder ohne AGV-Betrieb gibt es keine Bewegung
AnschlagHorizontal.in_bStatusZylinderAusgefahren := in_bAnschlagVorne;
AnschlagHorizontal.in_bStatusZylinderEingefahren := in_bAnschlagHinten;
AnschlagHorizontal.bpStartAusfahren              := blAnschlagVor AND NOT blAnschlagZurueck;
AnschlagHorizontal.bpStartEinfahren              := blAnschlagZurueck AND NOT blAnschlagVor;

AnschlagHorizontal();

out_bAnschlagVor     := AnschlagHorizontal.out_bZylinderAusfahren;
out_bAnschlagZurueck := AnschlagHorizontal.out_bZylinderEinfahren;

blAnschlagVorDone     :=     blAnschlagVor
                         AND (    NOT AnschlagHorizontal.bpAktivieren
                               OR ( AnschlagHorizontal.bpDone AND AnschlagHorizontal.epStatusZylinder = eZylinderAusgefahren ) );
blAnschlagZurueckDone :=     blAnschlagZurueck
                         AND (    NOT AnschlagHorizontal.bpAktivieren
                               OR ( AnschlagHorizontal.bpDone AND AnschlagHorizontal.epStatusZylinder = eZylinderEingefahren ) );

(* Fehlerbehandlung:
   - Endlage vorne/hinten nicht in der Zeit erreicht (Ueberwachung im ZylinderPneumatik_FB)
*)
rtlAnschlagHorizontalFehler( CLK := AnschlagHorizontal.bpFehler );

IF ( rtlAnschlagHorizontalFehler.Q ) THEN
  wpFehlerNr := AnschlagHorizontal.wpFehlerNr;
  SpsError( eFehler_Station,
            wpFehlerNr,
            BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
            AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
            BasisStationsParameter.awFehlerInformationen );

  BasisStationsParameter.wFehlerNummer := wpFehlerNr;
  BasisStationsParameter.bFehler       := TRUE;
END_IF
END_ACTION