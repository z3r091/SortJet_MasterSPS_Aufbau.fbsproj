(* METADATA
{
	"v3Meta": {
		"objectGuid": "e8d29946-42cb-4086-9005-bb6393195211"
	}
}
*)
ACTION Forel_Schnittstelle
//-------------------------------------------------------------------------------------------------
// STEUERUNG: AUSGAENGE ZUR VORGAENGERSTATION
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Wie Lisec, zusaetzlich: Analogwert-Verhaeltnis 0 => Festgeschwindigkeit aus der MK statt Analogwert
*)
blBereitZumEintransport := in_bGlasAbruf OR ( in_bTasterGlasbruch AND in_bTasterSpezial ) OR VISU_VARS.abgVISUFreigabeFremdanlage[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

IF ( in_bTasterGlasbruch AND in_bTasterSpezial ) OR VISU_VARS.abgVISUFreigabeFremdanlage[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] THEN
  rpGeschwindigkeit := BasisStationsParameter.stMKs.stFremdanlage.rGeschwindigkeit;

// Analogwert nicht aktiv oder Verhaeltnis 0 (Festgeschwindigkeit)
ELSIF (    NOT BasisStationsParameter.stMKs.stFremdanlage.bAnalogwertAktiv
        OR ( BasisStationsParameter.stMKs.stFremdanlage.rAnalogWertVerhaeltniss = 0.0 ) )
THEN
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