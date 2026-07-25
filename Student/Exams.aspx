<%@ Page Title="Module Exams" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Exams.aspx.cs"
    Inherits="CloudPhoria.Student.Exams" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .examq-arena { background:#111827; border-radius:16px; padding:32px; color:#fff; }
    .examq-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
    .examq-progress { font-size:13px; color:rgba(255,255,255,0.5); font-weight:600; }
    .examq-timer { font-size:20px; font-weight:800; color:#F59E0B; font-variant-numeric:tabular-nums; }
    .examq-q-text { font-size:17px; font-weight:600; text-align:center; margin:0 0 24px; line-height:1.5; }
    .examq-options { display:grid; grid-template-columns:repeat(2,1fr); gap:14px; max-width:520px; margin:0 auto; }
    .examq-opt { padding:16px 18px; background:rgba(255,255,255,0.06); border:2px solid rgba(255,255,255,0.12);
        border-radius:10px; font-size:14px; font-weight:600; cursor:pointer; text-align:center;
        transition:all 0.15s; user-select:none; }
    .examq-opt:hover { border-color:#6366F1; background:rgba(99,102,241,0.15); }
    .examq-opt.selected { border-color:#6366F1; background:rgba(99,102,241,0.25); }
    .examq-final { text-align:center; padding:20px; }
    @media(max-width:600px) { .examq-options { grid-template-columns:1fr; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- ============== EXAM INTRO / LOCKED MESSAGE (?moduleID=) ============== --%>
    <asp:Panel ID="pnlExamIntro" runat="server" Visible="false">
        <div class="cp-page-header">
            <h2><asp:Literal ID="litExamIntroTitle" runat="server" /></h2>
            <p>Duration: <asp:Literal ID="litExamIntroDuration" runat="server" /> min &bull;
               Pass mark: <asp:Literal ID="litExamIntroPassMark" runat="server" />%</p>
        </div>

        <asp:Panel ID="pnlExamIntroMessage" runat="server" Visible="false">
            <div class="cp-card" style="text-align:center;padding:24px;">
                <p style="margin:0 0 12px;color:var(--cp-text-muted);"><asp:Literal ID="litExamIntroMessage" runat="server" /></p>
                <a href="Exams.aspx" class="cp-btn cp-btn-outline cp-btn-sm">&#x2190; Back to Exams</a>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlExamStartBtn" runat="server" Visible="false">
            <div class="cp-card" style="text-align:center;padding:24px;">
                <p style="margin:0 0 8px;">
                    <asp:Literal ID="litExamIntroQCount" runat="server" /> questions &bull;
                    <span class="cp-xp-chip">+<asp:Literal ID="litExamIntroXP" runat="server" /> XP on pass</span>
                </p>
                <p style="font-size:12px;color:var(--cp-text-muted);margin:0 0 16px;">
                    The timer starts as soon as you click Start and keeps running even if you leave the page.
                    Once started, this attempt counts — answer carefully.
                </p>
                <asp:Button ID="btnStartExam" runat="server" Text="Start Exam"
                            CssClass="cp-btn cp-btn-primary" OnClick="btnStartExam_Click" />
            </div>
        </asp:Panel>
    </asp:Panel>

    <%-- ============== EXAM ARENA ============== --%>
    <asp:Panel ID="pnlExamArena" runat="server" Visible="false">
        <div class="examq-arena">
            <asp:Panel ID="pnlExamAnswer" runat="server" Visible="false">
                <div class="examq-header">
                    <span class="examq-progress"><asp:Literal ID="litExamProgress" runat="server" /></span>
                    <span class="examq-timer" id="examTimer">--</span>
                </div>

                <div class="examq-q-text"><asp:Literal ID="litExamQText" runat="server" /></div>

                <div class="examq-options" id="examOptions">
                    <asp:Literal ID="litExamOptions" runat="server" />
                </div>

                <asp:HiddenField ID="hdnExamSelectedOption" runat="server" />
                <div style="text-align:center;margin-top:20px;">
                    <asp:Button ID="btnSubmitExamAnswer" runat="server" Text="Submit Answer"
                                CssClass="cp-btn cp-btn-primary" OnClick="btnSubmitExamAnswer_Click" />
                </div>
            </asp:Panel>
        </div>
    </asp:Panel>

    <%-- ============== FINAL RESULT ============== --%>
    <asp:Panel ID="pnlExamFinalResult" runat="server" Visible="false">
        <div class="cp-card examq-final">
            <span style="font-size:48px;display:block;margin-bottom:12px;"><asp:Literal ID="litExamFinalIcon" runat="server" /></span>
            <h2 style="margin:0 0 8px;"><asp:Literal ID="litExamFinalTitle" runat="server" /></h2>
            <p style="font-size:24px;font-weight:800;color:var(--cp-primary);margin:0 0 4px;">
                <asp:Literal ID="litExamFinalScore" runat="server" />%
            </p>
            <p style="font-size:14px;color:var(--cp-text-muted);margin:0 0 8px;">
                <asp:Literal ID="litExamFinalCorrect" runat="server" /> / <asp:Literal ID="litExamFinalTotal" runat="server" /> correct
            </p>
            <asp:Panel ID="pnlExamFinalXP" runat="server" Visible="false">
                <p style="font-size:14px;color:var(--cp-text-muted);margin:0 0 8px;">
                    +<asp:Literal ID="litExamFinalXP" runat="server" /> XP earned
                </p>
            </asp:Panel>
            <asp:Panel ID="pnlExamFinalExpiredNote" runat="server" Visible="false">
                <p style="font-size:12px;color:var(--cp-warning);margin:0 0 16px;">
                    <asp:Literal ID="litExamFinalExpiredNote" runat="server" />
                </p>
            </asp:Panel>
            <a href="Exams.aspx" class="cp-btn cp-btn-outline cp-btn-sm">&#x2190; Back to Exams</a>
        </div>
    </asp:Panel>

    <%-- ============== EXAM LISTING (default view) ============== --%>
    <asp:Panel ID="pnlListing" runat="server" Visible="true">
    <div class="cp-page-header">
        <h2>Module Exams</h2>
        <p>Take timed module exams to earn XP and badges. Pass mark and duration vary by module.</p>
    </div>

    <%-- Available exams --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        Available Exams
    </h3>
    <asp:Panel ID="pnlAvailable" runat="server" Visible="false">
        <asp:Repeater ID="rptAvailable" runat="server">
            <ItemTemplate>
                <div class="cp-module-card">
                    <div class="cp-flex-between">
                        <div>
                            <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                                &#x23F1; <%# Eval("ExamDurationMinutes") %> min
                                &bull; Pass: <%# Eval("ExamPassMarkPercent") %>%
                                &bull; Reward: <span class="cp-xp-chip" style="font-size:11px;">+<%# Eval("XPReward") %> XP</span>
                            </div>
                        </div>
                        <%# Convert.ToBoolean(Eval("IsUnlocked"))
                            ? "<a href='Exams.aspx?moduleID=" + Eval("ModuleID") + "' class='cp-btn cp-btn-primary cp-btn-sm'>Start Exam</a>"
                            : "<span class='cp-badge cp-badge-grey' title='Complete all subtopics first'>Locked</span>" %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlNoAvailable" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;font-size:13px;color:var(--cp-text-muted);">
            No exams available. Complete modules to unlock their exams.
        </div>
    </asp:Panel>

    <%-- Past attempts --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:24px 0 12px;">
        Past Attempts
    </h3>
    <asp:Panel ID="pnlHistory" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table">
                <thead>
                    <tr>
                        <th>Module</th>
                        <th>Date</th>
                        <th>Score</th>
                        <th>Result</th>
                        <th>XP Awarded</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptHistory" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %></td>
                                <td><%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy") %></td>
                                <td><%# Eval("ScorePercent") %>%</td>
                                <td>
                                    <%# Convert.ToBoolean(Eval("IsPassed"))
                                        ? "<span class='cp-badge cp-badge-green'>Passed</span>"
                                        : "<span class='cp-badge cp-badge-red'>Failed</span>" %>
                                </td>
                                <td>
                                    <%# Convert.ToInt32(Eval("XPAwarded")) > 0
                                        ? "<span class='cp-xp-chip'>+" + Eval("XPAwarded") + " XP</span>"
                                        : "—" %>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoHistory" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;font-size:13px;color:var(--cp-text-muted);">
            No exam attempts yet.
        </div>
    </asp:Panel>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
(function () {
    var optionsWrap = document.getElementById('examOptions');
    var hdnField = document.getElementById('<%= hdnExamSelectedOption.ClientID %>');
    if (!optionsWrap) return;

    optionsWrap.addEventListener('click', function (e) {
        var opt = e.target.closest('.examq-opt');
        if (!opt) return;
        document.querySelectorAll('.examq-opt').forEach(function (o) { o.classList.remove('selected'); });
        opt.classList.add('selected');
        hdnField.value = opt.getAttribute('data-val');
    });

    window.startExamTimer = function (seconds) {
        var display = document.getElementById('examTimer');
        if (!display) return;
        var remaining = seconds;

        function render() {
            var m = Math.floor(remaining / 60);
            var s = remaining % 60;
            display.textContent = m + ':' + (s < 10 ? '0' : '') + s;
        }
        render();

        if (window.examTimerInterval) clearInterval(window.examTimerInterval);
        window.examTimerInterval = setInterval(function () {
            remaining--;
            render();
            if (remaining <= 60) display.style.color = '#EF4444';
            if (remaining <= 0) {
                clearInterval(window.examTimerInterval);
                hdnField.value = hdnField.value || '0';
                var submitBtn = document.getElementById('<%= btnSubmitExamAnswer.ClientID %>');
                if (submitBtn) submitBtn.click();
            }
        }, 1000);
    };
})();
</script>
</asp:Content>
