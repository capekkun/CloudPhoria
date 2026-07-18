<%@ Page Title="Classroom" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="ClassroomDetail.aspx.cs"
    Inherits="CloudPhoria.Student.ClassroomDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="cp-page-header">
        <h2>&#x1F3EB; <asp:Literal ID="litClassName" runat="server" Text="Classroom" /></h2>
        <p>Instructor: <asp:Literal ID="litInstructor" runat="server" /></p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server" Visible="false">
        <h3>Materials</h3>
        <asp:Panel ID="pnlMaterials" runat="server" Visible="false">
            <asp:Repeater ID="rptMaterials" runat="server">
                <ItemTemplate>
                    <div class="cp-module-card">
                        <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                            &#x1F4CE; <%# HttpUtility.HtmlEncode(Eval("FileName").ToString()) %>
                        </div>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                            Uploaded: <%# Convert.ToDateTime(Eval("UploadedAt")).ToString("dd MMM yyyy") %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
        <asp:Panel ID="pnlNoMaterials" runat="server" Visible="false">
            <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">No materials uploaded yet.</div>
        </asp:Panel>

        <h3>Assignments</h3>
        <asp:Panel ID="pnlAssignments" runat="server" Visible="false">
            <asp:Repeater ID="rptAssignments" runat="server">
                <ItemTemplate>
                    <div class="cp-module-card">
                        <div class="cp-flex-between">
                            <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                                &#x1F4DD; <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                            </div>
                            <%# Eval("DueDate") != DBNull.Value
                                ? "<span class='cp-badge cp-badge-amber'>Due: " + Convert.ToDateTime(Eval("DueDate")).ToString("dd MMM yyyy") + "</span>"
                                : "" %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
        <asp:Panel ID="pnlNoAssignments" runat="server" Visible="false">
            <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">No assignments posted yet.</div>
        </asp:Panel>
    </asp:Panel>

    <div style="margin-top:16px;">
        <a href="Classrooms.aspx" style="font-size:13px;color:var(--cp-primary);">&#x2190; Back to Classrooms</a>
    </div>
</asp:Content>
