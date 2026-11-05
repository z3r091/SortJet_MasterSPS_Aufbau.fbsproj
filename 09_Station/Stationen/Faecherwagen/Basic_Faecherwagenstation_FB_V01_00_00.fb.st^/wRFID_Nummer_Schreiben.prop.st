(* METADATA
{
  "v3Meta": {
    "objectGuid": "61bac579-e653-41b2-b8f0-3212942feb17",
    "subObjects": {
      "set": {
        "objectGuid": "2c0cfeca-c808-44fa-9f3f-5faac4060747"
      },
      "get": {
        "objectGuid": "9b84b645-b409-4691-950a-aea1dfb88055"
      }
    }
  }
}
*)
PROPERTY_Set wRFID_Nummer_Schreiben : WORD
VAR
END_VAR
// Neue Nummer fuer den RFID-Chip; die Variante schreibt bei steigender Flanke (Wert > 0)
wlRFID_Nummer_Schreiben := wRFID_Nummer_Schreiben;
END_PROPERTY
PROPERTY_Get wRFID_Nummer_Schreiben : WORD
VAR
END_VAR
wRFID_Nummer_Schreiben := wlRFID_Nummer_Schreiben;
END_PROPERTY
