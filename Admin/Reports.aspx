<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Reports.aspx.cs"
    Inherits="CloudPhoria.Admin.Reports" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<<<<<<< HEAD
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F4CA; Reports &amp; Moderation</h2>
                <p>Review user-submitted reports and take appropriate moderation actions.</p>
            </div>
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <%-- Stats row --%>
    <div class="cp-grid-4 cp-mb-lg">
        <div class="cp-stat-card">
            <div class="cp-stat-icon red" aria-hidden="true">&#x1F6A8;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litOpenCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Open</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon amber" aria-hidden="true">&#x1F441;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litReviewedCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Reviewed</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon green" aria-hidden="true">&#x2714;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litActionCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Action Taken</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon blue" aria-hidden="true">&#x1F6AB;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litDismissedCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Dismissed</div>
            </div>
        </div>
    </div>

    <%-- Filter bar --%>
    <div class="cp-card cp-mb-md" style="padding:14px 20px;">
        <div style="display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap;">
            <div style="min-width:150px;">
                <label class="cp-label">Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="Open"        Selected="True">Open</asp:ListItem>
                    <asp:ListItem Value="Reviewed">Reviewed</asp:ListItem>
                    <asp:ListItem Value="ActionTaken">Action Taken</asp:ListItem>
                    <asp:ListItem Value="Dismissed">Dismissed</asp:ListItem>
                    <asp:ListItem Value="">All</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div>
                <asp:Button ID="btnFilter" runat="server" Text="Filter"
                    CssClass="cp-btn cp-btn-primary" OnClick="btnFilter_Click" />
            </div>
        </div>
    </div>

    <div style="font-size:13px;color:var(--cp-text-muted);margin-bottom:10px;">
        Showing <strong><asp:Literal ID="litCount" runat="server" Text="0" /></strong> report(s)
    </div>

    <%-- Reports list --%>
    <asp:Panel ID="pnlList" runat="server" Visible="false">
        <asp:Repeater ID="rptReports" runat="server" OnItemCommand="rptReports_ItemCommand">
            <ItemTemplate>
                <div class="cp-card cp-mb-md" style="padding:18px 22px;">
                    <div style="display:flex;align-items:flex-start;justify-content:space-between;
                                gap:16px;flex-wrap:wrap;">
                        <div style="flex:1;min-width:0;">
                            <%-- Header row: report ID, content type, status --%>
                            <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:8px;">
                                <span style="font-size:11px;color:var(--cp-text-muted);">
                                    Report #<%# Eval("ReportID") %>
                                </span>
                                <%# Eval("ReportedContentType") != DBNull.Value
                                    ? $"<span class='cp-badge cp-badge-grey'>{HttpUtility.HtmlEncode(Eval("ReportedContentType").ToString())}</span>"
                                    : "" %>
                                <%# GetStatusBadge(Eval("Status").ToString()) %>
                            </div>
                            <%-- Reporter & reported user --%>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-bottom:6px;">
                                Reported by <strong><%# HttpUtility.HtmlEncode(Eval("ReporterName").ToString()) %></strong>
                                <%# Eval("ReportedUserName") != DBNull.Value
                                    ? $" &nbsp;&#x2022;&nbsp; Against: <strong>{HttpUtility.HtmlEncode(Eval("ReportedUserName").ToString())}</strong>"
                                    : "" %>
                                &nbsp;&#x2022;&nbsp;
                                <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                            </div>
                            <%-- Reason --%>
                            <div style="font-size:13px;color:var(--cp-text);line-height:1.5;
                                        padding:10px 14px;background:var(--cp-page-bg);
                                        border-radius:var(--cp-radius-sm);border:1px solid var(--cp-border);">
                                <%# HttpUtility.HtmlEncode(Eval("Reason").ToString()) %>
                            </div>
                            <%# Eval("ReviewedByName") != DBNull.Value
                                ? $"<div style='font-size:11px;color:var(--cp-text-muted);margin-top:8px;'>Reviewed by: <strong>{HttpUtility.HtmlEncode(Eval("ReviewedByName").ToString())}</strong></div>"
                                : "" %>
                        </div>
                        <%-- Action buttons — only show when the report is not fully resolved --%>
                        <div style="display:flex;flex-direction:column;gap:6px;flex-shrink:0;min-width:120px;">
                            <asp:LinkButton runat="server"
                                Visible='<%# Eval("Status").ToString() != "Reviewed" %>'
                                CommandName="MarkReviewed"
                                CommandArgument='<%# Eval("ReportID") %>'
                                CssClass="cp-btn cp-btn-sm cp-btn-outline">
                                Mark Reviewed
                            </asp:LinkButton>
                            <asp:LinkButton runat="server"
                                Visible='<%# Eval("Status").ToString() != "ActionTaken" %>'
                                CommandName="ActionTaken"
                                CommandArgument='<%# Eval("ReportID") %>'
                                CssClass="cp-btn cp-btn-sm cp-btn-success">
                                Action Taken
                            </asp:LinkButton>
                            <asp:LinkButton runat="server"
                                Visible='<%# Eval("Status").ToString() != "Dismissed" %>'
                                CommandName="Dismiss"
                                CommandArgument='<%# Eval("ReportID") %>'
                                CssClass="cp-btn cp-btn-sm cp-btn-ghost"
                                OnClientClick="return confirm('Dismiss this report?');">
                                Dismiss
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4CA;</span>
            <h3>No reports found</h3>
            <p>No reports match the selected status filter.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
