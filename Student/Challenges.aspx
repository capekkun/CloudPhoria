<%@ Page Title="Challenges" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Challenges.aspx.cs"
    Inherits="CloudPhoria.Student.Challenges" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .quiz-arena { background:#111827; border-radius:16px; padding:32px; color:#fff; }
    .quiz-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
    .quiz-progress { font-size:13px; color:rgba(255,255,255,0.5); font-weight:600; }
    .quiz-timer { font-size:20px; font-weight:800; color:#F59E0B; font-variant-numeric:tabular-nums; }
    .quiz-q-text { font-size:17px; font-weight:600; text-align:center; margin:0 0 24px; line-height:1.5; }
    .quiz-options { display:grid; grid-template-columns:repeat(2,1fr); gap:14px; max-width:520px; margin:0 auto; }
    .quiz-opt { padding:16px 18px; background:rgba(255,255,255,0.06); border:2px solid rgba(255,255,255,0.12);
        border-radius:10px; font-size:14px; font-weight:600; cursor:pointer; text-align:center;
        transition:all 0.15s; user-select:none; }
    .quiz-opt:hover { border-color:#6366F1; background:rgba(99,102,241,0.15); }
    .quiz-opt.selected { border-color:#6366F1; background:rgba(99,102,241,0.25); }
    .quiz-result-msg { text-align:center; padding:20px; }
    .quiz-result-msg .icon { font-size:40px; margin-bottom:8px; display:block; }
    .quiz-final { text-align:center; padding:20px; }
    .leaderboard-row { display:flex; align-items:center; justify-content:space-between; padding:10px 16px;
        border-bottom:1px solid var(--cp-border); font-size:13px; }
    .leaderboard-rank { font-weight:800; width:28px; }
    @media(max-width:600px) { .quiz-options { grid-template-columns:1fr; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- ============== LEADERBOARD-ONLY VIEW (?leaderboard=) ============== --%>
    <asp:Panel ID="pnlLeaderboardOnlyView" runat="server" Visible="false">
        <div class="cp-page-header">
            <h2>Leaderboard &mdash; <asp:Literal ID="litLeaderboardOnlyTitle" runat="server" /></h2>
            <p><a href="Challenges.aspx">&#x2190; Back to Challenges</a></p>
        </div>
    </asp:Panel>

    <%-- ============== CHALLENGE INTRO / RESULT SCREEN (?challengeID=) ============== --%>
    <asp:Panel ID="pnlIntro" runat="server" Visible="false">
        <div class="cp-page-header">
            <h2><asp:Literal ID="litIntroTitle" runat="server" /></h2>
            <p><asp:Literal ID="litIntroDesc" runat="server" /></p>
        </div>

        <asp:Panel ID="pnlIntroMessage" runat="server" Visible="false">
            <div class="cp-card" style="text-align:center;padding:24px;">
                <p style="margin:0 0 12px;color:var(--cp-text-muted);"><asp:Literal ID="litIntroMessage" runat="server" /></p>
                <a href="Challenges.aspx" class="cp-btn cp-btn-outline cp-btn-sm">&#x2190; Back to Challenges</a>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlStartBtn" runat="server" Visible="false">
            <div class="cp-card" style="text-align:center;padding:24px;">
                <p style="margin:0 0 8px;">
                    <asp:Literal ID="litIntroQCount" runat="server" /> questions &bull;
                    <span class="cp-xp-chip">+<asp:Literal ID="litIntroXP" runat="server" /> XP on completion</span>
                </p>
                <p style="font-size:12px;color:var(--cp-text-muted);margin:0 0 16px;">
                    Each question has its own timer. You get one attempt at this challenge — answer carefully!
                </p>
                <asp:Button ID="btnStartChallenge" runat="server" Text="Start Challenge"
                            CssClass="cp-btn cp-btn-primary" OnClick="btnStartChallenge_Click" />
            </div>
        </asp:Panel>
    </asp:Panel>

    <%-- ============== QUIZ ARENA ============== --%>
    <asp:Panel ID="pnlQuiz" runat="server" Visible="false">
        <div class="quiz-arena">

            <asp:Panel ID="pnlQuizAnswer" runat="server" Visible="false">
                <div class="quiz-header">
                    <span class="quiz-progress"><asp:Literal ID="litQuizProgress" runat="server" /></span>
                    <span class="quiz-timer" id="quizTimer">--</span>
                </div>

                <div class="quiz-q-text"><asp:Literal ID="litQuizQText" runat="server" /></div>

                <div class="quiz-options" id="quizOptions">
                    <asp:Literal ID="litQuizOptions" runat="server" />
                </div>

                <asp:HiddenField ID="hdnSelectedOption" runat="server" />
                <div style="text-align:center;margin-top:20px;">
                    <asp:Button ID="btnSubmitChAnswer" runat="server" Text="Submit Answer"
                                CssClass="cp-btn cp-btn-primary" OnClick="btnSubmitChAnswer_Click" />
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlQuizResult" runat="server" Visible="false">
                <div class="quiz-result-msg">
                    <span class="icon"><asp:Literal ID="litQuizResultIcon" runat="server" /></span>
                    <h3 style="margin:0 0 6px;"><asp:Literal ID="litQuizResultTitle" runat="server" /></h3>
                    <p style="color:rgba(255,255,255,0.5);margin:0 0 20px;"><asp:Literal ID="litQuizResultDesc" runat="server" /></p>
                    <asp:Button ID="btnNextChQuestion" runat="server" Text="Next Question &#x2192;"
                                CssClass="cp-btn cp-btn-primary" OnClick="btnNextChQuestion_Click" />
                </div>
            </asp:Panel>

        </div>
    </asp:Panel>

    <%-- ============== FINAL RESULT + LEADERBOARD ============== --%>
    <asp:Panel ID="pnlFinalResult" runat="server" Visible="false">
        <div class="cp-card quiz-final">
            <span style="font-size:48px;display:block;margin-bottom:12px;"></span>
            <h2 style="margin:0 0 8px;">Challenge Complete!</h2>
            <p style="font-size:24px;font-weight:800;color:var(--cp-primary);margin:0 0 4px;">
                <asp:Literal ID="litFinalScore" runat="server" /> points
            </p>
            <p style="font-size:14px;color:var(--cp-text-muted);margin:0 0 20px;">
                +<asp:Literal ID="litFinalXP" runat="server" /> XP earned
            </p>
            <a href="Challenges.aspx" class="cp-btn cp-btn-outline cp-btn-sm">&#x2190; Back to Challenges</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlLeaderboard" runat="server" Visible="false">
        <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:20px 0 12px;">
            Top 10 Leaderboard
        </h3>
        <div class="cp-card" style="padding:8px 16px;">
            <asp:Repeater ID="rptLeaderboard" runat="server">
                <ItemTemplate>
                    <div class="leaderboard-row">
                        <span>
                            <span class="leaderboard-rank"><%# Container.ItemIndex + 1 %>.</span>
                            <%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %>
                        </span>
                        <span style="font-weight:700;color:var(--cp-primary);"><%# Eval("Score") %> pts</span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <%-- ============== CHALLENGE LISTING (default view) ============== --%>
    <asp:Panel ID="pnlListingView" runat="server" Visible="true">
    <div class="cp-page-header">
        <h2>Challenges</h2>
        <p>Time-limited challenges to test your cloud knowledge and earn XP.</p>
    </div>

    <%-- Active challenges --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        Active Challenges
    </h3>
    <asp:Panel ID="pnlActive" runat="server" Visible="false">
        <div class="cp-grid-2">
            <asp:Repeater ID="rptActive" runat="server">
                <ItemTemplate>
                    <div class="cp-card">
                        <div class="cp-flex-between cp-mb-sm">
                            <h3 class="cp-card-title" style="margin:0;">
                                <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                            </h3>
                            <span class="cp-xp-chip">+<%# Eval("XPReward") %> XP</span>
                        </div>
                        <p class="cp-card-subtitle">
                            <%# HttpUtility.HtmlEncode(Eval("Description") != null ? Eval("Description").ToString() : "") %>
                        </p>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-bottom:8px;">
                            Ends: <%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy HH:mm") %>
                            &bull; <%# Eval("QuestionCount") %> question(s)
                        </div>
                        <div style="display:flex;gap:8px;align-items:center;">
                        <%# Convert.ToBoolean(Eval("HasParticipated"))
                            ? "<span class='cp-badge cp-badge-green'>Participated</span>"
                            : Session["UserID"] != null
                                ? (Convert.ToInt32(Eval("QuestionCount")) > 0
                                    ? "<a href='Challenges.aspx?challengeID=" + Eval("ChallengeID") + "' class='cp-btn cp-btn-primary cp-btn-sm'>Join Challenge</a>"
                                    : "<span class='cp-badge cp-badge-grey'>No questions yet</span>")
                                : "<a href='/Register.aspx' class='cp-btn cp-btn-outline cp-btn-sm'>Register to Join</a>" %>
                        <a href='Challenges.aspx?leaderboard=<%# Eval("ChallengeID") %>' class="cp-btn cp-btn-ghost cp-btn-sm">Leaderboard</a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoActive" runat="server" Visible="false">
        <div class="cp-empty-state">
            <h3>No active challenges</h3>
            <p>Check back soon — new challenges are added regularly.</p>
        </div>
    </asp:Panel>

    <%-- Past participation --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:24px 0 12px;">
        My Participation
    </h3>
    <asp:Panel ID="pnlPast" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table">
                <thead>
                    <tr>
                        <th>Challenge</th>
                        <th>Score</th>
                        <th>Completed</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptPast" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %></td>
                                <td><%# Eval("Score") %></td>
                                <td><%# Eval("CompletedAt") != DBNull.Value
                                        ? Convert.ToDateTime(Eval("CompletedAt")).ToString("dd MMM yyyy")
                                        : "—" %></td>
                                <td><a href='Challenges.aspx?leaderboard=<%# Eval("ChallengeID") %>' class="cp-btn cp-btn-ghost cp-btn-sm">Leaderboard</a></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoPast" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;font-size:13px;color:var(--cp-text-muted);">
            You haven't participated in any challenges yet.
        </div>
    </asp:Panel>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
(function () {
    var optionsWrap = document.getElementById('quizOptions');
    var hdnField = document.getElementById('<%= hdnSelectedOption.ClientID %>');
    if (!optionsWrap) return;

    optionsWrap.addEventListener('click', function (e) {
        var opt = e.target.closest('.quiz-opt');
        if (!opt) return;
        document.querySelectorAll('.quiz-opt').forEach(function (o) { o.classList.remove('selected'); });
        opt.classList.add('selected');
        hdnField.value = opt.getAttribute('data-val');
    });

    window.startChallengeTimer = function (seconds) {
        var display = document.getElementById('quizTimer');
        if (!display) return;
        var remaining = seconds;
        display.textContent = remaining + 's';
        if (window.chTimerInterval) clearInterval(window.chTimerInterval);
        window.chTimerInterval = setInterval(function () {
            remaining--;
            display.textContent = remaining + 's';
            if (remaining <= 5) display.style.color = '#EF4444';
            if (remaining <= 0) {
                clearInterval(window.chTimerInterval);
                hdnField.value = hdnField.value || '0';
                var submitBtn = document.getElementById('<%= btnSubmitChAnswer.ClientID %>');
                if (submitBtn) submitBtn.click();
            }
        }, 1000);
    };
})();
</script>
</asp:Content>
