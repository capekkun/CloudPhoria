<%@ Page Title="Instructor Approvals" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="InstructorApprovals.aspx.cs"
    Inherits="CloudPhoria.Admin.InstructorApprovals" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Instructor Approvals</h2>
                <p>Review instructor licence applications and grant or deny platform access.</p>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <div class="cp-card cp-mb-md">
        <div style="display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap;">
            <div style="min-width:160px;">
                <label class="cp-label">Filter by Status</label>
                <asp:DropDownList ID="ddlFilter" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="Pending" Selected="True">Pending</asp:ListItem>
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
        Showing <strong><asp:Literal ID="litCount" runat="server" Text="0" /></strong> instructor(s)
    </div>

    <asp:Panel ID="pnlList" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="table" aria-label="Instructor approvals">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Qualification</th>
                        <th>Registered</th>
                        <th>Status</th>
                        <th>Approved By</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptInstructors" runat="server"
                        OnItemCommand="rptInstructors_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;"><%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %></td>
                                <td style="font-size:12px;color:var(--cp-text-muted);"><%# HttpUtility.HtmlEncode(Eval("Email").ToString()) %></td>
                                <td style="font-size:12px;">
                                    <%# Eval("Qualification") != DBNull.Value ? HttpUtility.HtmlEncode(Eval("Qualification").ToString()) : "<span style='color:var(--cp-text-muted)'>—</span>" %>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %></td>
                                <td><%# GetStatusBadge(Eval("LicenseStatus").ToString()) %></td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <%# Eval("ApprovedByName") != DBNull.Value ? HttpUtility.HtmlEncode(Eval("ApprovedByName").ToString()) : "—" %>
                                </td>
                                <td>
                                    <div style="display:flex;gap:4px;flex-wrap:wrap;">
                                        <asp:LinkButton runat="server"
                                            Visible='<%# Eval("LicenseStatus").ToString() != "Approved" %>'
                                            CommandName="Approve" CommandArgument='<%# Eval("InstructorID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-success">Approve</asp:LinkButton>
                                        <asp:LinkButton runat="server"
                                            Visible='<%# Eval("LicenseStatus").ToString() != "Rejected" %>'
                                            CommandName="Reject" CommandArgument='<%# Eval("InstructorID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-danger"
                                            OnClientClick="return confirm('Reject this instructor?');">Reject</asp:LinkButton>
                                        <asp:LinkButton runat="server"
                                            Visible='<%# Eval("LicenseStatus").ToString() != "Pending" %>'
                                            CommandName="SetPending" CommandArgument='<%# Eval("InstructorID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-ghost">Reset</asp:LinkButton>
                                    </div>
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
            <h3>No instructors found</h3>
            <p>No instructor applications match the selected filter.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
