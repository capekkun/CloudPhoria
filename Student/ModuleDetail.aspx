<%@ Page Title="Module" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="ModuleDetail.aspx.cs"
    Inherits="CloudPhoria.Student.ModuleDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.mod-hero{background:linear-gradient(135deg,#0F172A 0%,#1E293B 60%,#0F172A 100%);
    padding:32px;color:#fff;border-radius:0;margin:-24px -32px 24px;position:relative;overflow:hidden;}
.mod-hero::before{content:'';position:absolute;inset:0;
    background-image:linear-gradient(rgba(14,165,233,0.03) 1px,transparent 1px),
    linear-gradient(90deg,rgba(14,165,233,0.03) 1px,transparent 1px);
    background-size:40px 40px;pointer-events:none;}
.mod-hero a{color:#38BDF8;font-size:13px;text-decoration:none;position:relative;z-index:1;}
.mod-hero h1{font-size:32px;font-weight:800;margin:12px 0 8px;position:relative;z-index:1;}
.mod-hero p{font-size:14px;color:rgba(255,255,255,0.6);max-width:600px;line-height:1.7;margin:0 0 16px;position:relative;z-index:1;}
.mod-meta{display:flex;gap:16px;flex-wrap:wrap;font-size:13px;color:rgba(255,255,255,0.5);position:relative;z-index:1;}
.mod-meta span{display:flex;align-items:center;gap:4px;}

/* Subtopic list */
.st-list{display:flex;flex-direction:column;gap:0;}
.st-item{display:flex;align-items:flex-start;gap:16px;padding:18px 20px;
    border-bottom:1px solid #E2E8F0;transition:background 0.12s;}
.st-item:hover{background:#F8FAFC;}
.st-item:last-child{border-bottom:none;}
.st-ico{width:40px;height:40px;border-radius:50%;display:flex;align-items:center;
    justify-content:center;flex-shrink:0;font-size:18px;}
.st-ico-done{background:rgba(34,197,94,0.12);color:#22C55E;}
.st-ico-progress{background:rgba(14,165,233,0.12);color:#0EA5E9;}
.st-ico-locked{background:rgba(100,116,139,0.08);color:#94A3B8;}
.st-name{font-size:14px;font-weight:600;color:#172033;}
.st-desc{font-size:12px;color:#64748B;margin-top:3px;line-height:1.5;}
.st-xp{font-size:11px;color:#F59E0B;font-weight:700;margin-top:4px;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<%-- Dark hero --%>
<div class="mod-hero">
    <a href="Pathways.aspx">&#x2190; Back to Learning Pathways</a>
    <h1><asp:Literal ID="litModuleName" runat="server" /></h1>
    <p><asp:Literal ID="litModuleDesc" runat="server" /></p>
    <div class="mod-meta">
        <span>&#x1F4DA; <asp:Literal ID="litPathway" runat="server" /></span>
        <span style="color:<asp:Literal ID='litDiffColour' runat='server' />;font-weight:600;">
            <asp:Literal ID="litDifficulty" runat="server" /></span>
        <span>&#x26A1; +<asp:Literal ID="litXP" runat="server" /> XP</span>
        <span>&#x1F4D6; <asp:Literal ID="litSubCount" runat="server" /> subtopics</span>
    </div>
</div>

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<%-- Progress bar --%>
<asp:Panel ID="pnlProgress" runat="server" Visible="false">
    <div class="cp-card cp-mb-lg">
        <div class="cp-progress-label">
            <span>Module Progress</span>
            <span><asp:Literal ID="litProgressPct" runat="server" />%</span>
        </div>
        <div class="cp-progress-wrap">
            <div class="cp-progress-bar" id="progressBar" runat="server" style="width:0%;"></div>
        </div>
    </div>
</asp:Panel>

<%-- Subtopics list --%>
<div class="cp-card" style="padding:0;overflow:hidden;">
    <div style="padding:16px 20px;border-bottom:1px solid #E2E8F0;">
        <h3 style="margin:0;font-size:16px;font-weight:700;color:#172033;">Subtopics</h3>
    </div>
    <asp:Panel ID="pnlSubtopics" runat="server" Visible="false">
        <div class="st-list">
            <asp:Repeater ID="rptSubtopics" runat="server">
                <ItemTemplate>
                    <a href="SubTopicView.aspx?subtopicID=<%# Eval("SubTopicID") %>" class="st-item" style="text-decoration:none;color:inherit;">
                        <div class="st-ico <%# Eval("StatusClass") %>">
                            <%# Eval("StatusIcon") %>
                        </div>
                        <div style="flex:1;min-width:0;">
                            <div class="st-name"><%# HttpUtility.HtmlEncode(Eval("SubTopicName").ToString()) %></div>
                            <div class="st-xp">+<%# Eval("XPReward") %> XP</div>
                        </div>
                        <span class="cp-badge cp-badge-<%# Eval("BadgeColour") %>"><%# Eval("StatusText") %></span>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoSubtopics" runat="server" Visible="false">
        <div style="text-align:center;padding:32px;color:#64748B;font-size:13px;">
            No subtopics published yet for this module.
        </div>
    </asp:Panel>
</div>


</asp:Content>
