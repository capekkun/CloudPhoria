<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Notifications.aspx.cs"
    Inherits="CloudPhoria.Admin.Notifications" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F514; Notifications</h2>
<<<<<<< HEAD
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
            <div class="cp-stat-icon red" aria-hidden="true">&#x1F514;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litUnreadCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Unread</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon blue" aria-hidden="true">&#x1F4EC;</div>
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
                                <%# !Convert.ToBoolean(Eval("IsRead")) ? "&#x1F514;" : "&#x1F515;" %>
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
=======
                <p>Your recent notifications and alerts.</p>
            </div>
            <asp:Panel ID="pnlMarkAllBtn" runat="server" Visible="false">
                <asp:Button ID="btnMarkAll" runat="server" Text="Mark All as Read"
                            CssClass="cp-btn cp-btn-outline"
                            OnClick="btnMarkAll_Click"
                            OnClientClick="return confirm('Mark all notifications as read?');" />
            </asp:Panel>
        </div>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span>&#x2714;</span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlNotifications" runat="server" Visible="false">
        <div class="cp-card" style="padding:0;overflow:hidden;">
            <asp:Repeater ID="rptNotifications" runat="server"
                          OnItemCommand="rptNotifications_ItemCommand">
                <ItemTemplate>
                    <div style="display:flex;align-items:flex-start;gap:14px;
                                padding:14px 20px;
                                border-bottom:1px solid var(--cp-border);
                                background:<%# Convert.ToBoolean(Eval("IsRead")) ? "transparent" : "rgba(14,165,233,0.04)" %>;">
                        <span style="font-size:20px;flex-shrink:0;margin-top:2px;" aria-hidden="true">
                            &#x1F514;
                        </span>
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:13px;color:var(--cp-text);font-weight:<%# Convert.ToBoolean(Eval("IsRead")) ? "400" : "600" %>;">
                                <%# HttpUtility.HtmlEncode(Eval("Message").ToString()) %>
                            </div>
                            <div style="font-size:11px;color:var(--cp-text-muted);margin-top:3px;">
                                <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                                <%# !string.IsNullOrEmpty(Eval("NotificationType") as string) ? " &bull; " + HttpUtility.HtmlEncode(Eval("NotificationType").ToString()) : "" %>
                            </div>
                        </div>
                        <div style="display:flex;align-items:center;gap:8px;flex-shrink:0;">
                            <%# Convert.ToBoolean(Eval("IsRead")) ? "" : "<span class='cp-badge cp-badge-blue'>New</span>" %>
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
                            <asp:LinkButton runat="server"
                                Visible='<%# !Convert.ToBoolean(Eval("IsRead")) %>'
                                CommandName="MarkRead"
                                CommandArgument='<%# Eval("NotificationID") %>'
<<<<<<< HEAD
                                CssClass="cp-btn cp-btn-sm cp-btn-ghost">
                                Mark Read
                            </asp:LinkButton>
                            <%# Convert.ToBoolean(Eval("IsRead"))
                                ? "<span style='font-size:11px;color:var(--cp-success);'>&#x2714; Read</span>"
                                : "" %>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
=======
                                CssClass="cp-btn cp-btn-ghost cp-btn-sm">
                                Mark Read
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F514;</span>
            <h3>No notifications</h3>
<<<<<<< HEAD
            <p>You have no notifications at this time.</p>
=======
            <p>You're all caught up. Notifications will appear here.</p>
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
        </div>
    </asp:Panel>

</asp:Content>
<<<<<<< HEAD

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
=======
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
