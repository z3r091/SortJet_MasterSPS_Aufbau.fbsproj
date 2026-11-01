(* METADATA
{
  "v3Meta": {
    "objectGuid": "0ae12948-d7ff-42ab-9726-6ee7adeb2905"
  }
}
*)
{attribute 'excludefrombuild'}
FUNCTION VisuText : STRING
VAR_INPUT
  wpMmiNummer : WORD;
  wAuftragsnr : WORD;
END_VAR
VAR
  str : STRING;
END_VAR
VisuText := '!!! FEHLER !!!';

IF ( wAuftragsnr = eStation_Kein_Auftrag ) THEN

  VisuText := 'Kein Auftrag';

END_IF

IF wpMmiNummer < 200 THEN

  CASE wAuftragsnr OF

    eStation_Eintransport:
      VisuText := 'Eintransport';

    eStation_Austransport:
      VisuText := 'Austransport';

    eStation_Vortransport:
      VisuText := 'Vortransport';

    eStation_Durchtransport:
      VisuText := 'Durchtransport';

    eStation_Positionierung:
      VisuText := 'Positionierung';

    eStation_Grundstellung:
      VisuText := 'Grundstellung';

    eStation_Vorabpositionierung:
      VisuText := 'Vorab-Positionierung';

  END_CASE

ELSE

  CASE wAuftragsnr OF

    eStation_Eintransport:
      VisuText := 'Eintransport';

    eStation_Austransport:
      VisuText := 'Austransport';

    eStation_Messkopplung:
      VisuText := 'Messkopplung';

    eStation_Warte_Auf_Austransport:
      VisuText := 'Warte auf Austransport';

    eStation_Warte_Auf_Eintransport:
      VisuText := 'Warte auf Eintransport';

    eStation_Belegt:
      VisuText := 'Belegt';

    eStation_Transportkopplung:
      VisuText := 'Transportkopplung';

    eStation_Ausrichten:
      VisuText := 'Ausrichten';

    eStation_Anlegen:
      VisuText := 'Anlegen';

    eStation_GlasZurueck:
      VisuText := 'Glas zurück';

    eStation_Auswertung_Glasfehlmessung:
      VisuText := 'Ausw. Glasfehlmessung';

    eStation_Messfahrt:
      VisuText := 'Messfahrt';

    eStation_Einschleusen:
      VisuText := 'Einschleusen';

    eStation_Vortransport:
      VisuText := 'Vortransport';

    eStation_Kopplung_Nach_SystemCheck_Erneuern:
      VisuText := 'Kopplung nach Check neu';

    eStation_Durchtransport:
      VisuText := 'Glas durchtransport';

    eStation_Abnehmen:
      VisuText := 'Glas abnehmen';

    eStation_GlasSuchfahrt:
      VisuText := 'Glas suchen';

    eStation_GlasBereit:
      VisuText := 'Glas bereit';

    eStation_Intern_Glaseintransport_DefaultGlas:
      VisuText := 'Int. Eintransport MinGlas';

    eStation_Intern_Glaseintransport_GrossesGlas:
      VisuText := 'Int. Eintransport MaxGlas';

    eStation_Warte_Auf_Transportkopplung:
      VisuText := 'Warte auf Transportkopplung';

    eStation_Intern_Kopplung_Nach_SystemCheck:
      VisuText := 'Int. Kopplung Nach Check';

    eStation_Vorabpositionierung:
      VisuText := 'Vorab-Positionierung';

  END_CASE

END_IF
END_FUNCTION