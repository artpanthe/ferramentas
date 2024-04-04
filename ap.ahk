#Include <_JXON>

URL_API := "http://192.168.0.199:5001"
msgCopy1 := "RCA origem de venda"
msgCopy2 := "Autorizado Frank"

^+1::
{
	Send(msgCopy1)
	return
}

^+2::
{
	Send(msgCopy2)
	return
}

; Terminal Windows
^!T:: {
	Run "wt"
}


^y::
{

	A_Clipboard := ""
	Send('^c')
	Errorlevel := !ClipWait()
	txtCopied := A_Clipboard

	strNumbers := ExtractNumbers(txtCopied)

	if (StrLen(strNumbers) = 7) {
		TextoFormatado := SubStr(strNumbers, 1, 4) . "-" . SubStr(strNumbers, 5, 1) . "/" . SubStr(strNumbers, 6)		
		
		A_Clipboard := TextoFormatado
		Send("^v")

		urlCnae := URL_API . "/cnae/" . strNumbers

		whr := ComObject("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", urlCnae, true)
		whr.Send()
		whr.WaitForResponse()
		responseDB := whr.ResponseText

		if (StrLen(responseDB) > 0) {
			objResponse := jxon_load(&responseDB)
			atividade := objResponse["atividade"]

			MsgBox(atividade, "Código atividade")
		} else {
			MsgBox "Erro"
		}
	}
}

ExtractNumbers(text) {
	result := ""

	if (RegExMatch(text, "(\d+)", &numbers)) {
		result := numbers[1]
	}

	return result
}