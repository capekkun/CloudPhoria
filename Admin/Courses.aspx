<%@ Page Title="Manage Courses" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Courses.aspx.cs"
    Inherits="CloudPhoria.Admin.Courses" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="cp-page-header">
    <h2>&#x1F4D6; Manage Courses</h2>
    <p>Assign instructors to modules and moderate published content across all pathways.</p>
</div>

<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="cp-alert cp-alert-success cp-mb-md"><asp:Literal ID="litSuccess" runat="server" /></div>
</asp:Panel>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Pathways</h3>
<div class="cp-grid-3 cp-mb-lg">
    <asp:Repeater ID="rptPathwaysAdmin" runat="server">
        <ItemTemplate>
            <div class="cp-card">
                <div style="font-size:14px;font-weight:700;color:var(--cp-text);">
                    <%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %>
                </div>
                <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                    <%# Eval("ModuleCount") %> modules
                    <%# Convert.ToBoolean(Eval("IsFoundation")) ? " &bull; Foundation (Free)" : "" %>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Modules — Assign Instructor &amp; Moderate</h3>
<div class="cp-table-wrap">
    <table class="cp-table">
        <thead><tr><th>Module</th><th>Pathway</th><th>Instructor</th><th>Status</th><th>Actions</th></tr></thead>
        <tbody>
            <asp:Repeater ID="rptModulesAdmin" runat="server" OnItemCommand="rptModulesAdmin_ItemCommand" OnItemDataBound="rptModulesAdmin_ItemDataBound">
                <ItemTemplate>
                    <tr>
                        <td><%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %></td>
                        <td style="font-size:12px;color:var(--cp-text-muted);"><%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %></td>
                        <td>
                            <asp:DropDownList runat="server" ID="ddlAssignInstructor" CssClass="cp-select" style="font-size:12px;padding:4px 8px;">
                            </asp:DropDownList>
                        </td>
                        <td>
                            <%# Convert.ToBoolean(Eval("IsPublished")) ? "<span class='cp-badge cp-badge-green'>Published</span>"
                                : "<span class='cp-badge cp-badge-grey'>Draft</span>" %>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px;flex-wrap:wrap;">
                                <asp:LinkButton runat="server" CommandName="Assign" CommandArgument='<%# Eval("ModuleID") %>'
                                    CssClass="cp-btn cp-btn-outline cp-btn-sm">Assign</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="TogglePublish" CommandArgument='<%# Eval("ModuleID") %>'
                                    CssClass="cp-btn cp-btn-outline cp-btn-sm">
                                    <%# Convert.ToBoolean(Eval("IsPublished")) ? "Unpublish" : "Publish" %>
                                </asp:LinkButton>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>
</div>

</asp:Content>
