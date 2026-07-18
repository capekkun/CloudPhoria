<%@ Page Title="Learn" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Pathways.aspx.cs"
    Inherits="CloudPhoria.Student.Pathways" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* Dark hero banner */
.learn-hero{background:linear-gradient(135deg,#0F172A 0%,#1E293B 60%,#0F172A 100%);
    padding:48px 32px;color:#fff;border-radius:0;margin:-24px -32px 0;position:relative;overflow:hidden;}
.learn-hero::before{content:'';position:absolute;inset:0;
    background-image:linear-gradient(rgba(14,165,233,0.03) 1px,transparent 1px),
    linear-gradient(90deg,rgba(14,165,233,0.03) 1px,transparent 1px);
    background-size:40px 40px;pointer-events:none;}
.learn-hero h1{font-size:42px;font-weight:800;margin:0 0 12px;position:relative;z-index:1;}
.learn-hero p{font-size:15px;color:rgba(255,255,255,0.6);max-width:540px;line-height:1.7;margin:0 0 28px;position:relative;z-index:1;}
.learn-stats{display:flex;gap:36px;flex-wrap:wrap;position:relative;z-index:1;}
.learn-stat-num{font-size:24px;font-weight:800;color:#fff;display:block;}
.learn-stat-lbl{font-size:12px;color:rgba(255,255,255,0.45);margin-top:2px;display:block;}

/* Tabs */
.learn-tabs{display:flex;gap:0;border-bottom:2px solid #E2E8F0;margin:24px -32px 24px;padding:0 32px;background:#fff;}
.learn-tab{padding:14px 20px;font-size:13.5px;font-weight:500;color:#64748B;cursor:pointer;
    border-bottom:2.5px solid transparent;margin-bottom:-2px;text-decoration:none;transition:color 0.15s;}
.learn-tab:hover{color:#172033;text-decoration:none;}
.learn-tab.active{color:#0EA5E9;border-bottom-color:#0EA5E9;font-weight:600;}

/* Panels */
.learn-panel{display:none;}
.learn-panel.active{display:block;}

/* Pathway grid cards */
.pw-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:18px;}
.pw-card{background:#fff;border:1px solid #E2E8F0;border-radius:14px;padding:0;overflow:hidden;
    transition:box-shadow 0.15s,border-color 0.15s,transform 0.15s;text-decoration:none;color:#172033;display:block;}
.pw-card:hover{box-shadow:0 8px 30px rgba(14,165,233,0.1);border-color:#0EA5E9;transform:translateY(-2px);text-decoration:none;color:#172033;}
.pw-card-top{height:8px;}
.pw-card-body{padding:20px 22px;}
.pw-card-icon{font-size:32px;margin-bottom:12px;display:block;}
.pw-card h3{font-size:16px;font-weight:700;color:#172033;margin:0 0 6px;}
.pw-card p{font-size:13px;color:#64748B;margin:0 0 12px;line-height:1.6;}
.pw-card-meta{font-size:12px;color:#94A3B8;display:flex;gap:12px;margin-bottom:12px;}

/* Module list */
.mod-list{display:flex;flex-direction:column;gap:12px;}
.mod-row{background:#fff;border:1px solid #E2E8F0;border-radius:12px;padding:16px 20px;
    display:flex;align-items:center;gap:16px;transition:border-color 0.15s,transform 0.15s;}
.mod-row:hover{border-color:#0EA5E9;transform:translateY(-1px);}
.mod-ico{width:48px;height:48px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0;}

@media(max-width:768px){
    .learn-hero{padding:32px 20px;margin:-16px -16px 0;}
    .learn-hero h1{font-size:28px;}
    .learn-tabs{margin:16px -16px 16px;padding:0 16px;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<%-- Hero banner --%>
<div class="learn-hero">
    <h1>Learn</h1>
    <p>Master cloud computing through guided pathways, interactive modules, and gamified challenges — at your own pace.</p>
    <div class="learn-stats">
        <div><span class="learn-stat-num"><asp:Literal ID="litPathwayCount" runat="server" Text="7"/>+</span><span class="learn-stat-lbl">Learning Pathways</span></div>
        <div><span class="learn-stat-num"><asp:Literal ID="litModuleCount" runat="server" Text="0"/>+</span><span class="learn-stat-lbl">Cloud Modules</span></div>
        <div><span class="learn-stat-num">6+</span><span class="learn-stat-lbl">Certifications</span></div>
    </div>
</div>

<%-- Tabs --%>
<div class="learn-tabs">
    <a class="learn-tab active" href="javascript:void(0)" onclick="showLearnTab('paths',this)">&#x25B6; Pathways</a>
    <a class="learn-tab" href="javascript:void(0)" onclick="showLearnTab('modules',this)">&#x1F4D6; Modules</a>
    <a class="learn-tab" href="javascript:void(0)" onclick="showLearnTab('progress',this)">&#x1F4CA; My Progress</a>
</div>

<%-- Error --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<%-- Subscription notice --%>
<asp:Panel ID="pnlFreeNotice" runat="server" Visible="false">
    <div class="cp-alert cp-alert-info cp-mb-md">
        You are on the <strong>Free</strong> plan — you can access the Cloud Foundations pathway. Upgrade to unlock all specialisations.
    </div>
</asp:Panel>

<%-- Tab: Pathways --%>
<div id="panel-paths" class="learn-panel active">
    <asp:Panel ID="pnlPathways" runat="server" Visible="false">
        <div class="pw-grid">
            <asp:Repeater ID="rptPathways" runat="server">
                <ItemTemplate>
                    <a class="pw-card" href="MyLearning.aspx?pathwayID=<%# Eval("PathwayID") %>">
                        <div class="pw-card-top" style="background:<%# Eval("AccentColour") %>;"></div>
                        <div class="pw-card-body">
                            <span class="pw-card-icon"><%# Eval("Icon") %></span>
                            <h3><%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %></h3>
                            <p><%# HttpUtility.HtmlEncode(Eval("ShortDesc").ToString()) %></p>
                            <div class="pw-card-meta">
                                <span>&#x1F4D6; <%# Eval("ModuleCount") %> modules</span>
                                <%# Convert.ToInt32(Eval("CertCount")) > 0 ? "<span>&#x1F3C5; Certification</span>" : "" %>
                            </div>
                            <%# Convert.ToBoolean(Eval("IsFoundation"))
                                ? "<span class='cp-badge cp-badge-green'>Free</span>"
                                : Convert.ToBoolean(Eval("IsLocked"))
                                    ? "<span class='cp-badge cp-badge-grey'>&#x1F512; Upgrade</span>"
                                    : "<span class='cp-badge cp-badge-blue'>Available</span>" %>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon">&#x25B6;</span>
            <h3>No pathways available yet</h3>
            <p>Pathways will appear here once they are published.</p>
        </div>
    </asp:Panel>
</div>

<%-- Tab: Modules --%>
<div id="panel-modules" class="learn-panel">
    <asp:Panel ID="pnlModules" runat="server" Visible="false">
        <div class="mod-list">
            <asp:Repeater ID="rptModules" runat="server">
                <ItemTemplate>
                    <div class="mod-row">
                        <div class="mod-ico" style="background:<%# Eval("IconBg") %>;"><%# Eval("ModIcon") %></div>
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:14px;font-weight:600;color:#172033;"><%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %></div>
                            <div style="font-size:12px;color:#64748B;margin-top:3px;">
                                <%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %> &bull;
                                <span style="color:<%# Eval("DiffColour") %>;font-weight:600;"><%# HttpUtility.HtmlEncode(Eval("DifficultyLevel").ToString()) %></span>
                                &bull; +<%# Eval("XPReward") %> XP
                            </div>
                        </div>
                        <span class="cp-badge cp-badge-blue"><%# Eval("SubTopicCount") %> subtopics</span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
</div>

<%-- Tab: My Progress --%>
<div id="panel-progress" class="learn-panel">
    <asp:Panel ID="pnlProgress" runat="server" Visible="false">
        <asp:Repeater ID="rptProgress" runat="server">
            <ItemTemplate>
                <div class="mod-row">
                    <div class="mod-ico" style="background:rgba(14,165,233,0.1);">&#x1F4D6;</div>
                    <div style="flex:1;min-width:0;">
                        <div style="font-size:14px;font-weight:600;color:#172033;"><%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %></div>
                        <div style="font-size:12px;color:#64748B;margin-top:3px;"><%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %></div>
                        <div class="cp-progress-wrap" style="margin-top:8px;">
                            <div class="cp-progress-bar" style="width:<%# Eval("ProgressPct") %>%;"></div>
                        </div>
                    </div>
                    <span class="cp-badge cp-badge-<%# Eval("Status").ToString() == "Completed" ? "green" : "blue" %>">
                        <%# Eval("Status") %>
                    </span>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlNoProgress" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon">&#x1F4CA;</span>
            <h3>No progress yet</h3>
            <p>Start a module to track your learning progress here.</p>
        </div>
    </asp:Panel>
</div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function showLearnTab(id, tab) {
    var panels = document.querySelectorAll('.learn-panel');
    for (var i=0;i<panels.length;i++) panels[i].classList.remove('active');
    var tabs = document.querySelectorAll('.learn-tab');
    for (var i=0;i<tabs.length;i++) tabs[i].classList.remove('active');
    document.getElementById('panel-'+id).classList.add('active');
    tab.classList.add('active');
}
</script>
</asp:Content>
