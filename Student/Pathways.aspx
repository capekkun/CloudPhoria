<%@ Page Title="Learning Pathways" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Pathways.aspx.cs"
    Inherits="CloudPhoria.Student.Pathways" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Learning Pathways</h2>
        <p>Choose a pathway to start your cloud computing journey. Complete all modules in a pathway to earn your certification.</p>
    </div>

    <%-- Subscription notice --%>
    <asp:Panel ID="pnlFreeNotice" runat="server" Visible="false">
        <div class="cp-alert cp-alert-info cp-mb-md">
            <span aria-hidden="true">&#x2139;</span>
            <span>You are on the <strong>Free</strong> plan. You can access the <strong>Cloud Foundations</strong> pathway.
            Upgrade to a Pro or Student plan to unlock all specialisation pathways.</span>
        </div>
    </asp:Panel>

    <%-- Error state --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- Pathways grid --%>
    <asp:Panel ID="pnlPathways" runat="server" Visible="false">
        <asp:Repeater ID="rptPathways" runat="server">
            <HeaderTemplate>
                <div class="cp-grid-3">
            </HeaderTemplate>
            <ItemTemplate>
                <div class="cp-card" style="position:relative;overflow:hidden;<%# Convert.ToBoolean(Eval("IsLocked")) ? "opacity:0.6;" : "" %>">
                    <%-- Accent bar --%>
                    <div style="position:absolute;top:0;left:0;right:0;height:3px;
                                background:<%# Eval("AccentColour") %>;"></div>
                    <div style="padding-top:4px;">
                        <div class="cp-flex-between cp-mb-sm">
                            <h3 class="cp-card-title" style="margin:0;">
                                <%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %>
                            </h3>
                            <%# Convert.ToBoolean(Eval("IsFoundation"))
                                ? "<span class='cp-badge cp-badge-green'>Free</span>"
                                : Convert.ToBoolean(Eval("IsLocked"))
                                    ? "<span class='cp-badge cp-badge-grey'>&#x1F512; Locked</span>"
                                    : "<span class='cp-badge cp-badge-blue'>Available</span>" %>
                        </div>
                        <p class="cp-card-subtitle">
                            <%# HttpUtility.HtmlEncode(Eval("Description") != null ? Eval("Description").ToString() : "") %>
                        </p>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-bottom:12px;">
                            &#x1F4D6; <%# Eval("ModuleCount") %> modules
                            <%# Convert.ToInt32(Eval("CertCount")) > 0
                                ? " &nbsp;&#x1F3C5; Certification available" : "" %>
                        </div>
                        <%# Convert.ToBoolean(Eval("IsLocked"))
                            ? "<a href='#' class='cp-btn cp-btn-ghost' style='pointer-events:none;'>&#x1F512; Upgrade to unlock</a>"
                            : "<a href='MyLearning.aspx?pathwayID=" + Eval("PathwayID") + "' class='cp-btn cp-btn-primary'>View Modules</a>" %>
                    </div>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                </div>
            </FooterTemplate>
        </asp:Repeater>
    </asp:Panel>

    <%-- Empty state --%>
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x25B6;</span>
            <h3>No pathways available</h3>
            <p>Pathways will appear here once they are published by an instructor.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
