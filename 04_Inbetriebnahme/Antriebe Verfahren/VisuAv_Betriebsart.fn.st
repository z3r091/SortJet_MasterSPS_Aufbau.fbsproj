(* METADATA
{
	"v3Meta": {
		"objectGuid": "3da3337f-c48b-4234-bea1-9469bc68832b"
	}
}
*)
FUNCTION VisuAv_Betriebsart : STRING(30)
VAR_INPUT
  eBetriebsart : AntriebsBetriebsart_EN;
END_VAR
// Klartext der Betriebsart fuer die Visu "Antriebe_Verfahren"
CASE eBetriebsart OF
  AntriebsBetriebsart_EN.KEINE_FUNKTION:               VisuAv_Betriebsart := 'keine';
  AntriebsBetriebsart_EN.RESET:                        VisuAv_Betriebsart := 'Reset';
  AntriebsBetriebsart_EN.REFERENZ:                     VisuAv_Betriebsart := 'Referenz';
  AntriebsBetriebsart_EN.HANDPLUS:                     VisuAv_Betriebsart := 'Hand +';
  AntriebsBetriebsart_EN.HANDMINUS:                    VisuAv_Betriebsart := 'Hand -';
  AntriebsBetriebsart_EN.ABSOLUT:                      VisuAv_Betriebsart := 'Absolut';
  AntriebsBetriebsart_EN.RELATIV:                      VisuAv_Betriebsart := 'Relativ';
  AntriebsBetriebsart_EN.RESTWEG:                      VisuAv_Betriebsart := 'Restweg';
  AntriebsBetriebsart_EN.SYNC_AUF_MASTER:              VisuAv_Betriebsart := 'Sync auf Master';
  AntriebsBetriebsart_EN.INVERTIERTER_SYNC_AUF_MASTER: VisuAv_Betriebsart := 'Sync invertiert';
  AntriebsBetriebsart_EN.SCHEIBENMESSUNG:              VisuAv_Betriebsart := 'Scheibenmessung';
  AntriebsBetriebsart_EN.BREMSE_LOESEN:                VisuAv_Betriebsart := 'Bremse loesen';
  AntriebsBetriebsart_EN.ABSOLUT_SETZEN:               VisuAv_Betriebsart := 'Absolut setzen';
ELSE
  VisuAv_Betriebsart := CONCAT( 'unbekannt ', WORD_TO_STRING( eBetriebsart ) );
END_CASE
END_FUNCTION