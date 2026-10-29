(* METADATA
{
	"v3Meta": {
		"objectGuid": "b9a8e540-c1e2-4ab9-ae26-0ecea7304ebf"
	}
}
*)
PROGRAM UpdateIoAnzeige
VAR
END_VAR

;

(*

(* +CAB2-490A03 - DI16 *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[0] := %IB1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[1] := %IB2;

(* +CAB2-490A04 - DI16 *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[2] := %IB4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[3] := %IB5;

(* +CAB2-490A06 - DI16 *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[4] := %IB7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[5] := %IB8;

(* +SH101-490A04 - DI16 *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[6] := %IB60;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[7] := %IB61;

(* +SH101-490A05 - DI16 *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[8] := %IB63;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[9] := %IB64;


(* +CAB2-490A07 - DO16 *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucOutput[0] := %QB1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucOutput[1] := %QB2;

(* +CAB2-490A09 - DO16 *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucOutput[2] := %QB3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucOutput[3] := %QB4;

(* +SH101-490A07 - DO16 *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucOutput[4] := %QB70;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucOutput[5] := %QB71;


(* +CA2010-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[10].0 := pgAntriebe[6].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[10].1 := pgAntriebe[6].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[10].2 := pgAntriebe[6].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[10].3 := pgAntriebe[6].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[10].4 := pgAntriebe[6].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[10].5 := pgAntriebe[6].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[10].6 := pgAntriebe[6].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[10].7 := pgAntriebe[6].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[11].0 := pgAntriebe[6].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[11].1 := pgAntriebe[6].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[11].2 := pgAntriebe[6].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[11].3 := pgAntriebe[6].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[11].4 := pgAntriebe[6].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[11].5 := pgAntriebe[6].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[11].6 := pgAntriebe[6].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[11].7 := pgAntriebe[6].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[12].0 := pgAntriebe[6].wpAusgaengeUmrichter.cXG37_13;

(* +CA2020-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[14].0 := pgAntriebe[4].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[14].1 := pgAntriebe[4].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[14].2 := pgAntriebe[4].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[14].3 := pgAntriebe[4].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[14].4 := pgAntriebe[4].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[14].5 := pgAntriebe[4].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[14].6 := pgAntriebe[4].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[14].7 := pgAntriebe[4].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[15].0 := pgAntriebe[4].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[15].1 := pgAntriebe[4].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[15].2 := pgAntriebe[4].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[15].3 := pgAntriebe[4].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[15].4 := pgAntriebe[4].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[15].5 := pgAntriebe[4].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[15].6 := pgAntriebe[4].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[15].7 := pgAntriebe[4].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[16].0 := pgAntriebe[4].wpAusgaengeUmrichter.cXG37_13;

(* +CA2022-100U02 - Tilting *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[18].0 := pgAntriebe[5].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[18].1 := pgAntriebe[5].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[18].2 := pgAntriebe[5].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[18].3 := pgAntriebe[5].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[18].4 := pgAntriebe[5].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[18].5 := pgAntriebe[5].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[18].6 := pgAntriebe[5].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[18].7 := pgAntriebe[5].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[19].0 := pgAntriebe[5].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[19].1 := pgAntriebe[5].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[19].2 := pgAntriebe[5].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[19].3 := pgAntriebe[5].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[19].4 := pgAntriebe[5].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[19].5 := pgAntriebe[5].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[19].6 := pgAntriebe[5].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[19].7 := pgAntriebe[5].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[20].0 := pgAntriebe[5].wpAusgaengeUmrichter.cXG37_13;

(* +CA2030-100U02 - Rolls *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[22].0 := pgAntriebe[1].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[22].1 := pgAntriebe[1].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[22].2 := pgAntriebe[1].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[22].3 := pgAntriebe[1].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[22].4 := pgAntriebe[1].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[22].5 := pgAntriebe[1].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[22].6 := pgAntriebe[1].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[22].7 := pgAntriebe[1].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[23].0 := pgAntriebe[1].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[23].1 := pgAntriebe[1].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[23].2 := pgAntriebe[1].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[23].3 := pgAntriebe[1].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[23].4 := pgAntriebe[1].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[23].5 := pgAntriebe[1].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[23].6 := pgAntriebe[1].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[23].7 := pgAntriebe[1].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[24].0 := pgAntriebe[1].wpAusgaengeUmrichter.cXG37_13;

(* +CA2031-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[26].0 := pgAntriebe[2].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[26].1 := pgAntriebe[2].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[26].2 := pgAntriebe[2].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[26].3 := pgAntriebe[2].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[26].4 := pgAntriebe[2].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[26].5 := pgAntriebe[2].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[26].6 := pgAntriebe[2].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[26].7 := pgAntriebe[2].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[27].0 := pgAntriebe[2].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[27].1 := pgAntriebe[2].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[27].2 := pgAntriebe[2].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[27].3 := pgAntriebe[2].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[27].4 := pgAntriebe[2].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[27].5 := pgAntriebe[2].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[27].6 := pgAntriebe[2].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[27].7 := pgAntriebe[2].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[28].0 := pgAntriebe[2].wpAusgaengeUmrichter.cXG37_13;

(* +CA2040-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[30].0 := pgAntriebe[0].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[30].1 := pgAntriebe[0].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[30].2 := pgAntriebe[0].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[30].3 := pgAntriebe[0].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[30].4 := pgAntriebe[0].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[30].5 := pgAntriebe[0].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[30].6 := pgAntriebe[0].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[30].7 := pgAntriebe[0].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[31].0 := pgAntriebe[0].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[31].1 := pgAntriebe[0].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[31].2 := pgAntriebe[0].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[31].3 := pgAntriebe[0].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[31].4 := pgAntriebe[0].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[31].5 := pgAntriebe[0].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[31].6 := pgAntriebe[0].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[31].7 := pgAntriebe[0].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[32].0 := pgAntriebe[0].wpAusgaengeUmrichter.cXG37_13;

(* +CA2050-100U02 - Lateral movement *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[34].0 := pgAntriebe[7].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[34].1 := pgAntriebe[7].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[34].2 := pgAntriebe[7].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[34].3 := pgAntriebe[7].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[34].4 := pgAntriebe[7].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[34].5 := pgAntriebe[7].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[34].6 := pgAntriebe[7].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[34].7 := pgAntriebe[7].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[35].0 := pgAntriebe[7].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[35].1 := pgAntriebe[7].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[35].2 := pgAntriebe[7].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[35].3 := pgAntriebe[7].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[35].4 := pgAntriebe[7].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[35].5 := pgAntriebe[7].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[35].6 := pgAntriebe[7].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[35].7 := pgAntriebe[7].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[36].0 := pgAntriebe[7].wpAusgaengeUmrichter.cXG37_13;

(* +CA2051-100U02 - Lifting *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[38].0 := pgAntriebe[8].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[38].1 := pgAntriebe[8].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[38].2 := pgAntriebe[8].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[38].3 := pgAntriebe[8].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[38].4 := pgAntriebe[8].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[38].5 := pgAntriebe[8].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[38].6 := pgAntriebe[8].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[38].7 := pgAntriebe[8].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[39].0 := pgAntriebe[8].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[39].1 := pgAntriebe[8].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[39].2 := pgAntriebe[8].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[39].3 := pgAntriebe[8].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[39].4 := pgAntriebe[8].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[39].5 := pgAntriebe[8].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[39].6 := pgAntriebe[8].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[39].7 := pgAntriebe[8].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[40].0 := pgAntriebe[8].wpAusgaengeUmrichter.cXG37_13;

(* +CA2052-100U02 - Turning *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[42].0 := pgAntriebe[9].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[42].1 := pgAntriebe[9].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[42].2 := pgAntriebe[9].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[42].3 := pgAntriebe[9].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[42].4 := pgAntriebe[9].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[42].5 := pgAntriebe[9].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[42].6 := pgAntriebe[9].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[42].7 := pgAntriebe[9].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[43].0 := pgAntriebe[9].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[43].1 := pgAntriebe[9].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[43].2 := pgAntriebe[9].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[43].3 := pgAntriebe[9].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[43].4 := pgAntriebe[9].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[43].5 := pgAntriebe[9].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[43].6 := pgAntriebe[9].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[43].7 := pgAntriebe[9].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[44].0 := pgAntriebe[9].wpAusgaengeUmrichter.cXG37_13;

(* +CA2060-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[46].0 := pgAntriebe[3].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[46].1 := pgAntriebe[3].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[46].2 := pgAntriebe[3].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[46].3 := pgAntriebe[3].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[46].4 := pgAntriebe[3].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[46].5 := pgAntriebe[3].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[46].6 := pgAntriebe[3].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[46].7 := pgAntriebe[3].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[47].0 := pgAntriebe[3].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[47].1 := pgAntriebe[3].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[47].2 := pgAntriebe[3].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[47].3 := pgAntriebe[3].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[47].4 := pgAntriebe[3].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[47].5 := pgAntriebe[3].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[47].6 := pgAntriebe[3].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[47].7 := pgAntriebe[3].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[48].0 := pgAntriebe[3].wpAusgaengeUmrichter.cXG37_13;

(* +CA2070-100U02 - Lateral movement *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[50].0 := pgAntriebe[17].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[50].1 := pgAntriebe[17].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[50].2 := pgAntriebe[17].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[50].3 := pgAntriebe[17].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[50].4 := pgAntriebe[17].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[50].5 := pgAntriebe[17].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[50].6 := pgAntriebe[17].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[50].7 := pgAntriebe[17].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[51].0 := pgAntriebe[17].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[51].1 := pgAntriebe[17].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[51].2 := pgAntriebe[17].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[51].3 := pgAntriebe[17].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[51].4 := pgAntriebe[17].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[51].5 := pgAntriebe[17].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[51].6 := pgAntriebe[17].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[51].7 := pgAntriebe[17].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[52].0 := pgAntriebe[17].wpAusgaengeUmrichter.cXG37_13;

(* +CA2071-100U02 - Lifting *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[54].0 := pgAntriebe[18].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[54].1 := pgAntriebe[18].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[54].2 := pgAntriebe[18].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[54].3 := pgAntriebe[18].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[54].4 := pgAntriebe[18].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[54].5 := pgAntriebe[18].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[54].6 := pgAntriebe[18].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[54].7 := pgAntriebe[18].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[55].0 := pgAntriebe[18].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[55].1 := pgAntriebe[18].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[55].2 := pgAntriebe[18].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[55].3 := pgAntriebe[18].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[55].4 := pgAntriebe[18].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[55].5 := pgAntriebe[18].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[55].6 := pgAntriebe[18].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[55].7 := pgAntriebe[18].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[56].0 := pgAntriebe[18].wpAusgaengeUmrichter.cXG37_13;

(* +CA2072-100U02 - Turning *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[58].0 := pgAntriebe[19].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[58].1 := pgAntriebe[19].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[58].2 := pgAntriebe[19].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[58].3 := pgAntriebe[19].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[58].4 := pgAntriebe[19].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[58].5 := pgAntriebe[19].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[58].6 := pgAntriebe[19].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[58].7 := pgAntriebe[19].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[59].0 := pgAntriebe[19].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[59].1 := pgAntriebe[19].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[59].2 := pgAntriebe[19].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[59].3 := pgAntriebe[19].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[59].4 := pgAntriebe[19].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[59].5 := pgAntriebe[19].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[59].6 := pgAntriebe[19].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[59].7 := pgAntriebe[19].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[60].0 := pgAntriebe[19].wpAusgaengeUmrichter.cXG37_13;

(* +CA2080-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[62].0 := pgAntriebe[10].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[62].1 := pgAntriebe[10].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[62].2 := pgAntriebe[10].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[62].3 := pgAntriebe[10].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[62].4 := pgAntriebe[10].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[62].5 := pgAntriebe[10].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[62].6 := pgAntriebe[10].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[62].7 := pgAntriebe[10].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[63].0 := pgAntriebe[10].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[63].1 := pgAntriebe[10].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[63].2 := pgAntriebe[10].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[63].3 := pgAntriebe[10].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[63].4 := pgAntriebe[10].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[63].5 := pgAntriebe[10].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[63].6 := pgAntriebe[10].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[63].7 := pgAntriebe[10].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[64].0 := pgAntriebe[10].wpAusgaengeUmrichter.cXG37_13;

(* +CA2090-100U02 - Rolls *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[66].0 := pgAntriebe[11].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[66].1 := pgAntriebe[11].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[66].2 := pgAntriebe[11].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[66].3 := pgAntriebe[11].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[66].4 := pgAntriebe[11].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[66].5 := pgAntriebe[11].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[66].6 := pgAntriebe[11].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[66].7 := pgAntriebe[11].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[67].0 := pgAntriebe[11].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[67].1 := pgAntriebe[11].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[67].2 := pgAntriebe[11].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[67].3 := pgAntriebe[11].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[67].4 := pgAntriebe[11].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[67].5 := pgAntriebe[11].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[67].6 := pgAntriebe[11].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[67].7 := pgAntriebe[11].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[68].0 := pgAntriebe[11].wpAusgaengeUmrichter.cXG37_13;

(* +CA2091-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[70].0 := pgAntriebe[12].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[70].1 := pgAntriebe[12].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[70].2 := pgAntriebe[12].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[70].3 := pgAntriebe[12].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[70].4 := pgAntriebe[12].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[70].5 := pgAntriebe[12].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[70].6 := pgAntriebe[12].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[70].7 := pgAntriebe[12].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[71].0 := pgAntriebe[12].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[71].1 := pgAntriebe[12].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[71].2 := pgAntriebe[12].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[71].3 := pgAntriebe[12].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[71].4 := pgAntriebe[12].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[71].5 := pgAntriebe[12].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[71].6 := pgAntriebe[12].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[71].7 := pgAntriebe[12].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[72].0 := pgAntriebe[12].wpAusgaengeUmrichter.cXG37_13;

(* +CA2100-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[74].0 := pgAntriebe[13].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[74].1 := pgAntriebe[13].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[74].2 := pgAntriebe[13].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[74].3 := pgAntriebe[13].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[74].4 := pgAntriebe[13].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[74].5 := pgAntriebe[13].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[74].6 := pgAntriebe[13].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[74].7 := pgAntriebe[13].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[75].0 := pgAntriebe[13].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[75].1 := pgAntriebe[13].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[75].2 := pgAntriebe[13].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[75].3 := pgAntriebe[13].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[75].4 := pgAntriebe[13].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[75].5 := pgAntriebe[13].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[75].6 := pgAntriebe[13].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[75].7 := pgAntriebe[13].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[76].0 := pgAntriebe[13].wpAusgaengeUmrichter.cXG37_13;

(* +CA2102-100U02 - Tilting *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[78].0 := pgAntriebe[14].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[78].1 := pgAntriebe[14].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[78].2 := pgAntriebe[14].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[78].3 := pgAntriebe[14].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[78].4 := pgAntriebe[14].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[78].5 := pgAntriebe[14].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[78].6 := pgAntriebe[14].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[78].7 := pgAntriebe[14].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[79].0 := pgAntriebe[14].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[79].1 := pgAntriebe[14].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[79].2 := pgAntriebe[14].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[79].3 := pgAntriebe[14].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[79].4 := pgAntriebe[14].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[79].5 := pgAntriebe[14].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[79].6 := pgAntriebe[14].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[79].7 := pgAntriebe[14].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[80].0 := pgAntriebe[14].wpAusgaengeUmrichter.cXG37_13;

(* +CA2110-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[82].0 := pgAntriebe[15].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[82].1 := pgAntriebe[15].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[82].2 := pgAntriebe[15].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[82].3 := pgAntriebe[15].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[82].4 := pgAntriebe[15].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[82].5 := pgAntriebe[15].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[82].6 := pgAntriebe[15].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[82].7 := pgAntriebe[15].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[83].0 := pgAntriebe[15].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[83].1 := pgAntriebe[15].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[83].2 := pgAntriebe[15].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[83].3 := pgAntriebe[15].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[83].4 := pgAntriebe[15].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[83].5 := pgAntriebe[15].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[83].6 := pgAntriebe[15].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[83].7 := pgAntriebe[15].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[84].0 := pgAntriebe[15].wpAusgaengeUmrichter.cXG37_13;

(* +CA2120-100U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[86].0 := pgAntriebe[16].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[86].1 := pgAntriebe[16].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[86].2 := pgAntriebe[16].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[86].3 := pgAntriebe[16].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[86].4 := pgAntriebe[16].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[86].5 := pgAntriebe[16].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[86].6 := pgAntriebe[16].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[86].7 := pgAntriebe[16].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[87].0 := pgAntriebe[16].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[87].1 := pgAntriebe[16].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[87].2 := pgAntriebe[16].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[87].3 := pgAntriebe[16].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[87].4 := pgAntriebe[16].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[87].5 := pgAntriebe[16].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[87].6 := pgAntriebe[16].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[87].7 := pgAntriebe[16].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[88].0 := pgAntriebe[16].wpAusgaengeUmrichter.cXG37_13;

(* +CA2061-100U02 - Lifting *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[90].0 := pgAntriebe[23].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[90].1 := pgAntriebe[23].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[90].2 := pgAntriebe[23].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[90].3 := pgAntriebe[23].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[90].4 := pgAntriebe[23].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[90].5 := pgAntriebe[23].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[90].6 := pgAntriebe[23].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[90].7 := pgAntriebe[23].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[91].0 := pgAntriebe[23].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[91].1 := pgAntriebe[23].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[91].2 := pgAntriebe[23].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[91].3 := pgAntriebe[23].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[91].4 := pgAntriebe[23].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[91].5 := pgAntriebe[23].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[91].6 := pgAntriebe[23].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[91].7 := pgAntriebe[23].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[92].0 := pgAntriebe[23].wpAusgaengeUmrichter.cXG37_13;

(* +SH101-60U02 - Lateral movement *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[94].0 := pgAntriebe[20].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[94].1 := pgAntriebe[20].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[94].2 := pgAntriebe[20].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[94].3 := pgAntriebe[20].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[94].4 := pgAntriebe[20].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[94].5 := pgAntriebe[20].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[94].6 := pgAntriebe[20].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[94].7 := pgAntriebe[20].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[95].0 := pgAntriebe[20].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[95].1 := pgAntriebe[20].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[95].2 := pgAntriebe[20].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[95].3 := pgAntriebe[20].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[95].4 := pgAntriebe[20].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[95].5 := pgAntriebe[20].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[95].6 := pgAntriebe[20].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[95].7 := pgAntriebe[20].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[96].0 := pgAntriebe[20].wpAusgaengeUmrichter.cXG37_13;

(* +SH101-70U02 - Lifting *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[98].0  := pgAntriebe[21].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[98].1  := pgAntriebe[21].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[98].2  := pgAntriebe[21].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[98].3  := pgAntriebe[21].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[98].4  := pgAntriebe[21].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[98].5  := pgAntriebe[21].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[98].6  := pgAntriebe[21].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[98].7  := pgAntriebe[21].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[99].0  := pgAntriebe[21].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[99].1  := pgAntriebe[21].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[99].2  := pgAntriebe[21].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[99].3  := pgAntriebe[21].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[99].4  := pgAntriebe[21].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[99].5  := pgAntriebe[21].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[99].6  := pgAntriebe[21].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[99].7  := pgAntriebe[21].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[100].0 := pgAntriebe[21].wpAusgaengeUmrichter.cXG37_13;

(* +SH101-75U02 - Belts *)
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[102].0 := pgAntriebe[22].udipEingaengeUmrichter.cXG31_1_I_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[102].1 := pgAntriebe[22].udipEingaengeUmrichter.cXG31_2_I_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[102].2 := pgAntriebe[22].udipEingaengeUmrichter.cXG31_3_I_3;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[102].3 := pgAntriebe[22].udipEingaengeUmrichter.cXG31_6_I_4;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[102].4 := pgAntriebe[22].udipEingaengeUmrichter.cXG31_7_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[102].5 := pgAntriebe[22].udipEingaengeUmrichter.cXG37_1_IO_1;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[102].6 := pgAntriebe[22].udipEingaengeUmrichter.cXG37_2_IO_2;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[102].7 := pgAntriebe[22].udipEingaengeUmrichter.cXG37_3_I_5;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[103].0 := pgAntriebe[22].udipEingaengeUmrichter.cXG37_4_I_6;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[103].1 := pgAntriebe[22].udipEingaengeUmrichter.cXG37_5_I_7;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[103].2 := pgAntriebe[22].udipEingaengeUmrichter.cXG37_6_I_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[103].3 := pgAntriebe[22].wpAusgaengeUmrichter.cXG37_8;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[103].4 := pgAntriebe[22].wpAusgaengeUmrichter.cXG37_9;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[103].5 := pgAntriebe[22].wpAusgaengeUmrichter.cXG37_10;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[103].6 := pgAntriebe[22].wpAusgaengeUmrichter.cXG37_11;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[103].7 := pgAntriebe[22].wpAusgaengeUmrichter.cXG37_12;
TCPMain.l_fb_SortjetHMI.SpsToMmi.ioSystem.aucInput[104].0 := pgAntriebe[22].wpAusgaengeUmrichter.cXG37_13;

*)
END_PROGRAM