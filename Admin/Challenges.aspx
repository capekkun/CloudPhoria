<%@ Page Title="Challenges" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Challenges.aspx.cs"
    Inherits="CloudPhoria.Admin.Challenges" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x26A1; Challenges</h2>
                <p>Create and manage official admin challenges for the CloudPhoria platform.</p>
            </div>
            <div>
                <button type="button" class="cp-btn cp-btn-primary"
                    onclick="toggleCreatePanel();">
                    &#x2B; New Challenge
                </button>
            </div>
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <%-- Create challenge form --%>
    <div id="createPanel" style="display:none;" class="cp-card cp-mb-lg">
        <h3 style="font-size:15px;font-weight:700;margin:0 0 16px;">Create New Challenge</h3>
        <div class="cp-form-group">
            <label class="cp-label">Challenge Title <span class="required">*</span></label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="cp-input"
                MaxLength="150" placeholder="e.g. Cloud Security Sprint" />
            <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                ControlToValidate="txtTitle" ValidationGroup="Create"
                CssClass="cp-form-error" ErrorMessage="Title is required." Display="Dynamic" />
        </div>
        <div class="cp-form-group">
            <label class="cp-label">Description</label>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="cp-textarea"
                TextMode="MultiLine" Rows="3"
                placeholder="Describe this challenge…" MaxLength="4000" />
        </div>
        <div class="cp-grid-2" style="gap:12px;">
            <div class="cp-form-group">
                <label class="cp-label">XP Reward <span class="required">*</span></label>
                <asp:TextBox ID="txtXPReward" runat="server" CssClass="cp-input"
                    TextMode="Number" placeholder="e.g. 100" />
                <asp:RequiredFieldValidator ID="rfvXP" runat="server"
                    ControlToValidate="txtXPReward" ValidationGroup="Create"
                    CssClass="cp-form-error" ErrorMessage="XP Reward is required." Display="Dynamic" />
                <asp:RangeValidator ID="rvXP" runat="server"
                    ControlToValidate="txtXPReward" ValidationGroup="Create"
                    Type="Integer" MinimumValue="1" MaximumValue="9999"
                    CssClass="cp-form-error" ErrorMessage="Enter 1–9999." Display="Dynamic" />
            </div>
            <div></div><%-- spacer --%>
            <div class="cp-form-group">
                <label class="cp-label">Start Date &amp; Time <span class="required">*</span></label>
                <asp:TextBox ID="txtStartDate" runat="server" CssClass="cp-input"
                    TextMode="DateTimeLocal" />
                <asp:RequiredFieldValidator ID="rfvStart" runat="server"
                    ControlToValidate="txtStartDate" ValidationGroup="Create"
                    CssClass="cp-form-error" ErrorMessage="Start date is required." Display="Dynamic" />
            </div>
            <div class="cp-form-group">
                <label class="cp-label">End Date &amp; Time <span class="required">*</span></label>
                <asp:TextBox ID="txtEndDate" runat="server" CssClass="cp-input"
                    TextMode="DateTimeLocal" />
                <asp:RequiredFieldValidator ID="rfvEnd" runat="server"
                    ControlToValidate="txtEndDate" ValidationGroup="Create"
                    CssClass="cp-form-error" ErrorMessage="End date is required." Display="Dynamic" />
            </div>
        </div>
        <div style="display:flex;gap:8px;margin-top:4px;">
            <asp:Button ID="btnCreate" runat="server" Text="Create Challenge"
                CssClass="cp-btn cp-btn-primary" ValidationGroup="Create"
                OnClick="btnCreate_Click" />
            <button type="button" class="cp-btn cp-btn-ghost"
                onclick="document.getElementById('createPanel').style.display='none';">
                Cancel
            </button>
        </div>
    </div>

    <%-- Stats row --%>
    <div class="cp-grid-3 cp-mb-lg">
        <div class="cp-stat-card">
            <div class="cp-stat-icon amber" aria-hidden="true">&#x26A1;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litActiveCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Active Now</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon blue" aria-hidden="true">&#x23F3;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litUpcomingCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Upcoming</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon green" aria-hidden="true">&#x2714;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litEndedCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Ended</div>
            </div>
        </div>
    </div>

    <%-- Challenges table --%>
    <asp:Panel ID="pnlList" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="table" aria-label="Challenges list">
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Created By</th>
                        <th>XP Reward</th>
                        <th>Start</th>
                        <th>End</th>
                        <th>Participants</th>
                        <th>State</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptChallenges" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div style="font-weight:600;font-size:13px;">
                                        <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                                    </div>
                                    <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;
                                                max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                        <%# Eval("Description") != DBNull.Value
                                            ? HttpUtility.HtmlEncode(Eval("Description").ToString())
                                            : "" %>
                                    </div>
                                </td>
                                <td style="font-size:12px;">
                                    <%# Eval("CreatorName") != DBNull.Value
                                        ? HttpUtility.HtmlEncode(Eval("CreatorName").ToString())
                                        : "<span style='color:var(--cp-text-muted);'>—</span>" %>
                                    <br/>
                                    <span class="cp-badge cp-badge-red" style="font-size:10px;">Admin</span>
                                </td>
                                <td>
                                    <span class="cp-xp-chip">&#x26A1; <%# Eval("XPReward") %> XP</span>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <%# Convert.ToDateTime(Eval("StartDate")).ToString("dd MMM yyyy HH:mm") %>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy HH:mm") %>
                                </td>
                                <td style="text-align:center;">
                                    <span class="cp-badge cp-badge-blue"><%# Eval("ParticipantCount") %></span>
                                </td>
                                <td>
                                    <%# GetChallengeStateBadge(
                                            Convert.ToDateTime(Eval("StartDate")),
                                            Convert.ToDateTime(Eval("EndDate"))) %>
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
            <p>Create a challenge using the button above.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function toggleCreatePanel() {
    var p = document.getElementById('createPanel');
    p.style.display = (p.style.display === 'none' || p.style.display === '') ? 'block' : 'none';
}
</script>
</asp:Content>
