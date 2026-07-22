<%@ Page Title="Fun Room Reviews" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="FunRoomReviews.aspx.cs"
    Inherits="CloudPhoria.Admin.FunRoomReviews" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F3AE; Fun Room Reviews</h2>
                <p>Review community-submitted Fun Rooms before they appear publicly on the platform.</p>
            </div>
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <%-- Filter bar --%>
    <div class="cp-card cp-mb-md">
        <div style="display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap;">
            <div style="min-width:150px;">
                <label class="cp-label">Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="Pending"  Selected="True">Pending</asp:ListItem>
                    <asp:ListItem Value="Approved">Approved</asp:ListItem>
                    <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
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
        Showing <strong><asp:Literal ID="litCount" runat="server" Text="0" /></strong> fun room(s)
    </div>

    <%-- Fun rooms list --%>
    <asp:Panel ID="pnlList" runat="server" Visible="false">
        <asp:Repeater ID="rptFunRooms" runat="server" OnItemCommand="rptFunRooms_ItemCommand">
            <ItemTemplate>
                <div class="cp-card cp-mb-md" style="padding:20px 24px;">
                    <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:16px;flex-wrap:wrap;">
                        <div style="flex:1;min-width:0;">
                            <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:6px;">
                                <span style="font-size:15px;font-weight:700;color:var(--cp-text);">
                                    <%# HttpUtility.HtmlEncode(Eval("RoomTitle").ToString()) %>
                                </span>
                                <%# GetStatusBadge(Eval("Status").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-bottom:8px;">
                                Submitted by <strong><%# HttpUtility.HtmlEncode(Eval("CreatorName").ToString()) %></strong>
                                &nbsp;&#x2022;&nbsp;
                                <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                            </div>
                            <div style="font-size:13px;color:var(--cp-text);line-height:1.5;
                                        max-height:80px;overflow:hidden;text-overflow:ellipsis;">
                                <%# Eval("ContentBody") != DBNull.Value
                                    ? HttpUtility.HtmlEncode(Eval("ContentBody").ToString())
                                    : "<span style='color:var(--cp-text-muted);font-style:italic;'>No description provided.</span>" %>
                            </div>
                            <%# Eval("ReviewedByName") != DBNull.Value
                                ? $"<div style='font-size:11px;color:var(--cp-text-muted);margin-top:8px;'>Reviewed by: <strong>{HttpUtility.HtmlEncode(Eval("ReviewedByName").ToString())}</strong></div>"
                                : "" %>
                        </div>
                        <div style="display:flex;flex-direction:column;gap:6px;flex-shrink:0;">
                            <asp:LinkButton runat="server"
                                Visible='<%# Eval("Status").ToString() != "Approved" %>'
                                CommandName="Approve"
                                CommandArgument='<%# Eval("FunRoomID") %>'
                                CssClass="cp-btn cp-btn-sm cp-btn-success">
                                &#x2714; Approve
                            </asp:LinkButton>
                            <asp:LinkButton runat="server"
                                Visible='<%# Eval("Status").ToString() != "Rejected" %>'
                                CommandName="Reject"
                                CommandArgument='<%# Eval("FunRoomID") %>'
                                CssClass="cp-btn cp-btn-sm cp-btn-danger"
                                OnClientClick="return confirm('Reject this Fun Room? The creator will be notified.');">
                                &#x2718; Reject
                            </asp:LinkButton>
                            <asp:LinkButton runat="server"
                                Visible='<%# Eval("Status").ToString() != "Pending" %>'
                                CommandName="SetPending"
                                CommandArgument='<%# Eval("FunRoomID") %>'
                                CssClass="cp-btn cp-btn-sm cp-btn-ghost">
                                Reset
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F3AE;</span>
            <h3>No fun rooms found</h3>
            <p>There are no fun rooms matching the selected status.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
