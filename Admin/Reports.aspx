<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Reports.aspx.cs"
    Inherits="CloudPhoria.Admin.Reports" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

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
