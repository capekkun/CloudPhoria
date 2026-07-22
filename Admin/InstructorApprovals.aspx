<%@ Page Title="Instructor Approvals" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="InstructorApprovals.aspx.cs"
    Inherits="CloudPhoria.Admin.InstructorApprovals" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<<<<<<< HEAD
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x2714; Instructor Approvals</h2>
                <p>Review instructor licence applications and grant or deny platform access.</p>
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
            <div style="min-width:160px;">
                <label class="cp-label">Filter by Status</label>
                <asp:DropDownList ID="ddlFilter" runat="server" CssClass="cp-select">
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
        Showing <strong><asp:Literal ID="litCount" runat="server" Text="0" /></strong> instructor(s)
    </div>

    <%-- Instructors table --%>
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
                                <td style="font-weight:600;">
                                    <%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <%# HttpUtility.HtmlEncode(Eval("Email").ToString()) %>
                                </td>
                                <td style="font-size:12px;">
                                    <%# Eval("Qualification") != DBNull.Value
                                        ? HttpUtility.HtmlEncode(Eval("Qualification").ToString())
                                        : "<span style='color:var(--cp-text-muted)'>—</span>" %>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                                </td>
                                <td>
                                    <%# GetStatusBadge(Eval("LicenseStatus").ToString()) %>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <%# Eval("ApprovedByName") != DBNull.Value
                                        ? HttpUtility.HtmlEncode(Eval("ApprovedByName").ToString())
                                        : "—" %>
                                    <%# Eval("ApprovedAt") != DBNull.Value
                                        ? "<br/><span style='font-size:11px;'>" +
                                          Convert.ToDateTime(Eval("ApprovedAt")).ToString("dd MMM yyyy") +
                                          "</span>"
                                        : "" %>
                                </td>
                                <td>
                                    <div style="display:flex;gap:4px;flex-wrap:wrap;">
                                        <asp:LinkButton runat="server"
                                            Visible='<%# Eval("LicenseStatus").ToString() != "Approved" %>'
                                            CommandName="Approve"
                                            CommandArgument='<%# Eval("InstructorID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-success">
                                            &#x2714; Approve
                                        </asp:LinkButton>
                                        <asp:LinkButton runat="server"
                                            Visible='<%# Eval("LicenseStatus").ToString() != "Rejected" %>'
                                            CommandName="Reject"
                                            CommandArgument='<%# Eval("InstructorID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-danger"
                                            OnClientClick="return confirm('Reject this instructor application?');">
                                            &#x2718; Reject
                                        </asp:LinkButton>
                                        <asp:LinkButton runat="server"
                                            Visible='<%# Eval("LicenseStatus").ToString() != "Pending" %>'
                                            CommandName="SetPending"
                                            CommandArgument='<%# Eval("InstructorID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-ghost">
                                            Reset
                                        </asp:LinkButton>
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
            <span class="cp-empty-state-icon" aria-hidden="true">&#x2714;</span>
            <h3>No instructors found</h3>
            <p>There are no instructor applications matching the selected filter.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
=======
<div class="cp-page-header">
    <h2>&#x2714; Instructor Approvals</h2>
    <p>Review and approve instructor licence applications before they can create content.</p>
</div>

<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="cp-alert cp-alert-success cp-mb-md"><asp:Literal ID="litSuccess" runat="server" /></div>
</asp:Panel>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Pending Applications</h3>
<asp:Panel ID="pnlPendingInstructors" runat="server" Visible="false">
    <asp:Repeater ID="rptPendingInstructors" runat="server" OnItemCommand="rptPendingInstructors_ItemCommand">
        <ItemTemplate>
            <div class="cp-card" style="margin-bottom:12px;">
                <div class="cp-flex-between" style="flex-wrap:wrap;gap:10px;">
                    <div>
                        <div style="font-size:14px;font-weight:700;color:var(--cp-text);">
                            <%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %>
                        </div>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-top:3px;">
                            <%# HttpUtility.HtmlEncode(Eval("Email").ToString()) %>
                        </div>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-top:6px;">
                            Qualification: <strong><%# HttpUtility.HtmlEncode(Eval("Qualification") != DBNull.Value ? Eval("Qualification").ToString() : "Not specified") %></strong>
                        </div>
                        <div style="font-size:11px;color:var(--cp-text-muted);margin-top:4px;">
                            Applied: <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                        </div>
                    </div>
                    <div class="ad-row-actions" style="display:flex;gap:6px;">
                        <asp:LinkButton runat="server" CommandName="Approve" CommandArgument='<%# Eval("InstructorID") %>'
                            CssClass="cp-btn cp-btn-primary cp-btn-sm"
                            OnClientClick="return confirm('Approve this instructor?');">
                            &#x2713; Approve
                        </asp:LinkButton>
                        <asp:LinkButton runat="server" CommandName="Reject" CommandArgument='<%# Eval("InstructorID") %>'
                            CssClass="cp-btn cp-btn-danger cp-btn-sm"
                            OnClientClick="return confirm('Reject this instructor application?');">
                            &#x2717; Reject
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>
<asp:Panel ID="pnlNoPending" runat="server" Visible="false">
    <div class="cp-empty-state">
        <span class="cp-empty-state-icon" aria-hidden="true">&#x2705;</span>
        <h3>No pending applications</h3>
        <p>All instructor applications have been reviewed.</p>
    </div>
</asp:Panel>

<h3 style="font-size:15px;font-weight:600;margin:28px 0 12px;">All Instructors</h3>
<div class="cp-table-wrap">
    <table class="cp-table">
        <thead><tr><th>Name</th><th>Qualification</th><th>Status</th><th>Approved</th></tr></thead>
        <tbody>
            <asp:Repeater ID="rptAllInstructors" runat="server">
                <ItemTemplate>
                    <tr>
                        <td><%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %></td>
                        <td><%# HttpUtility.HtmlEncode(Eval("Qualification") != DBNull.Value ? Eval("Qualification").ToString() : "-") %></td>
                        <td>
                            <%# Eval("LicenseStatus").ToString() == "Approved" ? "<span class='cp-badge cp-badge-green'>Approved</span>"
                                : Eval("LicenseStatus").ToString() == "Rejected" ? "<span class='cp-badge cp-badge-red'>Rejected</span>"
                                : "<span class='cp-badge cp-badge-amber'>Pending</span>" %>
                        </td>
                        <td style="font-size:12px;color:var(--cp-text-muted);">
                            <%# Eval("ApprovedAt") != DBNull.Value ? Convert.ToDateTime(Eval("ApprovedAt")).ToString("dd MMM yyyy") : "-" %>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>
</div>

</asp:Content>
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
