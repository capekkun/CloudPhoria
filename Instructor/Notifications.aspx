<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Notifications.aspx.cs"
    Inherits="CloudPhoria.Instructor.Notifications" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Notifications</h2>
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
        <div class="cp-alert cp-alert-success"><span></span>
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
                            <asp:LinkButton runat="server"
                                Visible='<%# !Convert.ToBoolean(Eval("IsRead")) %>'
                                CommandName="MarkRead"
                                CommandArgument='<%# Eval("NotificationID") %>'
                                CssClass="cp-btn cp-btn-ghost cp-btn-sm">
                                Mark Read
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <h3>No notifications</h3>
            <p>You're all caught up. Notifications will appear here.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
