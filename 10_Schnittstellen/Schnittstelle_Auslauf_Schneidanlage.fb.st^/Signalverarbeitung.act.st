(* METADATA
{
  "v3Meta": {
    "objectGuid": "d1a8c055-e553-4ad3-b9fd-e854b6194fb2"
  }
}
*)
ACTION Signalverarbeitung
blBereitZumEintransport := in_bGlasAbruf OR ( in_bTasterGlasbruch AND in_bTasterSpezial ) OR VISU_VARS.abgVISUFreigabeFremdanlage[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

IF ( in_bTasterGlasbruch AND in_bTasterSpezial ) OR VISU_VARS.abgVISUFreigabeFremdanlage[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] THEN
  rpGeschwindigkeit := BasisStationsParameter.stMKs.stFremdanlage.rGeschwindigkeit;
  
// Analogwert nicht aktiv
ELSIF NOT BasisStationsParameter.stMKs.stFremdanlage.bAnalogwertAktiv THEN
  IF blBereitZumEintransport THEN
    rpGeschwindigkeit := BasisStationsParameter.stMKs.stFremdanlage.rGeschwindigkeit;
  ELSE
    rpGeschwindigkeit := 0.0;
  END_IF
  
// Analogwert aktiv
(*
ELSIF (in_wAnalogwertISOLinie >= BasisStationsParameter.stMKs.stFremdanlage.wMindestAnalogWert) AND ( blBereitZumEintransport OR in_bTransportRueckwaerts ) THEN
  IF in_bTransportRueckwaerts THEN
    rpGeschwindigkeit := - WORD_TO_REAL(in_wAnalogwertISOLinie) / BasisStationsParameter.stMKs.stFremdanlage.rAnalogWertVerhaeltniss;
  ELSE
    rpGeschwindigkeit := WORD_TO_REAL(in_wAnalogwertISOLinie) / BasisStationsParameter.stMKs.stFremdanlage.rAnalogWertVerhaeltniss;
  END_IF*)
ELSE
  rpGeschwindigkeit := 0;
END_IF
END_ACTION