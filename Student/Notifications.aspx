<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Notifications.aspx.cs"
    Inherits="CloudPhoria.Student.Notifications" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="TopbarActions" ContentPlaceHolderID="TopbarActions" runat="server">
    <asp:LinkButton ID="btnMarkAllRead" runat="server"
        CssClass="cp-btn cp-btn-ghost cp-btn-sm"
        OnClick="btnMarkAllRead_Click">
        Mark all as read
    </asp:LinkButton>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Notifications</h2>
        <p>Your latest notifications and updates.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlNotifications" runat="server" Visible="false">
        <div class="cp-card" style="padding:0;overflow:hidden;">
            <asp:Repeater ID="rptNotifications" runat="server">
                <ItemTemplate>
                    <div style="display:flex;align-items:center;gap:12px;
                                padding:14px 18px;border-bottom:1px solid var(--cp-border);
                                background:<%# Convert.ToBoolean(Eval("IsRead")) ? "transparent" : "rgba(14,165,233,0.04)" %>;">
                        <span style="font-size:18px;flex-shrink:0;" aria-hidden="true">
                            <%# GetNotifIcon(Eval("NotificationType")) %>
                        </span>
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:13px;color:var(--cp-text);<%# Convert.ToBoolean(Eval("IsRead")) ? "" : "font-weight:600;" %>">
                                <%# HttpUtility.HtmlEncode(Eval("Message").ToString()) %>
                            </div>
                            <div style="font-size:11px;color:var(--cp-text-muted);margin-top:3px;">
                                <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                            </div>
                        </div>
                        <%# Convert.ToBoolean(Eval("IsRead")) ? "" :
                            "<span class='cp-badge cp-badge-blue'>New</span>" %>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F514;</span>
            <h3>No notifications</h3>
            <p>You're all caught up! New notifications will appear here.</p>
        </div>
    </asp:Panel>

</asp:Content>
