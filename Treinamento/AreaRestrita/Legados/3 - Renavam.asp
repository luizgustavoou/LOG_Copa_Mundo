<%@ Language=VBScript%>
<%Option Explicit %>
<!-- #include file='../../funcoes.asp' -->
<%


Dim idSessao, acao, desabilita
Dim Texto, TextoManutencao
Dim rs, achou
Dim varPlaca, varRenavam, varNovoRenavam, varDescricao, varMotivo

idsessao = Session("sessao")
acao = Request.Form("oculto")
varPlaca = ChecaNulo(Request.Form("txtPlaca"))
varRenavam = ChecaNulo(Request.Form("txtRenavam"))
varDescricao = ChecaNulo(Request.Form("ocultoDescricao"))
varNovoRenavam = ChecaNulo(Request.Form("txtNovoRenavam"))
varMotivo = ChecaNulo(Request.Form("cboMotivo"))

if isNull(varPlaca) then
	varPlaca = ChecaNulo(request.form("ocultoPlaca"))	
end if
if isNull(varRenavam) then
	varRenavam = ChecaNulo(request.form("ocultoRenavam"))	
end if


Function Consulta()
	NovoCmmd(Sys_NomeStoredProcedure(Acao))	
	
	Cmmd.Parameters("@idSessao").value = idSessao		
	Cmmd.Parameters("@Placa").value = iif(varPlaca="",NULL,varPlaca)
	Cmmd.Parameters("@Renavam").value = iif(varRenavam="",NULL,varRenavam)
	
	On Error Resume Next

	Set rs = Cmmd.Execute()

	If Err.Number <> 0 Then
		Consulta = "<div class='msgErro'>" &   err.Description & "</div>"
	End If

	On Error Goto 0
	
	Set Cmmd = Nothing

End Function

Function Manutencao()
	NovoCmmd(Sys_NomeStoredProcedure(Acao))
			
	Cmmd.Parameters("@idSessao").value = idSessao		
	Cmmd.Parameters("@Placa").value = iif(varPlaca="",NULL,varPlaca)
	Cmmd.Parameters("@Renavam").value = iif(varRenavam="",NULL,varRenavam)
	Cmmd.Parameters("@NovoRenavam").value = iif(varNovoRenavam="",NULL,varNovoRenavam)		
	Cmmd.Parameters("@MotivoCorrecao").value = iif(varMotivo="",NULL,varMotivo)		
		
	On Error Resume Next

	Cmmd.Execute()

	If Err.Number <> 0 Then
		Manutencao = "<div class='msgErro'>" & err.Description & "</div>"
	End If

	On Error Goto 0
	
	Set Cmmd = Nothing

End Function
	
'REALIZANDO ALTERAÇÕES NO BANCO
if acao <> "" and acao <> "C" then		
	TextoManutencao = Manutencao()			
	if TextoManutencao = "" then
		TextoManutencao = "<div class='msgOk'>Operação Realizada com Sucesso.</div>"		
		varRenavam = varNovoRenavam
		acao="C"
	else
		Texto = "<div class='msgErro'> " & TextoManutencao & "</div>"
		acao="C"
	end if
end if

if acao = "C" then
	Texto =	Consulta()	
	if Texto = "" then
		texto=TextoManutencao
		desabilita="disabled"
		achou=true			
		if not rs.eof then
			varDescricao =	rs("Descricao")						
		end if		
	else
		desabilita=""		
		achou = false
	end if
end if
%>
<%session("texto") = texto%>

<html>
<head>
<link href="../../../css/jquery-ui.min.css" rel="stylesheet" type="text/css">
<link href="../../../css/EstiloDetranNet-1.css" rel="stylesheet" type="text/css">
<script language="JavaScript" src="../../../js/jquery-1.11.2.min.js"></script>
<script language="JavaScript" src="../../../js/jquery-migrate-1.2.1.min.js"></script>
<script language="JavaScript" src="../../../js/jquery-ui.min.js"></script>
<script language="JavaScript" src="../../../js/funcoes.js"></script>
<script language="Javascript" src="../../entertab.js"></SCRIPT>
</head>

<body onLoad="focusFirstField();">
<form method="post" name="form1" id="form1">
<input type="hidden" name="oculto" id="oculto">	
<input type="hidden" value="<%=varPlaca%>" name="ocultoPlaca" id="ocultoPlaca">
<input type="hidden" value="<%=varRenavam%>" name="ocultoRenavam" id="ocultoRenavam">
<input type="hidden" value="<%=varDescricao%>" name="ocultoDescricao" id="ocultoDescricao">
<!--#include file="../../botoes.asp"-->
	
<table>
	<tr>
		<td> Placa :</td>
		<td>
		<input type="text" size="7" maxlength="7" class="box" name="txtPlaca" id="txtPlaca" value="<%=varPlaca%>" 				onKeyPress="maiusculo();" <% =desabilita %>><%=varDescricao%>
	  </td>
	</tr>
	<tr>
		<td> Renavam :</td>
		<td>
		<input type="text" size="12" maxlength="11" class="box" name="txtRenavam" id="txtRenavam" value="<%=varRenavam%>" 				onKeyPress="isnumeric();" <% =desabilita %>>				
	  </td>
	</tr>
</table>
<hr>
<%if achou then%>
	<table>
		<tr> 
			<td>Novo Renavam:</td>
			<td ><input type="text" size="12" maxlength="11" class="box" name="txtNovoRenavam" id="txtNovoRenavam" value="<%=varNovoRenavam%>" onKeyPress="isnumeric();"></td>
		</tr>	
		<tr> 
			<td>Motivo:</td>
			<td >
			<select name="cboMotivo" id="cboMotivo" size="1">
					<option value=""> Escolha um motivo  </option>
					<option <%= iif(varMotivo=1,"SELECTED","") %> value="1" >Código RENAVAM duplicado na BIN </option>
					<option <%= iif(varMotivo=2,"SELECTED","") %> value="2" >Código RENAVAM duplicado na Base Estadual </option>
				</select>
</td>
		</tr>		
	</table>
<%end if%>

</form>
</body>
</html>
<script language="javascript">
$(function() {
	<% Select Case Acao %>		
		<% Case "C" %>
				<% If achou=true Then %>
					show('A');					
				<% else %>
					show('C');					
				<% End If %>
		<% Case "" %>		
			show('C');			
		<% End Select %>
});

</script>



