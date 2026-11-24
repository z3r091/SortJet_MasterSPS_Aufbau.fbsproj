(* METADATA
{
	"v3Meta": {
		"objectGuid": "3bbd0527-1e76-46f0-a897-fe331d220a8d"
	}
}
*)
ACTION Lisec_Schnittstelle
//-------------------------------------------------------------------------------------------------
// STEUERUNG: AUSGAENGE ZUR VORGAENGERSTATION
//-------------------------------------------------------------------------------------------------
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
ELSIF (in_wAnalogwertISOLinie >= BasisStationsParameter.stMKs.stFremdanlage.wMindestAnalogWert) AND ( blBereitZumEintransport OR in_bTransportRueckwaerts ) THEN
  IF in_bTransportRueckwaerts THEN
    rpGeschwindigkeit := - WORD_TO_REAL(in_wAnalogwertISOLinie) / BasisStationsParameter.stMKs.stFremdanlage.rAnalogWertVerhaeltniss;
  ELSE
    rpGeschwindigkeit := WORD_TO_REAL(in_wAnalogwertISOLinie) / BasisStationsParameter.stMKs.stFremdanlage.rAnalogWertVerhaeltniss;
    rpGeschwindigkeit := MIN( rpGeschwindigkeit, BasisStationsParameter.stMKs.stFremdanlage.rMaxAnalogGeschwindigkeit );
  END_IF
ELSE
  rpGeschwindigkeit := 0;
END_IF

//-------------------------------------------------------------------------------------------------
// STEUERUNG: HARDWARESCHNITTSTELLE
//-------------------------------------------------------------------------------------------------
blSenderGlasBereit := ( ( BasisStationsParameter.bAutomatik )
                        AND NOT BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bFehler )
                      AND ( BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bBereitZumAustransport
                            OR BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]
                            OR BasisStationsParameter.bCheckMitNachfolger[cWAND_1] );
END_ACTION