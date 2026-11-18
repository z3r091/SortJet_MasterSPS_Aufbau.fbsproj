(* METADATA
{
	"v3Meta": {
		"objectGuid": "b5d583d3-89c4-4d74-8416-e72ac3d75b2b"
	}
}
*)
ACTION Zuweisung_Freigabe
//-------------------------------------------------------------------------------------------------
// ZUWEISUNG DER FREIGABEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Alle Freigaben einer Station stehen in stFreigabe (bAlles + je Komponente)
   - Berechnung: setFreigabeKomponenten (NotHalt, Sicherheitskreise inkl. Teilabschaltung, Bruecken)
*)

// Stationen
FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  setFreigabeKomponenten(starrStationBasisParameter[wlIndex]);
END_FOR

// Shuttle
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  setFreigabeKomponenten(starrShuttleBasisParameter[wlIndex]);
END_FOR

// Transfershuttle
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  setFreigabeKomponenten(starrTransfershuttleBasisParameter[wlIndex]);
END_FOR

// Fächerwagenstationen
FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
  setFreigabeKomponenten(starrFaecherwagenBasisParameter[wlIndex]);
END_FOR

// Schnittstelle Auslauf
FOR wlIndex := cERSTE_FREMDANLAGE_AUSLAUF TO cLETZTE_FREMDANLAGE_AUSLAUF DO
  setFreigabeKomponenten(starrFremdanlageAuslaufStationBasisParameter[wlIndex]);
END_FOR

// Schnittstelle Einlauf
FOR wlIndex := cERSTE_FREMDANLAGE_EINLAUF TO cLETZTE_FREMDANLAGE_EINLAUF DO
  setFreigabeKomponenten(starrFremdanlageEinlaufStationBasisParameter[wlIndex]);
END_FOR
END_ACTION