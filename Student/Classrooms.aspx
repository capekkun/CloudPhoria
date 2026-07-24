<%@ Page Title="Classrooms" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Classrooms.aspx.cs"
    Inherits="CloudPhoria.Student.Classrooms" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="TopbarActions" ContentPlaceHolderID="TopbarActions" runat="server">
    <button type="button" class="cp-btn cp-btn-primary cp-btn-sm"
            onclick="document.getElementById('joinPanel').style.display='block';">
        + Join Classroom
    </button>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Classrooms</h2>
        <p>Your instructor-led classrooms. Enter an invite code to join a new one.</p>
    </div>

    <%-- Join classroom panel --%>
    <div id="joinPanel" style="display:none;margin-bottom:20px;">
        <div class="cp-card">
            <h3 class="cp-card-title">Join a Classroom</h3>
            <p class="cp-card-subtitle">Enter the invite code given by your instructor.</p>
            <asp:Panel ID="pnlJoinError" runat="server" Visible="false">
                <div class="cp-alert cp-alert-danger cp-mb-md">
                    <asp:Literal ID="litJoinError" runat="server" />
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlJoinSuccess" runat="server" Visible="false">
                <div class="cp-alert cp-alert-success cp-mb-md">
                    <asp:Literal ID="litJoinSuccess" runat="server" />
                </div>
            </asp:Panel>
            <div style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap;">
                <div class="cp-form-group" style="margin:0;flex:1;min-width:200px;">
                    <label class="cp-label" for="<%= txtInviteCode.ClientID %>">
                        Invite Code <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtInviteCode" runat="server"
                                 CssClass="cp-input"
                                 MaxLength="20"
                                 placeholder="e.g. ABC123" />
                    <asp:RequiredFieldValidator ID="rfvCode" runat="server"
                        ControlToValidate="txtInviteCode"
                        CssClass="cp-form-error"
                        ErrorMessage="Invite code is required."
                        Display="Dynamic" />
                </div>
                <asp:Button ID="btnJoin" runat="server"
                            Text="Join"
                            CssClass="cp-btn cp-btn-primary"
                            OnClick="btnJoin_Click" />
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlClassrooms" runat="server" Visible="false">
        <div class="cp-grid-2">
            <asp:Repeater ID="rptClassrooms" runat="server">
                <ItemTemplate>
                    <div class="cp-card">
                        <h3 class="cp-card-title">
                            <%# HttpUtility.HtmlEncode(Eval("ClassroomName").ToString()) %>
                        </h3>
                        <p class="cp-card-subtitle">
                            Instructor: <%# HttpUtility.HtmlEncode(Eval("InstructorName").ToString()) %>
                        </p>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-bottom:12px;">
                            Joined: <%# Convert.ToDateTime(Eval("EnrolledAt")).ToString("dd MMM yyyy") %>
                        </div>
                        <a href="ClassroomDetail.aspx?classroomID=<%# Eval("ClassroomID") %>"
                           class="cp-btn cp-btn-outline cp-btn-sm">
                            View Classroom
                        </a>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <h3>No classrooms yet</h3>
            <p>Join a classroom using an invite code from your instructor.</p>
        </div>
    </asp:Panel>

</asp:Content>
