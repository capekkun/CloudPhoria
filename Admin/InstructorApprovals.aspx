<%@ Page Title="Instructor Approvals" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="InstructorApprovals.aspx.cs"
    Inherits="CloudPhoria.Admin.InstructorApprovals" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

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
