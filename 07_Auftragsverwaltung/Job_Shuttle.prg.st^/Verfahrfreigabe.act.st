(* METADATA
{
  "v3Meta": {
    "objectGuid": "c5ed0ecf-290a-4d28-a44b-5709f6fc01b5"
  }
}
*)
ACTION Verfahrfreigabe
(***************************************************************************************************)
(* BAUSTEIN: VERFAHRFREIGABE SHUTTLE                                                               *)
(***************************************************************************************************)
(* Hinweis:
   - bpShuttleAnhalten wird generisch aus starrShuttleBasisParameter[...].stMKs.astShuttleAnhaltenQuellen gebildet.
   - Pro Shuttle werden alle aktiven Eintraege per OR verknuepft.
   - Keine festen Stations- oder Shuttle-Nummern im Code.
   - Parametrierung erfolgt ausschliesslich in MK_Shuttle.
   - getBasis() loest Station / Shuttle / Transfershuttle einheitlich auf.
*)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

  aShuttle[wlIndex].bpShuttleAnhalten := FALSE;

  FOR wlIndexQuelle := 1 TO cMAX_SHUTTLE_ANHALTEN_QUELLEN DO

    IF starrShuttleBasisParameter[wlIndex].stMKs.astShuttleAnhaltenQuellen[wlIndexQuelle].bAktiv THEN

      Basis REF= getBasis(starrShuttleBasisParameter[wlIndex].stMKs.astShuttleAnhaltenQuellen[wlIndexQuelle].wQuellenNummer);

      // Hinweis: Quelle ist in dieser Konfiguration nicht vorhanden => ueberspringen
      IF __ISVALIDREF( Basis ) THEN

        CASE starrShuttleBasisParameter[wlIndex].stMKs.astShuttleAnhaltenQuellen[wlIndexQuelle].eSensorTyp OF

          eAuslaufsensor:
            IF Basis.OutGlasTransport[starrShuttleBasisParameter[wlIndex].stMKs.astShuttleAnhaltenQuellen[wlIndexQuelle].wWand].bScheibeFaehrtUeberAuslauf THEN
              aShuttle[wlIndex].bpShuttleAnhalten := TRUE;
            END_IF

          eEinlaufsensor:
            IF Basis.OutGlasTransport[starrShuttleBasisParameter[wlIndex].stMKs.astShuttleAnhaltenQuellen[wlIndexQuelle].wWand].bScheibeFaehrtUeberEinlauf THEN
              aShuttle[wlIndex].bpShuttleAnhalten := TRUE;
            END_IF

        END_CASE

      END_IF

    END_IF

  END_FOR

END_FOR

(* ---------------------------------------------------------------------------------------
//  VERFAHRLOGIK - RESET DER POSITIONIERUNG NACH ABBRUCH
//         
//  Hinweis:
//  - Zurueck des Auftrags  "cSHUTTLE_VORABPOSITIONIERUNG" wenn dieser aktiv gewesen ist
// ---------------------------------------------------------------------------------------*)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  IF  ( starrShuttleBasisParameter[wlIndex].bPositionierAuftragZuruecksetzen ) THEN
      IF ( AuftragsdatenStation[wlIndex].wAuftrag = eStation_Vorabpositionierung ) THEN
        starrShuttleBasisParameter[wlIndex].bQuittungPositionierungZurueckgesetzt := TRUE;
         AuftragsdatenStation[wlIndex].wAuftrag := eStation_Kein_Auftrag;
      END_IF
  END_IF
END_FOR

(* ---------------------------------------------------------------------------------------
//  VERFAHRLOGIK TRANSFERSHUTTLE - RESET DER POSITIONIERUNG NACH ABBRUCH
//         
//  Hinweis:
//  - Zurueck des Auftrags  "cSHUTTLE_VORABPOSITIONIERUNG" wenn dieser aktiv gewesen ist
// ---------------------------------------------------------------------------------------*)
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  IF  ( starrTransfershuttleBasisParameter[wlIndex].bPositionierAuftragZuruecksetzen ) THEN
    IF ( AuftragsdatenTransfershuttle[wlIndex].wAuftrag = eStation_Vorabpositionierung ) THEN
      starrTransfershuttleBasisParameter[wlIndex].bQuittungPositionierungZurueckgesetzt := TRUE;
      AuftragsdatenTransfershuttle[wlIndex].wAuftrag := eStation_Kein_Auftrag;
    END_IF
  END_IF
END_FOR
END_ACTION