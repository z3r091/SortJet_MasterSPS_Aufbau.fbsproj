(* METADATA
{
  "v3Meta": {
    "objectGuid": "2dce68d4-a5fa-4829-9d6b-aa2cc71de5cd"
  }
}
*)
ACTION A_Baustein_Initialisierung
//-------------------------------------------------------------------------------------------------
// BAUSTEIN INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
BasisStationsParameter.awFehlerInformationen[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;

blRFID_Sensor_ModusBit_0 := TRUE;  // auf diese Art wird das automatische Auslesen des RFID-Sensors gestartet
blRFID_Sensor_ModusBit_1 := FALSE;
blRFID_Sensor_ModusBit_2 := FALSE;
blRFID_Sensor_ModusBit_3 := FALSE;
blRFID_Sensor_ModusBit_4 := FALSE;
blRFID_Sensor_ModusBit_5 := FALSE;
blRFID_Sensor_ModusBit_6 := FALSE;
blRFID_Sensor_ModusBit_7 := FALSE;
slMaxRFID_Nummer := '';

IF ANZAHL_ZIFFERN_RFID < 5 THEN // Maxwert des Datentypes muss beachtet werden. Sonst gibt es einen Überlauf; Maxwert := 65535
  FOR wlIndexZiffer := 1 TO ANZAHL_ZIFFERN_RFID DO // zusammenfügen aller Ziffern des Maxwertes in einen String
    slMaxRFID_Nummer := CONCAT(slMaxRFID_Nummer, '9' );
  END_FOR
  wlMaxRFIDNummer := STRING_TO_WORD(slMaxRFID_Nummer);
ELSE
  wlMaxRFIDNummer := 65535; // Max Wert eines Wortes
END_IF
END_ACTION