<%@ Page Title="Challenges" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Challenges.aspx.cs"
    Inherits="CloudPhoria.Instructor.Challenges" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x26A1; Challenges</h2>
                <p>Create time-boxed challenges for your students to earn XP.</p>
            </div>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Challenge
            </button>
        </div>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span>&#x2714;</span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span>&#x26A0;</span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlChallenges" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Challenges">
                <thead>
                    <tr>
                        <th scope="col">Title</th>
                        <th scope="col">XP Reward</th>
                        <th scope="col">Start Date</th>
                        <th scope="col">End Date</th>
                        <th scope="col">Participants</th>
                        <th scope="col">Status</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptChallenges" runat="server"
                                  OnItemCommand="rptChallenges_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;"><%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %></td>
                                <td><span class="cp-xp-chip"><%# Eval("XPReward") %> XP</span></td>
                                <td style="color:var(--cp-text-muted);"><%# Convert.ToDateTime(Eval("StartDate")).ToString("dd MMM yyyy") %></td>
                                <td style="color:var(--cp-text-muted);"><%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy") %></td>
                                <td><span class="cp-badge cp-badge-blue"><%# Eval("ParticipantCount") %></span></td>
                                <td>
                                    <%# GetChallengeStatus(Eval("StartDate"), Eval("EndDate")) %>
                                </td>
                                <td>
                                    <asp:LinkButton runat="server"
                                        CommandName="Delete"
                                        CommandArgument='<%# Eval("ChallengeID") %>'
                                        CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                        OnClientClick="return confirm('Delete this challenge?');">
                                        Delete
                                    </asp:LinkButton>
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
            <span class="cp-empty-state-icon" aria-hidden="true">&#x26A1;</span>
            <h3>No challenges yet</h3>
            <p>Create a challenge to motivate your students with bonus XP.</p>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Challenge
            </button>
        </div>
    </asp:Panel>

    <%-- Create Challenge Modal --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="createChTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button" onclick="hideModal('createModal')" aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="createChTitle">New Challenge</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtChTitle.ClientID %>">Title <span class="required">*</span></label>
                <asp:TextBox ID="txtChTitle" runat="server" CssClass="cp-input"
                             MaxLength="150" placeholder="Challenge title" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtChTitle"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateCh" ErrorMessage="Title is required." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtChDesc.ClientID %>">Description</label>
                <asp:TextBox ID="txtChDesc" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="3" placeholder="What is this challenge about?" />
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtChXP.ClientID %>">XP Reward</label>
                    <asp:TextBox ID="txtChXP" runat="server" CssClass="cp-input" TextMode="Number" Text="50" />
                </div>
                <div class="cp-form-group"><%-- spacer --%></div>
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtChStart.ClientID %>">Start Date <span class="required">*</span></label>
                    <asp:TextBox ID="txtChStart" runat="server" CssClass="cp-input" TextMode="Date" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtChStart"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="CreateCh" ErrorMessage="Start date is required." />
                </div>
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtChEnd.ClientID %>">End Date <span class="required">*</span></label>
                    <asp:TextBox ID="txtChEnd" runat="server" CssClass="cp-input" TextMode="Date" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtChEnd"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="CreateCh" ErrorMessage="End date is required." />
                </div>
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('createModal')">Cancel</button>
                <asp:Button ID="btnCreateCh" runat="server" Text="Create Challenge"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="CreateCh"
                            OnClick="btnCreateCh_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function showModal(id) { document.getElementById(id).classList.add('open'); document.body.style.overflow='hidden'; }
function hideModal(id) { document.getElementById(id).classList.remove('open'); document.body.style.overflow=''; }
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el){
    el.addEventListener('click',function(e){ if(e.target===el) hideModal(el.id); });
});
</script>
</asp:Content>
