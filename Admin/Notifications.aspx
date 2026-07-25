<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Notifications.aspx.cs"
    Inherits="CloudPhoria.Admin.Notifications" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Notifications</h2>
                <p>Your personal notifications from platform activity.</p>
            </div>
            <div>
                <asp:Button ID="btnMarkAllRead" runat="server" Text="Mark All Read"
                    CssClass="cp-btn cp-btn-outline"
                    OnClick="btnMarkAllRead_Click"
                    OnClientClick="return confirm('Mark all notifications as read?');" />
            </div>
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <%-- Stats row --%>
    <div class="cp-grid-2 cp-mb-lg" style="max-width:480px;">
        <div class="cp-stat-card">
            <div class="cp-stat-icon red" aria-hidden="true"></div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litUnreadCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Unread</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon blue" aria-hidden="true"></div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litTotalCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Total</div>
            </div>
        </div>
    </div>

    <%-- Notification list --%>
    <asp:Panel ID="pnlList" runat="server" Visible="false">
        <asp:Repeater ID="rptNotifications" runat="server"
            OnItemCommand="rptNotifications_ItemCommand">
            <ItemTemplate>
                <div class="cp-card cp-mb-md" style="padding:14px 18px;
                    <%# !Convert.ToBoolean(Eval("IsRead"))
                        ? "border-left:3px solid var(--cp-primary);background:rgba(14,165,233,0.03);"
                        : "border-left:3px solid var(--cp-border);" %>">
                    <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;">
                        <div style="display:flex;align-items:flex-start;gap:12px;flex:1;min-width:0;">
                            <span style="font-size:18px;flex-shrink:0;" aria-hidden="true">
                                <%# !Convert.ToBoolean(Eval("IsRead")) ? "" : "" %>
                            </span>
                            <div style="flex:1;min-width:0;">
                                <div style="font-size:13px;color:var(--cp-text);line-height:1.5;">
                                    <%# HttpUtility.HtmlEncode(Eval("Message").ToString()) %>
                                </div>
                                <div style="font-size:11px;color:var(--cp-text-muted);margin-top:4px;
                                            display:flex;align-items:center;gap:8px;">
                                    <span><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %></span>
                                    <%# Eval("NotificationType") != DBNull.Value
                                        ? $"<span class='cp-badge cp-badge-grey' style='font-size:10px;'>{HttpUtility.HtmlEncode(Eval("NotificationType").ToString())}</span>"
                                        : "" %>
                                </div>
                            </div>
                        </div>
                        <div style="flex-shrink:0;">
                            <asp:LinkButton runat="server"
                                Visible='<%# !Convert.ToBoolean(Eval("IsRead")) %>'
                                CommandName="MarkRead"
                                CommandArgument='<%# Eval("NotificationID") %>'
                                CssClass="cp-btn cp-btn-sm cp-btn-ghost">
                                Mark Read
                            </asp:LinkButton>
                            <%# Convert.ToBoolean(Eval("IsRead"))
                                ? "<span style='font-size:11px;color:var(--cp-success);'>Read</span>"
                                : "" %>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <h3>No notifications</h3>
            <p>You have no notifications at this time.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
