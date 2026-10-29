(* METADATA
{
	"v3Meta": {
		"objectGuid": "ee188bc7-676d-468b-af81-8afc58a85f62"
	}
}
*)
ACTION Flasher
Flasher02(ENABLE:= TRUE , TIMELOW:= T#0.2S, TIMEHIGH:= T#0.2S , OUT=> gbFlashbit02sec);
Flasher03(ENABLE:= TRUE , TIMELOW:= t#0.3s, TIMEHIGH:= t#0.3s , OUT=> gbFlashbit03sec);
Flasher05(ENABLE:= TRUE , TIMELOW:= t#0.5s, TIMEHIGH:= t#0.5s , OUT=> gbFlashbit05sec);
Flasher10(ENABLE:= TRUE , TIMELOW:= T#0.5S, TIMEHIGH:= T#1.0S , OUT=> gbFlashbit1sec);
Flasher12(ENABLE:= TRUE , TIMELOW:= t#1.2s, TIMEHIGH:= t#1.8s , OUT=> gbFlashbit12sec);
END_ACTION