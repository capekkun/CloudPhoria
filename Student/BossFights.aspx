<%@ Page Title="Boss Fights" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="BossFights.aspx.cs"
    Inherits="CloudPhoria.Student.BossFights" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .boss-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:18px; }
    .boss-card {
        background:#111827;
        border:1px solid rgba(255,255,255,0.08);
        border-radius:14px;
        padding:20px;
        color:#fff;
        position:relative;
        overflow:hidden;
        transition:border-color 0.15s, transform 0.15s;
    }
    .boss-card:hover { border-color:rgba(220,38,38,0.4); transform:translateY(-2px); }
    .boss-card-glow {
        position:absolute; top:-30px; right:-30px;
        width:100px; height:100px; border-radius:50%;
        background:radial-gradient(circle, rgba(220,38,38,0.15) 0%, transparent 70%);
        pointer-events:none;
    }
    .boss-diff-easy       { color:#22C55E; }
    .boss-diff-medium     { color:#F59E0B; }
    .boss-diff-hard       { color:#EF4444; }
    .boss-diff-legendary  { color:#A855F7; }
    .boss-hp-bar-wrap { background:rgba(255,255,255,0.08); border-radius:4px; height:6px; margin:10px 0; }
    .boss-hp-bar      { height:100%; border-radius:4px; background:linear-gradient(90deg,#EF4444,#F97316); }

    /* ================= BATTLE ARENA (drag & drop) ================= */
    .battle-arena { background:linear-gradient(180deg,#0B0F1A 0%,#1A0A2E 40%,#0B0F1A 100%);
        border-radius:18px; padding:32px; color:#fff; position:relative; overflow:hidden;
        border:1px solid rgba(220,38,38,0.15); }
    .battle-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
    .battle-boss-name { font-size:20px; font-weight:800; }
    .battle-timer { font-size:22px; font-weight:800; color:#F59E0B; font-variant-numeric:tabular-nums; }

    .battle-hp-row { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:24px; }
    .battle-hp-box { background:rgba(255,255,255,0.03); border:1px solid rgba(255,255,255,0.08);
        border-radius:12px; padding:14px 18px; }
    .battle-hp-lbl { font-size:11px; font-weight:700; color:rgba(255,255,255,0.5); text-transform:uppercase;
        margin-bottom:6px; }
    .battle-hp-val { font-size:18px; font-weight:800; margin-bottom:8px; }
    .battle-hp-bar-wrap { height:10px; border-radius:5px; background:rgba(255,255,255,0.08); overflow:hidden; }
    .battle-hp-bar-boss { height:100%; background:linear-gradient(90deg,#EF4444,#F97316); border-radius:5px; transition:width .5s; }
    .battle-hp-bar-player { height:100%; background:linear-gradient(90deg,#0EA5E9,#22C55E); border-radius:5px; transition:width .5s; }

    .battle-q-text { font-size:17px; font-weight:600; text-align:center; margin:0 0 24px; line-height:1.5; }

    /* Drop zone */
    .drop-zone { border:3px dashed rgba(99,102,241,0.4); border-radius:14px; min-height:76px;
        display:flex; align-items:center; justify-content:center; margin:0 auto 28px; max-width:460px;
        background:rgba(99,102,241,0.05); transition:all 0.2s; font-size:13px; color:rgba(255,255,255,0.4); }
    .drop-zone.drag-over { border-color:#6366F1; background:rgba(99,102,241,0.15); transform:scale(1.02); }
    .drop-zone.filled { border-style:solid; border-color:#6366F1; background:rgba(99,102,241,0.1); }
    .drop-zone .dropped-chip { padding:10px 20px; background:#6366F1; color:#fff; border-radius:8px;
        font-weight:700; font-size:14px; }

    /* Draggable options */
    .drag-options { display:grid; grid-template-columns:repeat(2,1fr); gap:14px; max-width:520px; margin:0 auto; }
    .drag-opt { padding:16px 18px; background:rgba(255,255,255,0.06); border:2px solid rgba(255,255,255,0.12);
        border-radius:10px; font-size:14px; font-weight:600; cursor:grab; text-align:center;
        transition:all 0.15s; user-select:none; }
    .drag-opt:hover { border-color:#6366F1; background:rgba(99,102,241,0.15); transform:translateY(-2px); }
    .drag-opt.dragging { opacity:0.3; }
    .drag-opt.used { opacity:0.15; pointer-events:none; }
    .drag-opt.correct-flash { border-color:#22C55E !important; background:rgba(34,197,94,0.25) !important; }
    .drag-opt.wrong-flash { border-color:#EF4444 !important; background:rgba(239,68,68,0.25) !important; }

    .battle-submit-row { text-align:center; margin-top:20px; }
    .battle-start-btn { display:inline-block; padding:16px 44px; background:linear-gradient(135deg,#DC2626,#7C3AED);
        color:#fff; border-radius:12px; font-size:16px; font-weight:800; border:none; cursor:pointer;
        box-shadow:0 8px 30px rgba(220,38,38,0.3); text-transform:uppercase; letter-spacing:0.04em; }
    .battle-turn-msg { text-align:center; padding:20px; }
    .battle-turn-msg .icon { font-size:40px; margin-bottom:8px; display:block; }

    @media(max-width:600px) {
        .drag-options { grid-template-columns:1fr; }
        .battle-hp-row { grid-template-columns:1fr; }
    }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Boss Fights</h2>
        <p>Battle cloud knowledge bosses in timed quiz rooms. Survive their attacks and deal damage with correct answers to win XP.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- Rooms grid --%>
    <asp:Panel ID="pnlRooms" runat="server" Visible="false">
        <div class="boss-grid">
            <asp:Repeater ID="rptRooms" runat="server">
                <ItemTemplate>
                    <div class="boss-card">
                        <div class="boss-card-glow" aria-hidden="true"></div>
                        <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px;">
                            <h3 style="font-size:15px;font-weight:700;margin:0;color:#fff;">
                                <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                            </h3>
                            <span style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.05em;"
                                  class="boss-diff-<%# Eval("DifficultyLevel").ToString().ToLower() %>">
                                <%# HttpUtility.HtmlEncode(Eval("DifficultyLevel").ToString()) %>
                            </span>
                        </div>
                        <div style="font-size:12px;color:rgba(255,255,255,0.5);margin-bottom:8px;">
                            Boss: <strong style="color:#fff;"><%# HttpUtility.HtmlEncode(Eval("BossName").ToString()) %></strong>
                        </div>
                        <div style="font-size:12px;color:rgba(255,255,255,0.4);margin-bottom:4px;">
                            Boss HP: <%# Eval("MaxHP") %>
                        </div>
                        <div class="boss-hp-bar-wrap">
                            <div class="boss-hp-bar" style="width:100%;"></div>
                        </div>
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-top:14px;">
                            <span class="cp-xp-chip">+<%# Eval("XPReward") %> XP on win</span>
                            <%# Convert.ToBoolean(Eval("HasWon"))
                                ? "<span class='cp-badge cp-badge-green'>&#x2713; Defeated</span>"
                                : Session["UserID"] != null
                                    ? "<a href='BossFights.aspx?roomID=" + Eval("RoomID") + "' class='cp-btn cp-btn-danger cp-btn-sm'>&#x1F5F1; Enter Battle</a>"
                                    : "<a href='/Register.aspx' class='cp-btn cp-btn-outline cp-btn-sm'>Register to Battle</a>" %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <%-- ============== DRAG & DROP BATTLE ARENA ============== --%>
    <asp:Panel ID="pnlBattle" runat="server" Visible="false">
        <div class="battle-arena">

            <asp:Panel ID="pnlBattleStart" runat="server">
                <div style="text-align:center;padding:20px 0;">
                    <h2 style="font-size:24px;font-weight:800;margin:0 0 8px;">
                        &#x2694;&#xFE0F; <asp:Literal ID="litStartBossName" runat="server" />
                    </h2>
                    <p style="color:rgba(255,255,255,0.5);font-size:14px;margin:0 0 24px;">
                        Drag the correct answer into the drop zone to deal damage. Wrong answers let the boss attack you!
                    </p>
                    <asp:Button ID="btnStartBattle" runat="server" Text="&#x1F5F1; Start Battle" CssClass="battle-start-btn" OnClick="btnStartBattle_Click" />
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlBattleActive" runat="server" Visible="false">
                <div class="battle-header">
                    <span class="battle-boss-name">&#x1F480; <asp:Literal ID="litBattleBossName" runat="server" /></span>
                    <span class="battle-timer" id="battleTimer">--</span>
                </div>

                <div class="battle-hp-row">
                    <div class="battle-hp-box">
                        <div class="battle-hp-lbl">&#x1F480; Boss HP</div>
                        <div class="battle-hp-val"><asp:Literal ID="litBossHP" runat="server" /> / <asp:Literal ID="litBossMaxHP" runat="server" /></div>
                        <div class="battle-hp-bar-wrap"><div class="battle-hp-bar-boss" id="bossHPBar" runat="server" style="width:100%;"></div></div>
                    </div>
                    <div class="battle-hp-box">
                        <div class="battle-hp-lbl">&#x1F6E1; Your HP</div>
                        <div class="battle-hp-val"><asp:Literal ID="litPlayerHP" runat="server" /> / <asp:Literal ID="litPlayerMaxHP" runat="server" /></div>
                        <div class="battle-hp-bar-wrap"><div class="battle-hp-bar-player" id="playerHPBar" runat="server" style="width:100%;"></div></div>
                    </div>
                </div>

                <div class="battle-q-text"><asp:Literal ID="litBattleQText" runat="server" /></div>

                <div class="drop-zone" id="dropZone">
                    <span id="dropZonePlaceholder">Drag your answer here</span>
                </div>

                <div class="drag-options" id="dragOptions">
                    <asp:Literal ID="litDragOptions" runat="server" />
                </div>

                <asp:HiddenField ID="hdnSelectedOption" runat="server" />
                <asp:Button ID="btnSubmitAnswer" runat="server" style="display:none;" OnClick="btnSubmitAnswer_Click" />
            </asp:Panel>

            <asp:Panel ID="pnlTurnResult" runat="server" Visible="false">
                <div class="battle-turn-msg">
                    <span class="icon"><asp:Literal ID="litTurnIcon" runat="server" /></span>
                    <h3 style="margin:0 0 6px;"><asp:Literal ID="litTurnTitle" runat="server" /></h3>
                    <p style="color:rgba(255,255,255,0.5);margin:0 0 20px;"><asp:Literal ID="litTurnDesc" runat="server" /></p>
                    <asp:Button ID="btnNextTurn" runat="server" Text="Next Question &#x2192;" CssClass="battle-start-btn"
                        style="font-size:14px;padding:12px 32px;" OnClick="btnNextTurn_Click" />
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlBattleResult" runat="server" Visible="false">
                <div class="battle-turn-msg">
                    <span class="icon"><asp:Literal ID="litResultIcon" runat="server" /></span>
                    <h2 style="margin:0 0 8px;"><asp:Literal ID="litResultTitle" runat="server" /></h2>
                    <p style="color:rgba(255,255,255,0.5);margin:0 0 8px;"><asp:Literal ID="litResultSub" runat="server" /></p>
                    <asp:Panel ID="pnlResultXP" runat="server" Visible="false">
                        <div style="font-size:20px;font-weight:800;color:#F59E0B;margin-bottom:20px;">
                            +<asp:Literal ID="litResultXP" runat="server" /> XP Earned!
                        </div>
                    </asp:Panel>
                    <a href="BossFights.aspx" class="battle-start-btn" style="font-size:14px;padding:12px 32px;text-decoration:none;display:inline-block;">
                        Back to Boss Fights
                    </a>
                </div>
            </asp:Panel>

        </div>
    </asp:Panel>

    <script>
    (function () {
        var dropZone = document.getElementById('dropZone');
        var placeholder = document.getElementById('dropZonePlaceholder');
        var hdnField = document.getElementById('<%= hdnSelectedOption.ClientID %>');
        var submitBtn = document.getElementById('<%= btnSubmitAnswer.ClientID %>');
        if (!dropZone) return;

        function attachDragEvents() {
            var opts = document.querySelectorAll('.drag-opt');
            opts.forEach(function (opt) {
                opt.setAttribute('draggable', 'true');
                opt.addEventListener('dragstart', function (e) {
                    e.dataTransfer.setData('text/plain', opt.getAttribute('data-val'));
                    e.dataTransfer.setData('text/label', opt.textContent);
                    opt.classList.add('dragging');
                });
                opt.addEventListener('dragend', function () { opt.classList.remove('dragging'); });

                // Touch/click fallback — tap an option to drop it directly
                opt.addEventListener('click', function () {
                    if (opt.classList.contains('used')) return;
                    dropAnswer(opt.getAttribute('data-val'), opt.textContent, opt);
                });
            });
        }

        dropZone.addEventListener('dragover', function (e) { e.preventDefault(); dropZone.classList.add('drag-over'); });
        dropZone.addEventListener('dragleave', function () { dropZone.classList.remove('drag-over'); });
        dropZone.addEventListener('drop', function (e) {
            e.preventDefault();
            dropZone.classList.remove('drag-over');
            var val = e.dataTransfer.getData('text/plain');
            var label = e.dataTransfer.getData('text/label');
            var el = document.querySelector('.drag-opt[data-val="' + val + '"]');
            dropAnswer(val, label, el);
        });

        function dropAnswer(val, label, el) {
            if (!val) return;
            hdnField.value = val;
            dropZone.classList.add('filled');
            dropZone.innerHTML = "<span class='dropped-chip'>" + label + "</span>";
            document.querySelectorAll('.drag-opt').forEach(function (o) { o.classList.add('used'); });
            if (el) el.classList.add('used');
            if (window.battleTimerInterval) clearInterval(window.battleTimerInterval);
            submitBtn.click();
        }

        attachDragEvents();

        window.startBattleTimer = function (seconds) {
            var display = document.getElementById('battleTimer');
            if (!display) return;
            var remaining = seconds;
            display.textContent = remaining + 's';
            if (window.battleTimerInterval) clearInterval(window.battleTimerInterval);
            window.battleTimerInterval = setInterval(function () {
                remaining--;
                display.textContent = remaining + 's';
                if (remaining <= 5) display.style.color = '#EF4444';
                if (remaining <= 0) {
                    clearInterval(window.battleTimerInterval);
                    hdnField.value = '0';
                    submitBtn.click();
                }
            }, 1000);
        };
    })();
    </script>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F480;</span>
            <h3>No boss fights available</h3>
            <p>Admins publish new boss fight rooms regularly. Check back soon.</p>
        </div>
    </asp:Panel>

    <%-- Battle history --%>
    <asp:Panel ID="pnlHistory" runat="server" Visible="false">
        <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:28px 0 12px;">
            Battle History
        </h3>
        <div class="cp-table-wrap">
            <table class="cp-table">
                <thead>
                    <tr><th>Room</th><th>Result</th><th>XP</th><th>Date</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptHistory" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %></td>
                                <td>
                                    <%# Eval("Status").ToString() == "Won"
                                        ? "<span class='cp-badge cp-badge-green'>Won</span>"
                                        : Eval("Status").ToString() == "Lost"
                                            ? "<span class='cp-badge cp-badge-red'>Lost</span>"
                                            : "<span class='cp-badge cp-badge-grey'>" + HttpUtility.HtmlEncode(Eval("Status").ToString()) + "</span>" %>
                                </td>
                                <td><%# Convert.ToInt32(Eval("XPAwarded")) > 0 ? "+" + Eval("XPAwarded") : "—" %></td>
                                <td><%# Convert.ToDateTime(Eval("StartedAt")).ToString("dd MMM yyyy") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

</asp:Content>
