<%@ Language=VBScript %>
<%Option Explicit%>
<!-- #include file='../../funcoes.asp' -->
<%
DIM rs, sessao, acao, Erro
DIM IdPreQuadroObservacoesCNH, Descricao, Chave, ChaveAntiga, ChaveGrafica, Tipo

Sub GravaCampos()
	Erro = false
	sessao = session("sessao")
	acao = Request.Form("oculto")

	IdPreQuadroObservacoesCNH = ChecaNulo(request.form("IdPreQuadroObservacoesCNH"))
	Chave = ChecaNulo(request.form("Chave"))
	ChaveAntiga = ChecaNulo(request.form("ChaveAntiga"))
	ChaveGrafica = ChecaNulo(request.form("ChaveGrafica"))
	Descricao = ChecaNulo(request.form("Descricao"))	
	Tipo = ChecaNulo(request.form("Tipo"))
End Sub

Sub Consulta()
	NovoCmmd(Sys_NomeStoredProcedure("C"))
	Cmmd.Parameters.Item("@IdSessao").value = Sessao
	Set rs = Cmmd.Execute()
	Set Cmmd = Nothing
End Sub

Sub Manutencao(acao)
	NovoCmmd(Sys_NomeStoredProcedure(acao))
	Cmmd.Parameters.Item("@IdSessao").value = Sessao
	Cmmd.Parameters.Item("@IdPreQuadroObservacoesCNH").value = IdPreQuadroObservacoesCNH
	Cmmd.Parameters.Item("@Chave").value = Chave
	Cmmd.Parameters.Item("@ChaveAntiga").value = ChaveAntiga
	Cmmd.Parameters.Item("@ChaveGrafica").value = ChaveGrafica
	Cmmd.Parameters.Item("@Descricao").value = Descricao
	Cmmd.Parameters.Item("@Tipo").value = Tipo
	On Error Resume Next
		Cmmd.Execute()
		If Err.number <> 0 Then
			session("texto") = "<div class='msgErro'>" &  Err.Description & "</div>"
		Else
			session("texto") = "<div class='msgOk'>Operação realizada com sucesso.</div>"
		End If
	On Error Goto 0
	Set Cmmd = Nothing
End Sub

'INICIO ------------------------
Call GravaCampos()

If acao = "I" or acao = "E" or acao = "A" Then
	Call Manutencao(acao)
End If
%>

<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge;chrome=1" />
<link href="../../../css/jquery-ui.min.css" rel="stylesheet" type="text/css">
<link href="../../../css/EstiloDetranNet-1.css" rel="stylesheet" type="text/css">
<script language="JavaScript" src="../../../js/jquery-1.11.2.min.js"></script>
<script language="JavaScript" src="../../../js/jquery-migrate-1.2.1.min.js"></script>
<script language="JavaScript" src="../../../js/jquery-ui.min.js"></script>
<script language="JavaScript" src="../../../js/funcoes.js"></script>
<script language="JavaScript">
function Seleciona(codigo, descricao, Chave, ChaveAntiga, ChaveGrafica, Tipo){
	form1.IdPreQuadroObservacoesCNH.value = codigo;
	form1.Descricao.value = descricao;
	form1.Chave.value = Chave;
	form1.ChaveAntiga.value = ChaveAntiga;
	form1.ChaveGrafica.value = ChaveGrafica;
	if (Tipo == 'A') 
		form1.Tipo[0].checked = true;
	else
		form1.Tipo[1].checked = true;
		
	hide('I');
	show('A');
	show('E');
}
</script>
</head>

<body onLoad="focusFirstField();">

<form method="POST" name="form1" id="form1">
	<!--#include file="../../botoes.asp"-->
	<input type="hidden" name="oculto" id="oculto">
	<input type="hidden" name="IdPreQuadroObservacoesCNH" id="IdPreQuadroObservacoesCNH" value="<%=IdPreQuadroObservacoesCNH%>">
	
<table class="form">
	<tr>
		<td>Chave Antiga:</td>
		<td><input type="text" name="ChaveAntiga" id="ChaveAntiga" size="3" maxlength="2" value="<%=ChaveAntiga%>"></td>
	</tr>
	<tr>
		<td>Chave:</td>
		<td><input type="text" name="Chave" id="Chave" size="3" maxlength="2" value="<%=Chave%>"></td>
	</tr>
	<tr>
		<td>Chave Gráfica:</td>
		<td><input type="text" name="ChaveGrafica" id="ChaveGrafica" size="3" maxlength="2" value="<%=ChaveGrafica%>"></td>
	</tr>
	<tr>
		<td>Descrição:</td>
		<td><input type="text" name="Descricao" id="Descricao" size="100" maxlength="200" value="<%=Descricao%>"></td>
	</tr>
	<tr>
		<td colspan="2">
			<input type="radio" value="A" name="Tipo" id="Tipo" <%=iif(Tipo = "A","checked","")%> class="semEstilo"> Ativo
			<input type="radio" value="P" name="Tipo" id="Tipo" <%=iif(Tipo = "P","checked","")%> class="semEstilo"> Passivo
		</td>
	</tr>
</table>

<table class="grid">
	<thead>
        <tr>
            <th>Chave Antiga</th>
            <th>Chave</th>
            <th>Chave Gráfica</th>
            <th>Descrição</th>
            <th>Tipo</th>
        </tr>
	</thead>
    <tbody>
		<%Call Consulta()%>
        <%if not (rs.bof and rs.eof) then%>
            <%do until rs.eof%>	
                <tr onClick="Seleciona('<%=rs("IdPreQuadroObservacoesCNH")%>','<%=rs("Descricao")%>','<%=rs("Chave")%>','<%=rs("ChaveAntiga")%>','<%=rs("ChaveGrafica")%>','<%=rs("Tipo")%>')">
                    <td><%=rs("ChaveAntiga")%>&nbsp;</td>
                    <td><%=rs("Chave")%>&nbsp;</td>
                    <td><%=rs("ChaveGrafica")%>&nbsp;</td>
                    <td><%=rs("Descricao")%>&nbsp;</td>
                    <td><%if Trim(rs("Tipo")) = "A" then%>Ativo<%else%>Passivo<%end if%>&nbsp;</td>
                </tr>
            <%rs.movenext : loop%>
        <%end if%>
	</tbody>
</table>
</form>
</body>
</html>
<script language="JavaScript">
$(function() {
	<%If Erro Then%>
		show('A');
		show('E');
	<%Else%>
		show('I');
	<%End If%>

});
</script>



