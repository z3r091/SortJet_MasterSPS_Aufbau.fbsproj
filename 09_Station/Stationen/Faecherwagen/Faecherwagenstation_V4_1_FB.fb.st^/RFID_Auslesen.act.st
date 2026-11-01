(* METADATA
{
  "v3Meta": {
    "objectGuid": "212c3c69-b3ee-4d9d-ac64-7450de5fc49f"
  }
}
*)
ACTION RFID_Auslesen
// RFID Auslesen
IF blRFID_Auslesen THEN
  CASE steplRFID_Auslesen OF
    // RFID Auslesen
    STEP_0_E:
      wlRFID_Nummer := 000;
      slRFID_Validierung := '';
      slRFID_Nummer :='';
      wlIndexByte := 1;
      wlIndexZiffer:=0;
      IF BasisStationsParameter.stMKs.stStationsAufbau.bRFID THEN
        steplRFID_Auslesen := STEP_10_E;
      ELSE
        steplRFID_Auslesen := STEP_1000_E;
      END_IF

    // RFID Auslesen
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Die einzelnen Bits der Benötigten Bytes werden in einem Byte zusammen gefasst
      // ---------------------------------------------------------------------------------------

      FOR wlIndexByte := ERSTES_ZEICHEN TO (ERSTE_ZIFFER_RFID + ANZAHL_ZIFFERN_RFID - 1) DO//in den Bytes 16-23 stehen die relevanten Daten des RFID-Chips
        abylBytesRFID[wlIndexByte].0:= ablRFID[wlIndexByte,0]; 
        abylBytesRFID[wlIndexByte].1:= ablRFID[wlIndexByte,1]; 
        abylBytesRFID[wlIndexByte].2:= ablRFID[wlIndexByte,2]; 
        abylBytesRFID[wlIndexByte].3:= ablRFID[wlIndexByte,3]; 
        abylBytesRFID[wlIndexByte].4:= ablRFID[wlIndexByte,4]; 
        abylBytesRFID[wlIndexByte].5:= ablRFID[wlIndexByte,5]; 
        abylBytesRFID[wlIndexByte].6:= ablRFID[wlIndexByte,6]; 
        abylBytesRFID[wlIndexByte].7:= ablRFID[wlIndexByte,7]; 
      END_FOR


      steplRFID_Auslesen := STEP_100_E;

    // RFID Auslesen
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Die ersten Bytes werden überprüft ob diese den Wert "Rack " ergeben
      // ---------------------------------------------------------------------------------------

      FOR wlIndexByte := ERSTES_ZEICHEN TO (ERSTE_ZIFFER_RFID - 1) DO
        slRFID_Validierung := CONCAT(slRFID_Validierung, ascii[abylBytesRFID[wlIndexByte]] );
      END_FOR

      IF ( slRFID_Validierung = VERGLEICH_RFID_VALID)THEN
        steplRFID_Auslesen := STEP_150_E;
      ELSE
        slRFID_Validierung := '';
      END_IF

    // RFID Auslesen
    STEP_150_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Umwandeln der Bytes in welchen die Ziffern stehen in einen String(hier 21-23)
      // - Umwandeln des Strings in ein WORD
      // ---------------------------------------------------------------------------------------

      FOR wlIndexZiffer := ERSTE_ZIFFER_RFID TO (ERSTE_ZIFFER_RFID + ANZAHL_ZIFFERN_RFID - 1) DO//zusammenfügen aller Ziffernbytes in einen String
        slRFID_Nummer := CONCAT(slRFID_Nummer, ascii[abylBytesRFID[wlIndexZiffer]] );
      END_FOR
      wlRFID_Nummer    := STRING_TO_WORD(slRFID_Nummer);
      // Überprüfen der Ausgelesenen ID, ob diese nicht die Obergrenze überschreitet Es muss aufgepasst werden, das der Wert auf dem Chip nicht 65535 überschreitet.
      // Sollte er dies tun, dann wird ein größerer Datentyp benötigt
      IF (wlRFID_Nummer > 0) AND (wlRFID_Nummer <= wlMaxRFIDNummer) THEN
        steplRFID_Auslesen := STEP_1000_E;
      END_IF

    STEP_1000_E:
      blRFID_DataValid := TRUE;


  END_CASE
END_IF

IF NOT blRFID_Auslesen THEN
  IF steplRFID_Auslesen <> 0 THEN
    blRFID_DataValid := FALSE;
    steplRFID_Auslesen := STEP_0_E;
  END_IF
END_IF
END_ACTION