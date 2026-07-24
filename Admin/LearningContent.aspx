<%@ Page Title="Learning Content" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="LearningContent.aspx.cs"
    Inherits="CloudPhoria.Admin.LearningContent" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Learning Content</h2>
                <p>Overview of all pathways, modules, and subtopics. Publish or unpublish content platform-wide.</p>
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
                <label class="cp-label">Pathway</label>
                <asp:DropDownList ID="ddlPathway" runat="server" CssClass="cp-select"
                    AutoPostBack="false" />
            </div>
            <div style="min-width:130px;">
                <label class="cp-label">Publish Status</label>
                <asp:DropDownList ID="ddlPublished" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="">All</asp:ListItem>
                    <asp:ListItem Value="1">Published</asp:ListItem>
                    <asp:ListItem Value="0">Draft</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div style="flex:1;min-width:160px;">
                <label class="cp-label">Search Module Name</label>
                <div class="cp-search-wrap">
                    <span class="cp-search-icon" aria-hidden="true"></span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="cp-input"
                        placeholder="Module name…" MaxLength="100" />
                </div>
            </div>
            <div>
                <asp:Button ID="btnFilter" runat="server" Text="Filter"
                    CssClass="cp-btn cp-btn-primary" OnClick="btnFilter_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear"
                    CssClass="cp-btn cp-btn-ghost" style="margin-left:6px;"
                    OnClick="btnClear_Click" />
            </div>
        </div>
    </div>

    <div style="font-size:13px;color:var(--cp-text-muted);margin-bottom:10px;">
        Showing <strong><asp:Literal ID="litCount" runat="server" Text="0" /></strong> module(s)
    </div>

    <%-- Modules table --%>
    <asp:Panel ID="pnlModules" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="table" aria-label="Learning content modules">
                <thead>
                    <tr>
                        <th>Module</th>
                        <th>Pathway</th>
                        <th>Difficulty</th>
                        <th>Subtopics</th>
                        <th>XP Reward</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptModules" runat="server"
                        OnItemCommand="rptModules_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div style="font-weight:600;font-size:13px;">
                                        <%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %>
                                    </div>
                                    <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;">
                                        Created <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                                    </div>
                                </td>
                                <td style="font-size:12px;">
                                    <%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %>
                                </td>
                                <td>
                                    <%# GetDifficultyBadge(Eval("DifficultyLevel").ToString()) %>
                                </td>
                                <td style="text-align:center;">
                                    <span class="cp-badge cp-badge-blue">
                                        <%# Eval("SubTopicCount") %>
                                    </span>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <span class="cp-xp-chip"><%# Eval("XPReward") %> XP</span>
                                </td>
                                <td>
                                    <%# Convert.ToBoolean(Eval("IsPublished"))
                                        ? "<span class='cp-badge cp-badge-green'>Published</span>"
                                        : "<span class='cp-badge cp-badge-grey'>Draft</span>" %>
                                </td>
                                <td>
                                    <asp:LinkButton runat="server"
                                        Visible='<%# !Convert.ToBoolean(Eval("IsPublished")) %>'
                                        CommandName="Publish"
                                        CommandArgument='<%# Eval("ModuleID") %>'
                                        CssClass="cp-btn cp-btn-sm cp-btn-success">
                                        Publish
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server"
                                        Visible='<%# Convert.ToBoolean(Eval("IsPublished")) %>'
                                        CommandName="Unpublish"
                                        CommandArgument='<%# Eval("ModuleID") %>'
                                        CssClass="cp-btn cp-btn-sm cp-btn-ghost"
                                        OnClientClick="return confirm('Unpublish this module? Students will lose access.');">
                                        Unpublish
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
            <h3>No modules found</h3>
            <p>Try adjusting your filters.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
