<%@ Page Title="Pathway" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="PathwayDetail.aspx.cs"
    Inherits="CloudPhoria.Student.PathwayDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.pw-hero{background:linear-gradient(135deg,#0F172A 0%,#1E293B 60%,#0F172A 100%);
    padding:40px 32px;color:#fff;border-radius:0;margin:-24px -32px 24px;position:relative;overflow:hidden;}
.pw-hero::before{content:'';position:absolute;inset:0;
    background-image:linear-gradient(rgba(14,165,233,0.03) 1px,transparent 1px),
    linear-gradient(90deg,rgba(14,165,233,0.03) 1px,transparent 1px);
    background-size:40px 40px;pointer-events:none;}
.pw-hero a{color:#38BDF8;font-size:13px;text-decoration:none;position:relative;z-index:1;}
.pw-hero h1{font-size:34px;font-weight:800;margin:12px 0 10px;position:relative;z-index:1;}
.pw-hero p{font-size:14px;color:rgba(255,255,255,0.65);max-width:640px;line-height:1.7;margin:0 0 20px;position:relative;z-index:1;}
.pw-hero-meta{display:flex;gap:20px;flex-wrap:wrap;font-size:13px;color:rgba(255,255,255,0.5);position:relative;z-index:1;margin-bottom:20px;}
.pw-hero-meta span{display:flex;align-items:center;gap:5px;}
.pw-enroll-btn{display:inline-block;padding:12px 28px;background:linear-gradient(90deg,#0EA5E9,#6366F1);
    color:#fff;font-size:14px;font-weight:600;border-radius:8px;text-decoration:none;
    transition:opacity 0.15s,transform 0.15s;position:relative;z-index:1;border:none;cursor:pointer;}
.pw-enroll-btn:hover{opacity:0.9;transform:translateY(-1px);color:#fff;text-decoration:none;}
.pw-enroll-btn:disabled{opacity:0.5;cursor:not-allowed;transform:none;}

/* Sections */
.pw-section{margin-bottom:28px;}
.pw-section h2{font-size:18px;font-weight:700;color:#172033;margin:0 0 16px;display:flex;align-items:center;gap:8px;}

/* Module cards */
.pw-mod-list{display:flex;flex-direction:column;gap:12px;}
.pw-mod-card{background:#fff;border:1px solid #E2E8F0;border-radius:12px;padding:18px 20px;
    display:flex;align-items:center;gap:16px;transition:border-color 0.15s,transform 0.15s;
    text-decoration:none;color:inherit;}
.pw-mod-card:hover{border-color:#0EA5E9;transform:translateY(-1px);text-decoration:none;color:inherit;}
.pw-mod-num{width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,#0EA5E9,#6366F1);
    display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:700;color:#fff;flex-shrink:0;}
.pw-mod-info{flex:1;min-width:0;}
.pw-mod-name{font-size:14px;font-weight:600;color:#172033;}
.pw-mod-sub{font-size:12px;color:#64748B;margin-top:3px;}
.pw-mod-badge{font-size:11px;}

/* Certification preview */
.pw-cert-card{background:linear-gradient(135deg,#F0F9FF,#EEF2FF);border:2px solid #0EA5E9;
    border-radius:14px;padding:28px;text-align:center;position:relative;overflow:hidden;}
.pw-cert-card::before{content:'';position:absolute;inset:0;
    background:radial-gradient(circle at 50% 0%,rgba(14,165,233,0.08),transparent 60%);pointer-events:none;}
.pw-cert-icon{font-size:48px;margin-bottom:12px;display:block;position:relative;z-index:1;}
.pw-cert-name{font-size:18px;font-weight:700;color:#172033;margin:0 0 8px;position:relative;z-index:1;}
.pw-cert-desc{font-size:13px;color:#64748B;max-width:400px;margin:0 auto;line-height:1.6;position:relative;z-index:1;}

/* Exam info */
.pw-exam-card{background:#fff;border:1px solid #E2E8F0;border-radius:12px;padding:20px;
    border-left:4px solid #6366F1;}
.pw-exam-card h3{font-size:15px;font-weight:700;margin:0 0 10px;color:#172033;}
.pw-exam-details{display:flex;gap:20px;flex-wrap:wrap;font-size:13px;color:#64748B;}

/* Progress */
.pw-progress-card{background:#fff;border:1px solid #E2E8F0;border-radius:12px;padding:20px;}
.pw-progress-label{display:flex;justify-content:space-between;font-size:13px;color:#64748B;margin-bottom:8px;}
.pw-progress-bar-wrap{background:#E2E8F0;border-radius:6px;height:10px;overflow:hidden;}
.pw-progress-bar-fill{background:linear-gradient(90deg,#0EA5E9,#6366F1);height:100%;border-radius:6px;transition:width 0.3s;}

@media(max-width:768px){
    .pw-hero{padding:28px 20px;margin:-16px -16px 16px;}
    .pw-hero h1{font-size:24px;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<%-- Hero --%>
<div class="pw-hero">
    <a href="Pathways.aspx">&#x2190; Back to All Pathways</a>
    <h1><asp:Literal ID="litPathwayName" runat="server" /></h1>
    <p><asp:Literal ID="litDescription" runat="server" /></p>
    <div class="pw-hero-meta">
        <span>&#x1F4D6; <asp:Literal ID="litModuleCount" runat="server" /> Modules</span>
        <span>&#x26A1; <asp:Literal ID="litTotalXP" runat="server" /> Total XP</span>
        <asp:Literal ID="litCertBadge" runat="server" />
        <asp:Literal ID="litFoundationBadge" runat="server" />
    </div>
    <asp:Panel ID="pnlEnroll" runat="server" Visible="false">
        <asp:Button ID="btnEnroll" runat="server" Text="&#x25B6; Enroll in Pathway"
            CssClass="pw-enroll-btn" OnClick="btnEnroll_Click" />
    </asp:Panel>
    <asp:Panel ID="pnlAlreadyEnrolled" runat="server" Visible="false">
        <span style="background:rgba(34,197,94,0.15);color:#22C55E;padding:8px 18px;border-radius:8px;
            font-size:13px;font-weight:600;position:relative;z-index:1;">
            &#x2713; You are enrolled in this pathway
        </span>
    </asp:Panel>
    <asp:Panel ID="pnlUpgradeNeeded" runat="server" Visible="false">
        <a href="Upgrade.aspx" class="pw-enroll-btn" style="background:linear-gradient(90deg,#F59E0B,#EF4444);text-decoration:none;">
            &#x1F512; Upgrade to Pro to Enroll
        </a>
    </asp:Panel>
</div>

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<%-- Overall Progress --%>
<asp:Panel ID="pnlProgress" runat="server" Visible="false">
    <div class="pw-section">
        <div class="pw-progress-card">
            <div class="pw-progress-label">
                <span>Pathway Progress</span>
                <span><asp:Literal ID="litProgressPct" runat="server" />%</span>
            </div>
            <div class="pw-progress-bar-wrap">
                <div class="pw-progress-bar-fill" id="pwProgressBar" runat="server" style="width:0%;"></div>
            </div>
            <div style="font-size:12px;color:#94A3B8;margin-top:8px;">
                <asp:Literal ID="litProgressDetail" runat="server" />
            </div>
        </div>
    </div>
</asp:Panel>

<%-- Modules --%>
<div class="pw-section">
    <h2>&#x1F4D6; Modules</h2>
    <asp:Panel ID="pnlModules" runat="server" Visible="false">
        <div class="pw-mod-list">
            <asp:Repeater ID="rptModules" runat="server">
                <ItemTemplate>
                    <a href="ModuleDetail.aspx?moduleID=<%# Eval("ModuleID") %>" class="pw-mod-card">
                        <div class="pw-mod-num"><%# Container.ItemIndex + 1 %></div>
                        <div class="pw-mod-info">
                            <div class="pw-mod-name"><%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %></div>
                            <div class="pw-mod-sub">
                                <span style="color:<%# DiffCol(Eval("DifficultyLevel").ToString()) %>;font-weight:600;">
                                    <%# Eval("DifficultyLevel") %></span>
                                &bull; <%# Eval("SubTopicCount") %> subtopics
                                &bull; +<%# Eval("XPReward") %> XP
                            </div>
                        </div>
                        <span class="pw-mod-badge cp-badge cp-badge-<%# Eval("BadgeColour") %>"><%# Eval("StatusText") %></span>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoModules" runat="server" Visible="false">
        <div style="text-align:center;padding:32px;color:#64748B;font-size:13px;">
            No modules published for this pathway yet.
        </div>
    </asp:Panel>
</div>

<%-- Pathway Exam Info --%>
<asp:Panel ID="pnlExamInfo" runat="server" Visible="false">
    <div class="pw-section">
        <h2>&#x1F4CB; Pathway Examination</h2>
        <div class="pw-exam-card" style="margin-bottom:16px;">
            <h3>Complete all modules to unlock the pathway certification exam</h3>
            <div class="pw-exam-details">
                <span>&#x23F1; Avg. Duration: <asp:Literal ID="litExamDuration" runat="server" /> min per module exam</span>
                <span>&#x1F3AF; Avg. Pass Mark: <asp:Literal ID="litExamPass" runat="server" />%</span>
                <span>&#x1F4D6; <asp:Literal ID="litExamModules" runat="server" /> module exams required</span>
            </div>
        </div>

        <%-- Per-module exam list --%>
        <asp:Panel ID="pnlModuleExams" runat="server" Visible="false">
            <div class="pw-mod-list">
                <asp:Repeater ID="rptModuleExams" runat="server">
                    <ItemTemplate>
                        <div class="pw-mod-card" style="cursor:default;">
                            <div class="pw-mod-num" style="background:linear-gradient(135deg,#6366F1,#8B5CF6);font-size:16px;">
                                &#x1F4DD;
                            </div>
                            <div class="pw-mod-info">
                                <div class="pw-mod-name"><%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %></div>
                                <div class="pw-mod-sub">
                                    <%# Eval("ExamDurationMinutes") %> min &bull;
                                    Pass mark: <%# Eval("ExamPassMarkPercent") %>% &bull;
                                    +<%# Eval("XPReward") %> XP
                                </div>
                            </div>
                            <%# Convert.ToBoolean(Eval("IsPassed"))
                                ? "<span class='cp-badge cp-badge-green'>&#x2713; Passed</span>"
                                : Convert.ToBoolean(Eval("CanTakeExam"))
                                    ? "<a href='ExamStart.aspx?moduleID=" + Eval("ModuleID") + "' class='cp-btn cp-btn-primary cp-btn-sm'>Start Exam</a>"
                                    : "<span class='cp-badge cp-badge-grey' title='Complete all subtopics first'>&#x1F512; Locked</span>" %>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>
    </div>
</asp:Panel>

<%-- Certification --%>
<asp:Panel ID="pnlCertification" runat="server" Visible="false">
    <div class="pw-section">
        <h2>&#x1F3C5; Certification</h2>
        <div class="pw-cert-card">
            <span class="pw-cert-icon">&#x1F3C6;</span>
            <div class="pw-cert-name"><asp:Literal ID="litCertName" runat="server" /></div>
            <div class="pw-cert-desc">
                Complete all modules and pass all module exams in this pathway to earn your certification.
                This certification validates your expertise and can be shared on your profile.
            </div>
            <asp:Panel ID="pnlCertEarned" runat="server" Visible="false">
                <div style="margin-top:16px;padding:10px 20px;background:rgba(34,197,94,0.12);
                    border-radius:8px;display:inline-block;color:#16A34A;font-weight:600;font-size:13px;">
                    &#x2713; You have earned this certification!
                </div>
            </asp:Panel>
        </div>
    </div>
</asp:Panel>

</asp:Content>
