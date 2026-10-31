(* METADATA
{
  "v3Meta": {
    "objectGuid": "ac996fe1-9bce-4d65-b8a5-db1a5457671f"
  }
}
*)
FUNCTION_BLOCK Eckuebergabe_FB EXTENDS Basic_Station_FB

// Hinweis:
// - Eckuebergabe mit zwei Glastransport-Achsen (X und Y) auf einer Ebene
// - Die Riemen sitzen im Hubrahmen: Hubrahmen oben = Riemenachse arbeitet, unten = andere Achse
// - Welche Achse welchen Ein-/Austransport macht, kommt je Nachbar aus
//   stSchnittstellendaten.aEintransporte/aAustransporte.Achsrichtung
// - Kommt die Scheibe nicht ueber die Austransport-Achse, uebernimmt diese nach dem Eintransport
//   die Scheibe per Vortransport

VAR

  // BOOLEAN
  blHubrahmenPositionieren : BOOL; // Anforderung aus den Schrittketten: Hubrahmen auf elHubrahmenZielAchse stellen
  blHubrahmenInPosition    : BOOL; // Hubrahmen steht auf elHubrahmenZielAchse

  // ENUM
  elRiemenAchse        : Achsrichtung_EN; // Achse der Riemen im Hubrahmen (MK)
  elAchseEintransport  : Achsrichtung_EN; // Achse des aktuellen Eintransports (Auftrag)
  elAchseAustransport  : Achsrichtung_EN; // Achse fuer den Austransport (Schnittstellendaten)
  elAchseSchnittstelle : Achsrichtung_EN; // Achse, deren Signale an die Nachbarstationen gehen
  elHubrahmenZielAchse : Achsrichtung_EN; // Achse, auf die der Hubrahmen gestellt wird

  // BAUSTEINE
  Glastransport_X : Eckuebergabe_Glastransport_FB;
  Glastransport_Y : Eckuebergabe_Glastransport_FB;
  Hubrahmen       : ZylinderPneumatik_FB; // Ausgefahren = oben, eingefahren = unten

  // REFERENZEN
  GlastransportEin           : REFERENCE TO Eckuebergabe_Glastransport_FB; // Achse des aktuellen Eintransports
  GlastransportAus           : REFERENCE TO Eckuebergabe_Glastransport_FB; // Austransport-Achse
  GlastransportSchnittstelle : REFERENCE TO Eckuebergabe_Glastransport_FB; // Achse fuer die Signale an die Nachbarstationen

END_VAR


//==================================================================================================
// MASTER AUFRUFEN
//==================================================================================================
SUPER^(BasisStationsParameter := BasisStationsParameter);

//==================================================================================================
// DEAKTIVIEREN
//==================================================================================================
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  RETURN;
END_IF

//==================================================================================================
// AKTIONEN
//==================================================================================================
A_Aufrufe();

IO_Zuweisung();

SystemCheck();
Eintransport();
Vortransport();
Austransport();
Reset();
Handfunktionen();

A_Hubrahmen();
END_FUNCTION_BLOCK