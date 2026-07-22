<%@ Page Title="Audit Logs" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="AuditLogs.aspx.cs"
    Inherits="CloudPhoria.Admin.AuditLogs" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<<<<<<< HEAD
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F4CB; Audit Logs</h2>
                <p>Full history of administrative and security-sensitive actions on the platform.</p>
            </div>
        </div>
    </div>

    <%-- Filter bar --%>
    <div class="cp-card cp-mb-md">
        <div style="display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap;">
            <div style="flex:1;min-width:160px;">
                <label class="cp-label">Search Action / Admin</label>
                <div class="cp-search-wrap">
                    <span class="cp-search-icon" aria-hidden="true">&#x1F50D;</span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="cp-input"
                        placeholder="Action type or admin name…" MaxLength="100" />
                </div>
            </div>
            <div style="min-width:150px;">
                <label class="cp-label">Target Table</label>
                <asp:DropDownList ID="ddlTable" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="">All Tables</asp:ListItem>
                    <asp:ListItem Value="Users">Users</asp:ListItem>
                    <asp:ListItem Value="Instructors">Instructors</asp:ListItem>
                    <asp:ListItem Value="Modules">Modules</asp:ListItem>
                    <asp:ListItem Value="FunRooms">FunRooms</asp:ListItem>
                    <asp:ListItem Value="BossFightRooms">BossFightRooms</asp:ListItem>
                    <asp:ListItem Value="Challenges">Challenges</asp:ListItem>
                    <asp:ListItem Value="Reports">Reports</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div>
                <asp:Button ID="btnSearch" runat="server" Text="Search"
                    CssClass="cp-btn cp-btn-primary" OnClick="btnSearch_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear"
                    CssClass="cp-btn cp-btn-ghost" style="margin-left:6px;"
                    OnClick="btnClear_Click" />
            </div>
        </div>
    </div>

    <div style="font-size:13px;color:var(--cp-text-muted);margin-bottom:10px;">
        Showing <strong><asp:Literal ID="litCount" runat="server" Text="0" /></strong> log(s)
        <span style="margin-left:8px;font-size:11px;">(most recent first, max 200)</span>
    </div>

    <%-- Logs table --%>
    <asp:Panel ID="pnlList" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="table" aria-label="Audit log entries">
                <thead>
                    <tr>
                        <th style="width:160px;">When</th>
                        <th>Action</th>
                        <th>Performed By</th>
                        <th>Target</th>
                        <th>Details</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptLogs" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-size:11px;color:var(--cp-text-muted);white-space:nowrap;">
                                    <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm:ss") %>
                                </td>
                                <td>
                                    <code style="font-size:11px;background:var(--cp-page-bg);
                                                 padding:2px 6px;border-radius:4px;
                                                 color:var(--cp-indigo);font-family:monospace;">
                                        <%# HttpUtility.HtmlEncode(Eval("ActionType").ToString()) %>
                                    </code>
                                </td>
                                <td style="font-size:12px;font-weight:600;">
                                    <%# HttpUtility.HtmlEncode(Eval("PerformedBy").ToString()) %>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <%# Eval("TargetTable") != DBNull.Value
                                        ? HttpUtility.HtmlEncode(Eval("TargetTable").ToString())
                                        : "—" %>
                                    <%# Eval("TargetID") != DBNull.Value
                                        ? $" <span style='font-size:11px;'>(ID: {Eval("TargetID")})</span>"
                                        : "" %>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);
                                           max-width:260px;word-break:break-word;">
                                    <%# Eval("Details") != DBNull.Value
                                        ? HttpUtility.HtmlEncode(Eval("Details").ToString())
                                        : "—" %>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4CB;</span>
            <h3>No audit log entries found</h3>
            <p>Admin actions will appear here as they are performed.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
=======
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
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