=======
<div class="cp-page-header">
    <h2>&#x1F6A8; Reports &amp; Moderation</h2>
    <p>Review reports submitted by users about content or other users, then take action.</p>
</div>

<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="cp-alert cp-alert-success cp-mb-md"><asp:Literal ID="litSuccess" runat="server" /></div>
</asp:Panel>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<div style="display:flex;gap:8px;margin-bottom:16px;">
    <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="cp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_Changed">
        <asp:ListItem Value="" Text="All Statuses" />
        <asp:ListItem Value="Open" Text="Open" Selected="True" />
        <asp:ListItem Value="Reviewed" Text="Reviewed" />
        <asp:ListItem Value="ActionTaken" Text="Action Taken" />
        <asp:ListItem Value="Dismissed" Text="Dismissed" />
    </asp:DropDownList>
</div>

<asp:Panel ID="pnlReports" runat="server" Visible="false">
    <asp:Repeater ID="rptReports" runat="server" OnItemCommand="rptReports_ItemCommand">
        <ItemTemplate>
            <div class="cp-card" style="margin-bottom:12px;">
                <div class="cp-flex-between" style="flex-wrap:wrap;gap:10px;align-items:flex-start;">
                    <div style="flex:1;min-width:200px;">
                        <div style="font-size:13px;font-weight:700;color:var(--cp-text);">
                            Reported by: <%# HttpUtility.HtmlEncode(Eval("ReporterName").ToString()) %>
                            <%# Eval("ReportedUserName") != DBNull.Value ? " &rarr; against " + HttpUtility.HtmlEncode(Eval("ReportedUserName").ToString()) : "" %>
                        </div>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                            <%# Eval("ReportedContentType") != DBNull.Value ? "Content type: " + HttpUtility.HtmlEncode(Eval("ReportedContentType").ToString()) + " &bull; " : "" %>
                            <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                        </div>
                        <div style="font-size:13px;color:var(--cp-text);margin-top:8px;padding:10px;background:var(--cp-bg-subtle);border-radius:8px;">
                            <%# HttpUtility.HtmlEncode(Eval("Reason").ToString()) %>
                        </div>
                    </div>
                    <div style="display:flex;flex-direction:column;gap:6px;align-items:flex-end;">
                        <%# Eval("Status").ToString() == "Open" ? "<span class='cp-badge cp-badge-red'>Open</span>"
                            : Eval("Status").ToString() == "Reviewed" ? "<span class='cp-badge cp-badge-amber'>Reviewed</span>"
                            : Eval("Status").ToString() == "ActionTaken" ? "<span class='cp-badge cp-badge-green'>Action Taken</span>"
                            : "<span class='cp-badge cp-badge-grey'>Dismissed</span>" %>
                        <div style="display:flex;gap:6px;">
                            <asp:LinkButton runat="server" CommandName="MarkReviewed" CommandArgument='<%# Eval("ReportID") %>'
                                CssClass="cp-btn cp-btn-outline cp-btn-sm">Reviewed</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="ActionTaken" CommandArgument='<%# Eval("ReportID") %>'
                                CssClass="cp-btn cp-btn-primary cp-btn-sm">Action Taken</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="Dismiss" CommandArgument='<%# Eval("ReportID") %>'
                                CssClass="cp-btn cp-btn-ghost cp-btn-sm">Dismiss</asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>
<asp:Panel ID="pnlNoReports" runat="server" Visible="false">
    <div class="cp-empty-state">
        <span class="cp-empty-state-icon" aria-hidden="true">&#x2705;</span>
        <h3>No reports found</h3>
        <p>There are no reports matching this filter.</p>
    </div>
</asp:Panel>

</asp:Content>
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
