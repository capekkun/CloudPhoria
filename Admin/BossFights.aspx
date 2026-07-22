<%@ Page Title="Boss Fights" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="BossFights.aspx.cs"
    Inherits="CloudPhoria.Admin.BossFights" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F480; Boss Fight Rooms</h2>
                <p>Manage official admin-created Boss Fight rooms. Publish or unpublish to control student access.</p>
            </div>
            <div>
                <button type="button" class="cp-btn cp-btn-primary"
                    onclick="document.getElementById('createPanel').style.display =
                             document.getElementById('createPanel').style.display === 'none' ? 'block' : 'none';">
                    &#x2B; Create New Room
                </button>
            </div>
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <%-- Create new room form --%>
    <div id="createPanel" style="display:none;" class="cp-card cp-mb-lg">
        <h3 style="font-size:15px;font-weight:700;margin:0 0 16px;">Create New Boss Fight Room</h3>
        <div class="cp-grid-2" style="gap:12px;">
            <div class="cp-form-group">
                <label class="cp-label">Room Title <span class="required">*</span></label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="cp-input"
                    MaxLength="150" placeholder="e.g. Firewall Fortress" />
                <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                    ControlToValidate="txtTitle" ValidationGroup="Create"
                    CssClass="cp-form-error" ErrorMessage="Title is required." Display="Dynamic" />
            </div>
            <div class="cp-form-group">
                <label class="cp-label">Difficulty <span class="required">*</span></label>
                <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="Easy">Easy</asp:ListItem>
                    <asp:ListItem Value="Medium">Medium</asp:ListItem>
                    <asp:ListItem Value="Hard">Hard</asp:ListItem>
                    <asp:ListItem Value="Legendary">Legendary</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="cp-form-group">
                <label class="cp-label">XP Reward <span class="required">*</span></label>
                <asp:TextBox ID="txtXPReward" runat="server" CssClass="cp-input"
                    TextMode="Number" placeholder="e.g. 200" />
                <asp:RequiredFieldValidator ID="rfvXP" runat="server"
                    ControlToValidate="txtXPReward" ValidationGroup="Create"
                    CssClass="cp-form-error" ErrorMessage="XP Reward is required." Display="Dynamic" />
                <asp:RangeValidator ID="rvXP" runat="server"
                    ControlToValidate="txtXPReward" ValidationGroup="Create"
                    Type="Integer" MinimumValue="1" MaximumValue="9999"
                    CssClass="cp-form-error" ErrorMessage="Enter a value between 1 and 9999." Display="Dynamic" />
            </div>
            <div class="cp-form-group">
                <label class="cp-label">Player Max HP <span class="required">*</span></label>
                <asp:TextBox ID="txtPlayerHP" runat="server" CssClass="cp-input"
                    TextMode="Number" placeholder="e.g. 100" />
                <asp:RequiredFieldValidator ID="rfvHP" runat="server"
                    ControlToValidate="txtPlayerHP" ValidationGroup="Create"
                    CssClass="cp-form-error" ErrorMessage="Player HP is required." Display="Dynamic" />
                <asp:RangeValidator ID="rvHP" runat="server"
                    ControlToValidate="txtPlayerHP" ValidationGroup="Create"
                    Type="Integer" MinimumValue="1" MaximumValue="9999"
                    CssClass="cp-form-error" ErrorMessage="Enter a value between 1 and 9999." Display="Dynamic" />
            </div>
        </div>
        <div class="cp-form-group">
            <label class="cp-label">Theme Description</label>
            <asp:TextBox ID="txtTheme" runat="server" CssClass="cp-textarea"
                TextMode="MultiLine" Rows="3"
                placeholder="Describe the battle theme…" MaxLength="2000" />
        </div>
        <div style="display:flex;gap:8px;margin-top:4px;">
            <asp:Button ID="btnCreate" runat="server" Text="Create Room"
                CssClass="cp-btn cp-btn-primary" ValidationGroup="Create"
                OnClick="btnCreate_Click" />
            <button type="button" class="cp-btn cp-btn-ghost"
                onclick="document.getElementById('createPanel').style.display='none';">
                Cancel
            </button>
        </div>
    </div>

    <%-- Filter bar --%>
    <div class="cp-card cp-mb-md" style="padding:14px 20px;">
        <div style="display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap;">
            <div style="min-width:150px;">
                <label class="cp-label">Difficulty</label>
                <asp:DropDownList ID="ddlFilterDiff" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="">All Difficulties</asp:ListItem>
                    <asp:ListItem Value="Easy">Easy</asp:ListItem>
                    <asp:ListItem Value="Medium">Medium</asp:ListItem>
                    <asp:ListItem Value="Hard">Hard</asp:ListItem>
                    <asp:ListItem Value="Legendary">Legendary</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div style="min-width:130px;">
                <label class="cp-label">Status</label>
                <asp:DropDownList ID="ddlFilterPub" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="">All</asp:ListItem>
                    <asp:ListItem Value="1">Published</asp:ListItem>
                    <asp:ListItem Value="0">Unpublished</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div>
                <asp:Button ID="btnFilter" runat="server" Text="Filter"
                    CssClass="cp-btn cp-btn-primary" OnClick="btnFilter_Click" />
                <asp:Button ID="btnClearFilter" runat="server" Text="Clear"
                    CssClass="cp-btn cp-btn-ghost" style="margin-left:6px;"
                    OnClick="btnClearFilter_Click" />
            </div>
        </div>
    </div>

    <div style="font-size:13px;color:var(--cp-text-muted);margin-bottom:10px;">
        Showing <strong><asp:Literal ID="litCount" runat="server" Text="0" /></strong> room(s)
    </div>

    <%-- Boss fight rooms table --%>
    <asp:Panel ID="pnlList" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="table" aria-label="Boss fight rooms">
                <thead>
                    <tr>
                        <th>Room Title</th>
                        <th>Boss</th>
                        <th>Difficulty</th>
                        <th>XP Reward</th>
                        <th>Questions</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptRooms" runat="server" OnItemCommand="rptRooms_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div style="font-weight:600;font-size:13px;">
                                        <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                                    </div>
                                    <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;">
                                        Created <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                                    </div>
                                </td>
                                <td style="font-size:12px;">
                                    <%# Eval("BossName") != DBNull.Value
                                        ? HttpUtility.HtmlEncode(Eval("BossName").ToString())
                                        : "<span style='color:var(--cp-text-muted);font-style:italic;'>No boss yet</span>" %>
                                </td>
                                <td><%# GetDifficultyBadge(Eval("DifficultyLevel").ToString()) %></td>
                                <td>
                                    <span class="cp-xp-chip">&#x26A1; <%# Eval("XPReward") %> XP</span>
                                </td>
                                <td style="text-align:center;">
                                    <span class="cp-badge cp-badge-blue"><%# Eval("QuestionCount") %></span>
                                </td>
                                <td>
                                    <%# Convert.ToBoolean(Eval("IsPublished"))
                                        ? "<span class='cp-badge cp-badge-green'>Published</span>"
                                        : "<span class='cp-badge cp-badge-grey'>Draft</span>" %>
                                </td>
                                <td>
                                    <div style="display:flex;gap:4px;flex-wrap:wrap;">
                                        <asp:LinkButton runat="server"
                                            Visible='<%# !Convert.ToBoolean(Eval("IsPublished")) %>'
                                            CommandName="Publish"
                                            CommandArgument='<%# Eval("RoomID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-success">
                                            Publish
                                        </asp:LinkButton>
                                        <asp:LinkButton runat="server"
                                            Visible='<%# Convert.ToBoolean(Eval("IsPublished")) %>'
                                            CommandName="Unpublish"
                                            CommandArgument='<%# Eval("RoomID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-ghost"
                                            OnClientClick="return confirm('Unpublish this Boss Fight room?');">
                                            Unpublish
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
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F480;</span>
            <h3>No boss fight rooms found</h3>
            <p>Create a new room using the button above.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
