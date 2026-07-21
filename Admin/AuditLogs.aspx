<%@ Page Title="Audit Logs" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="AuditLogs.aspx.cs"
    Inherits="CloudPhoria.Admin.AuditLogs" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="cp-page-header">
    <h2>&#x1F4CB; Audit Logs</h2>
    <p>Track every administrative action taken on the platform for accountability and monitoring.</p>
</div>

<div class="ad-inline-form cp-mb-md" style="display:flex;gap:8px;">
    <asp:TextBox ID="txtSearch" runat="server" CssClass="cp-input" placeholder="Search by action type..." style="max-width:280px;" />
    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="cp-btn cp-btn-outline" OnClick="btnSearch_Click" />
</div>

<div class="cp-table-wrap">
    <table class="cp-table">
        <thead><tr><th>Performed By</th><th>Action</th><th>Target</th><th>Details</th><th>When</th></tr></thead>
        <tbody>
            <asp:Repeater ID="rptAuditLog" runat="server">
                <ItemTemplate>
                    <tr>
                        <td><%# HttpUtility.HtmlEncode(Eval("PerformedByName").ToString()) %></td>
                        <td><span class="cp-badge cp-badge-indigo"><%# HttpUtility.HtmlEncode(Eval("ActionType").ToString()) %></span></td>
                        <td style="font-size:12px;color:var(--cp-text-muted);">
                            <%# Eval("TargetTable") != DBNull.Value ? HttpUtility.HtmlEncode(Eval("TargetTable").ToString()) + (Eval("TargetID") != DBNull.Value ? " #" + Eval("TargetID") : "") : "-" %>
                        </td>
                        <td style="font-size:12px;color:var(--cp-text-muted);">
                            <%# Eval("Details") != DBNull.Value ? HttpUtility.HtmlEncode(Eval("Details").ToString()) : "-" %>
                        </td>
                        <td style="font-size:12px;color:var(--cp-text-muted);">
                            <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>
</div>

<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="cp-empty-state">
        <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4CB;</span>
        <h3>No matching log entries</h3>
    </div>
</asp:Panel>

</asp:Content>
