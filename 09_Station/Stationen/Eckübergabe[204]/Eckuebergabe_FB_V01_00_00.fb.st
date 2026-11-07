(* METADATA
{
	"v3Meta": {
		"objectGuid": "ac996fe1-9bce-4d65-b8a5-db1a5457671f"
	}
}
*)
FUNCTION_BLOCK Eckuebergabe_FB_V01_00_00 EXTENDS Basic_Station_FB_V01_00_00

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
  blAktionImFehler         : BOOL; // Eine der wandweisen Aktionen steht im Fehler

  // ENUM
  elRiemenAchse        : Achsrichtung_EN; // Achse der Riemen im Hubrahmen (MK)
  elAchseEintransport  : Achsrichtung_EN; // Achse des aktuellen Eintransports (Auftrag)
  elAchseAustransport  : Achsrichtung_EN; // Achse fuer den Austransport (Schnittstellendaten)
  elAchseSchnittstelle : Achsrichtung_EN; // Achse, deren Signale an die Nachbarstationen gehen
  elHubrahmenZielAchse : Achsrichtung_EN; // Achse, auf die der Hubrahmen gestellt wird

  // BAUSTEINE
  Glastransport_X : Eckuebergabe_Glastransport_FB_V01_00_00;
  Glastransport_Y : Eckuebergabe_Glastransport_FB_V01_00_00;
  Hubrahmen       : ZylinderPneumatik_FB_V01_00_00; // Ausgefahren = oben, eingefahren = unten

  // AKTIONEN (WANDWEISE)
  Eintransport : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Eckuebergabe_Eintransport_FB_V01_00_00;
  Austransport : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Eckuebergabe_Austransport_FB_V01_00_00;
  Vortransport : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Eckuebergabe_Vortransport_FB_V01_00_00;

  // REFERENZEN
  GlastransportEin           : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00; // Achse des aktuellen Eintransports
  GlastransportAus           : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00; // Austransport-Achse
  GlastransportSchnittstelle : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00; // Achse fuer die Signale an die Nachbarstationen

END_VAR


//==================================================================================================
// MASTER AUFRUFEN
//==================================================================================================
SUPER^(BasisStationsParameter := BasisStationsParameter);

//==================================================================================================
// DEAKTIVIEREN
//==================================================================================================
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  HandfunktionenStatus();
  RETURN;
END_IF

//==================================================================================================
// AKTIONEN
//==================================================================================================
A_Aufrufe();

IO_Zuweisung();

SystemCheck();

(* Hinweis:
   - Automatik-Aktionen je Wand
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Eintransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         Glastransport          := GlastransportSchnittstelle,
                         bpHubrahmenInPosition  := blHubrahmenInPosition,
                         elAchseEintransport    := elAchseEintransport,
                         elAchseAustransport    := elAchseAustransport,
                         Glastransport_X        := Glastransport_X,
                         Glastransport_Y        := Glastransport_Y,
                         GlastransportEin       := GlastransportEin,
                         GlastransportAus       := GlastransportAus,
                         Hubrahmen              := Hubrahmen,
                         blHubrahmenPositionieren := blHubrahmenPositionieren,
                         elHubrahmenZielAchse     := elHubrahmenZielAchse );

  Vortransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         Glastransport          := GlastransportSchnittstelle,
                         bpHubrahmenInPosition  := blHubrahmenInPosition,
                         elAchseAustransport    := elAchseAustransport,
                         Glastransport_X        := Glastransport_X,
                         Glastransport_Y        := Glastransport_Y,
                         GlastransportAus       := GlastransportAus,
                         Hubrahmen              := Hubrahmen,
                         blHubrahmenPositionieren := blHubrahmenPositionieren,
                         elHubrahmenZielAchse     := elHubrahmenZielAchse );

  Austransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         Glastransport          := GlastransportSchnittstelle,
                         bpHubrahmenInPosition  := blHubrahmenInPosition,
                         elAchseAustransport    := elAchseAustransport,
                         Glastransport_X        := Glastransport_X,
                         Glastransport_Y        := Glastransport_Y,
                         GlastransportAus       := GlastransportAus,
                         Hubrahmen              := Hubrahmen,
                         blHubrahmenPositionieren := blHubrahmenPositionieren,
                         elHubrahmenZielAchse     := elHubrahmenZielAchse );
END_FOR

Reset();
Handfunktionen();

A_Hubrahmen();
END_FUNCTION_BLOCK