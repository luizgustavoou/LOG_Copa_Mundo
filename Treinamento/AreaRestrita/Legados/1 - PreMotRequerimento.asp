<%@ Language=VBScript %>
<%Option Explicit%>
<!-- #include file='../../funcoes.asp' -->
<%
DIM rs, sessao, acao, Erro
DIM IdPreMotivoRequerimento,Descricao,Chave

Sub GravaCampos()
	Erro = false
	sessao = session("sessao")
	acao = Request.Form("oculto")

	IdPreMotivoRequerimento = ChecaNulo(request.form("IdPreMotivoRequerimento"))
	Chave = ChecaNulo(request.form("Chave"))	
	Descricao = ChecaNulo(request.form("Descricao"))	
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
	Cmmd.Parameters.Item("@IdPreMotivoRequerimento").value = IdPreMotivoRequerimento
	Cmmd.Parameters.Item("@Descricao").value = Descricao
	Cmmd.Parameters.Item("@Chave").value = Chave	
	On Error Resume Next
		Cmmd.Execute()
		If Err.number <> 0 Then
			Erro = iif(acao <> "I", true, false)
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
function Seleciona(codigo,descricao,Chave){
	form1.IdPreMotivoRequerimento.value = codigo;
	form1.Descricao.value = descricao;
	form1.Chave.readOnly = true;		
	form1.Chave.value = Chave;
	
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
	<input type="hidden" name="IdPreMotivoRequerimento" id="IdPreMotivoRequerimento" value="<%=IdPreMotivoRequerimento%>">
	
<table class="form">
	<tr>
		<td>Chave:</td>
		<td><input type="text" name="Chave" id="Chave" size="3" maxlength="1" value="<%=Chave%>" <%=iif(Erro,"readonly","")%>></td>
	</tr>
	<tr>
		<td>Descrição:</td>
		<td><input type="text" name="Descricao" id="Descricao" size="100" maxlength="60" value="<%=Descricao%>"></td>
	</tr>
</table>

<table class="grid">
	<thead>
        <tr>
            <th>Chave</th>			
            <th>Descrição</th>
        </tr>
	</thead>
    <tbody>
		<%Call Consulta()%>
        <%if not (rs.bof and rs.eof) then%>
            <%do until rs.eof%>
            <tr onClick="Seleciona('<%=rs("IdPreMotivoRequerimento")%>','<%=rs("Descricao")%>','<%=rs("Chave")%>')">
                <td><%=rs("Chave")%></td>				
                <td><%=rs("Descricao")%></td>
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



