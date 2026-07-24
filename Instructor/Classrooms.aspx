<%@ Page Title="Classrooms" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Classrooms.aspx.cs"
    Inherits="CloudPhoria.Instructor.Classrooms" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Teams-style chat room ───────────────────────── */
.inst-teams-wrap {
    display: grid;
    grid-template-columns: 220px 1fr;
    height: 620px;
    border: 1px solid var(--cp-border);
    border-radius: 14px;
    overflow: hidden;
    margin-top: 4px;
    background: #fff;
}
.inst-teams-sidebar {
    background: #1E1E2E;
    color: #fff;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}
.inst-teams-sidebar-header {
    padding: 18px 16px 12px;
    border-bottom: 1px solid rgba(255,255,255,0.08);
}
.inst-teams-sidebar-header h3 {
    font-size: 14px; font-weight: 700; margin: 0 0 3px; color: #fff;
}
.inst-teams-sidebar-header p {
    font-size: 11px; color: rgba(255,255,255,0.45); margin: 0;
}
.inst-teams-nav { flex: 1; padding: 8px 6px; overflow-y: auto; }
.inst-teams-nav-item {
    display: flex; align-items: center; gap: 9px;
    padding: 9px 12px; border-radius: 8px; cursor: pointer;
    font-size: 13px; font-weight: 500;
    color: rgba(255,255,255,0.65);
    transition: all 0.12s; margin-bottom: 2px;
    text-decoration: none; background: none; border: none;
    width: 100%; text-align: left; font-family: inherit;
}
.inst-teams-nav-item:hover { background: rgba(255,255,255,0.08); color: #fff; }
.inst-teams-nav-item.active { background: rgba(14,165,233,0.2); color: #38BDF8; }
.inst-teams-nav-item .icon { font-size: 16px; width: 22px; text-align: center; }

/* Main area */
.inst-teams-main { display: flex; flex-direction: column; overflow: hidden; }
.inst-teams-panel { display: none; flex-direction: column; height: 100%; }
.inst-teams-panel.active { display: flex; }
.inst-teams-panel-header {
    padding: 14px 20px;
    border-bottom: 1px solid #E5E7EB;
    display: flex; align-items: center; justify-content: space-between;
    background: #fff; flex-shrink: 0;
}
.inst-teams-panel-header h4 {
    font-size: 14px; font-weight: 700; color: #111827; margin: 0;
}
.inst-teams-panel-body { flex: 1; overflow-y: auto; }

/* Chat */
.inst-chat-messages {
    display: flex; flex-direction: column;
    gap: 14px; padding: 18px 20px;
    min-height: 100%;
}
.inst-msg { display: flex; gap: 10px; align-items: flex-start; }
.inst-msg-mine { flex-direction: row-reverse; }
.inst-msg-avatar {
    width: 32px; height: 32px; border-radius: 50%;
    background: linear-gradient(135deg,#6366F1,#8B5CF6);
    display: flex; align-items: center; justify-content: center;
    font-size: 11px; font-weight: 700; color: #fff; flex-shrink: 0;
}
.inst-msg-avatar-inst { background: linear-gradient(135deg,#F59E0B,#EF4444); }
.inst-msg-content { max-width: 60%; }
.inst-msg-name {
    font-size: 11px; font-weight: 600; color: #374151; margin-bottom: 3px;
}
.inst-msg-mine .inst-msg-name { text-align: right; color: #6366F1; }
.inst-msg-bubble {
    background: #F3F4F6; border-radius: 0 10px 10px 10px;
    padding: 9px 13px; font-size: 13px; line-height: 1.5;
    color: #1F2937; word-break: break-word;
}
.inst-msg-mine .inst-msg-bubble {
    background: #6366F1; color: #fff; border-radius: 10px 0 10px 10px;
}
.inst-msg-time { font-size: 10px; color: #9CA3AF; margin-top: 3px; }
.inst-msg-mine .inst-msg-time { text-align: right; }
.inst-chat-input {
    display: flex; gap: 8px; padding: 14px 20px;
    border-top: 1px solid #E5E7EB; background: #FAFBFC; flex-shrink: 0;
}
.inst-chat-input input[type=text] {
    flex: 1; padding: 10px 14px; border: 1px solid #E5E7EB;
    border-radius: 8px; font-size: 13px; outline: none;
    font-family: inherit; transition: border-color 0.15s;
}
.inst-chat-input input[type=text]:focus {
    border-color: #6366F1; box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
}
.inst-chat-send {
    padding: 10px 20px; background: #6366F1; color: #fff;
    border: none; border-radius: 8px; font-size: 13px;
    font-weight: 600; cursor: pointer; font-family: inherit;
    transition: background 0.15s;
}
.inst-chat-send:hover { background: #4F46E5; }
.inst-chat-empty {
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    height: 100%; color: #9CA3AF; text-align: center; padding: 30px;
}
.inst-chat-empty span { font-size: 40px; display: block; margin-bottom: 10px; }

/* Files & Members */
.inst-file-list { padding: 16px 20px; display: flex; flex-direction: column; gap: 8px; }
.inst-file-item {
    display: flex; align-items: center; gap: 12px;
    padding: 12px 16px; background: #F9FAFB;
    border: 1px solid #E5E7EB; border-radius: 8px;
}
.inst-file-icon {
    width: 38px; height: 38px; border-radius: 7px;
    background: #EEF2FF; display: flex; align-items: center;
    justify-content: center; font-size: 18px; flex-shrink: 0;
}
.inst-file-name { font-size: 13px; font-weight: 600; color: #111827; }
.inst-file-meta { font-size: 11px; color: #6B7280; margin-top: 2px; }
.inst-members-list { padding: 16px 20px; }
.inst-member-item {
    display: flex; align-items: center; gap: 10px;
    padding: 10px 0; border-bottom: 1px solid #F3F4F6;
}
.inst-member-item:last-child { border-bottom: none; }
.inst-member-avatar {
    width: 34px; height: 34px; border-radius: 50%;
    background: linear-gradient(135deg,#6366F1,#8B5CF6);
    display: flex; align-items: center; justify-content: center;
    font-size: 11px; font-weight: 700; color: #fff;
}
.inst-member-avatar-inst { background: linear-gradient(135deg,#F59E0B,#EF4444); }
.inst-member-name { font-size: 13px; font-weight: 600; color: #111827; }
.inst-member-role { font-size: 11px; color: #6B7280; }
.inst-empty-panel {
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; height: 100%;
    color: #9CA3AF; text-align: center; padding: 30px;
}
.inst-empty-panel span { font-size: 40px; display: block; margin-bottom: 10px; }

/* Responsive */
@media (max-width: 680px) {
    .inst-teams-wrap { grid-template-columns: 1fr; height: auto; }
    .inst-teams-sidebar { display: none; }
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Page header --%>
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Classrooms</h2>
                <p>Create and manage your classrooms. Click a classroom to open its chat room.</p>
            </div>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Classroom
            </button>
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span></span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span></span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <%-- ═══ SECTION 1 — Classroom cards ═══ --%>
    <asp:Panel ID="pnlClassrooms" runat="server" Visible="false">
        <asp:Repeater ID="rptClassrooms" runat="server"
                      OnItemCommand="rptClassrooms_ItemCommand">
            <ItemTemplate>
                <div class="cp-card" style="margin-bottom:12px;">
                    <div class="cp-flex-between" style="flex-wrap:wrap;gap:10px;">
                        <div>
                            <div style="font-size:16px;font-weight:700;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("ClassroomName").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                                Invite Code:
                                <strong style="color:var(--cp-primary);letter-spacing:0.08em;">
                                    <%# HttpUtility.HtmlEncode(Eval("InviteCode").ToString()) %>
                                </strong>
                                &bull; Created <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                            <span class="cp-badge cp-badge-indigo">
                                <%# Eval("StudentCount") %> student(s)
                            </span>
                            <asp:LinkButton runat="server"
                                CommandName="OpenChat"
                                CommandArgument='<%# Eval("ClassroomID") + "|" + Eval("ClassroomName") %>'
                                CssClass="cp-btn cp-btn-primary cp-btn-sm">
                                Open Chat
                            </asp:LinkButton>
                            <asp:LinkButton runat="server"
                                CommandName="Delete"
                                CommandArgument='<%# Eval("ClassroomID") %>'
                                CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                OnClientClick="return confirm('Delete this classroom and all its content?');">
                                Delete
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <h3>No classrooms yet</h3>
            <p>Create a classroom and share the invite code with your students.</p>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Classroom
            </button>
        </div>
    </asp:Panel>

    <%-- ═══ SECTION 2 — Chat room ═══ --%>
    <asp:Panel ID="pnlChatRoom" runat="server" Visible="false">

        <hr style="border:none;border-top:2px solid var(--cp-border);margin:24px 0 16px;" />

        <%-- Chat room header --%>
        <div style="display:flex;align-items:center;justify-content:space-between;
                    flex-wrap:wrap;gap:10px;margin-bottom:14px;">
            <div>
                <div style="font-size:11px;font-weight:600;text-transform:uppercase;
                            letter-spacing:0.08em;color:var(--cp-text-muted);margin-bottom:4px;">
                    Classroom Chat
                </div>
                <div style="font-size:18px;font-weight:700;color:var(--cp-text);">
                    <asp:Literal ID="litChatRoomName" runat="server" />
                </div>
            </div>
            <asp:LinkButton ID="btnCloseChat" runat="server"
                CssClass="cp-btn cp-btn-ghost cp-btn-sm"
                OnClick="btnCloseChat_Click">
                Close Chat
            </asp:LinkButton>
        </div>

        <%-- Hidden fields for chat state --%>
        <asp:HiddenField ID="hfChatClassroomID" runat="server" />

        <%-- Teams-style layout --%>
        <div class="inst-teams-wrap">

            <%-- Sidebar nav --%>
            <div class="inst-teams-sidebar">
                <div class="inst-teams-sidebar-header">
                    <h3><asp:Literal ID="litSidebarName" runat="server" /></h3>
                    <p>Classroom</p>
                </div>
                <div class="inst-teams-nav">
                    <button class="inst-teams-nav-item active" type="button"
                            onclick="instShowPanel('chat',this)">
                        <span class="icon"></span> Chat
                    </button>
                    <button class="inst-teams-nav-item" type="button"
                            onclick="instShowPanel('files',this)">
                        <span class="icon"></span> Files &amp; Attachments
                    </button>
                    <button class="inst-teams-nav-item" type="button"
                            onclick="instShowPanel('assignments',this)">
                        <span class="icon"></span> Assignments
                    </button>
                    <button class="inst-teams-nav-item" type="button"
                            onclick="instShowPanel('members',this)">
                        <span class="icon"></span> Members
                    </button>
                </div>
            </div>

            <%-- Main panels --%>
            <div class="inst-teams-main">

                <%-- Chat panel --%>
                <div class="inst-teams-panel active" id="instPanelChat">
                    <div class="inst-teams-panel-header">
                        <h4>Chat</h4>
                        <span style="font-size:11px;color:#6B7280;" id="instMemberCount"></span>
                    </div>
                    <div class="inst-teams-panel-body" id="instChatScroll">
                        <div class="inst-chat-messages" id="instChatMessages">
                            <asp:Literal ID="litMessages" runat="server" />
                        </div>
                    </div>
                    <div class="inst-chat-input">
                        <asp:TextBox ID="txtMessage" runat="server"
                            placeholder="Type a message and press Enter..."
                            MaxLength="2000" autocomplete="off" />
                        <asp:Button ID="btnSend" runat="server" Text="Send"
                            CssClass="inst-chat-send"
                            OnClick="btnSend_Click" />
                    </div>
                </div>

                <%-- Files panel --%>
                <div class="inst-teams-panel" id="instPanelFiles">
                    <div class="inst-teams-panel-header">
                        <h4>Files &amp; Attachments</h4>
                        <a href="Materials.aspx" class="cp-btn cp-btn-outline cp-btn-sm">
                            Manage in Materials Page &#x2192;
                        </a>
                    </div>
                    <div class="inst-teams-panel-body">
                        <asp:Literal ID="litFiles" runat="server" />
                    </div>
                </div>

                <%-- Assignments panel --%>
                <div class="inst-teams-panel" id="instPanelAssignments">
                    <div class="inst-teams-panel-header">
                        <h4>Assignments</h4>
                        <a href="Assignments.aspx" class="cp-btn cp-btn-outline cp-btn-sm">
                            Manage in Assignments Page &#x2192;
                        </a>
                    </div>
                    <div class="inst-teams-panel-body">
                        <asp:Literal ID="litAssignments" runat="server" />
                    </div>
                </div>

                <%-- Members panel --%>
                <div class="inst-teams-panel" id="instPanelMembers">
                    <div class="inst-teams-panel-header">
                        <h4>Members</h4>
                    </div>
                    <div class="inst-teams-panel-body">
                        <asp:Literal ID="litMembers" runat="server" />
                    </div>
                </div>

            </div><%-- end inst-teams-main --%>
        </div><%-- end inst-teams-wrap --%>

    </asp:Panel><%-- end pnlChatRoom --%>

    <%-- Create Classroom Modal --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog"
         aria-modal="true" aria-labelledby="createCTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button"
                    onclick="hideModal('createModal')" aria-label="Close"></button>
            <h2 class="cp-modal-title" id="createCTitle">New Classroom</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtClassName.ClientID %>">
                    Classroom Name <span class="required">*</span>
                </label>
                <asp:TextBox ID="txtClassName" runat="server" CssClass="cp-input"
                             MaxLength="100"
                             placeholder="e.g. Cloud Basics - Morning Group" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtClassName"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateC" ErrorMessage="Classroom name is required." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtInviteCode.ClientID %>">
                    Invite Code <span class="required">*</span>
                    <span style="font-weight:400;color:var(--cp-text-muted);font-size:11px;">
                        (unique, shared with students)
                    </span>
                </label>
                <asp:TextBox ID="txtInviteCode" runat="server" CssClass="cp-input"
                             MaxLength="20" placeholder="e.g. CLOUD2025A" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtInviteCode"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateC" ErrorMessage="Invite code is required." />
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost"
                        onclick="hideModal('createModal')">Cancel</button>
                <asp:Button ID="btnCreate" runat="server" Text="Create Classroom"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="CreateC"
                            OnClick="btnCreate_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
/* ── Modal helpers ─────────────────────────────── */
function showModal(id) {
    document.getElementById(id).classList.add('open');
    document.body.style.overflow = 'hidden';
}
function hideModal(id) {
    document.getElementById(id).classList.remove('open');
    document.body.style.overflow = '';
}
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el) {
    el.addEventListener('click', function(e) {
        if (e.target === el) hideModal(el.id);
    });
});

/* ── Teams panel switcher ──────────────────────── */
function instShowPanel(name, btn) {
    document.querySelectorAll('.inst-teams-panel').forEach(function(p) {
        p.classList.remove('active');
    });
    document.querySelectorAll('.inst-teams-nav-item').forEach(function(b) {
        b.classList.remove('active');
    });
    btn.classList.add('active');
    var map = {
        chat: 'instPanelChat',
        files: 'instPanelFiles',
        assignments: 'instPanelAssignments',
        members: 'instPanelMembers'
    };
    var panel = document.getElementById(map[name]);
    if (panel) panel.classList.add('active');
    if (name === 'chat') scrollChat();
}

/* ── Chat helpers ──────────────────────────────── */
function scrollChat() {
    var el = document.getElementById('instChatScroll');
    if (el) el.scrollTop = el.scrollHeight;
}

/* ── Auto-poll new messages every 3 s ─────────── */
var _lastMsgID  = 0;
var _pollTimer  = null;
var _classroomID = 0;
var _currentUserID = 0;
var _instructorID  = 0;

function startPolling(classroomID, currentUserID, instructorID) {
    _classroomID   = classroomID;
    _currentUserID = currentUserID;
    _instructorID  = instructorID;

    // Seed the lastMsgID from existing rendered messages.
    var msgs = document.querySelectorAll('[data-msgid]');
    msgs.forEach(function(m) {
        var id = parseInt(m.getAttribute('data-msgid'), 10);
        if (id > _lastMsgID) _lastMsgID = id;
    });

    if (_pollTimer) clearInterval(_pollTimer);
    _pollTimer = setInterval(pollMessages, 3000);
}

function stopPolling() {
    if (_pollTimer) { clearInterval(_pollTimer); _pollTimer = null; }
}

function pollMessages() {
    if (!_classroomID) return;
    var url = '<%= ResolveUrl("~/Handlers/ChatMessages.ashx") %>?classroomID='
              + _classroomID + '&afterID=' + _lastMsgID;
    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data || !data.messages || data.messages.length === 0) return;
            var container = document.getElementById('instChatMessages');
            // Remove empty state div if present.
            var empty = container.querySelector('.inst-chat-empty');
            if (empty) empty.parentNode.removeChild(empty);

            data.messages.forEach(function(msg) {
                if (msg.messageID > _lastMsgID) _lastMsgID = msg.messageID;
                var isMine = msg.senderID === _currentUserID;
                var isInst = msg.senderID === _instructorID;
                var msgClass = isMine ? 'inst-msg inst-msg-mine' : 'inst-msg';
                var avClass  = isInst ? 'inst-msg-avatar inst-msg-avatar-inst' : 'inst-msg-avatar';
                var bubbleBadge = isInst && !isMine
                    ? ' <span style="font-size:10px;color:#F59E0B;">Instructor</span>'
                    : '';
                var div = document.createElement('div');
                div.className = msgClass;
                div.setAttribute('data-msgid', msg.messageID);
                div.innerHTML =
                    '<div class="' + avClass + '">' + escHtml(msg.initials) + '</div>' +
                    '<div class="inst-msg-content">' +
                    '<div class="inst-msg-name">' + escHtml(msg.senderName) + bubbleBadge + '</div>' +
                    '<div class="inst-msg-bubble">' + escHtml(msg.messageText) + '</div>' +
                    '<div class="inst-msg-time">' + escHtml(msg.sentAt) + '</div>' +
                    '</div>';
                container.appendChild(div);
            });
            scrollChat();
        })
        .catch(function() { /* silent — poll again next tick */ });
}

function escHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g,'&amp;').replace(/</g,'&lt;')
        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* Enter key sends message */
window.addEventListener('DOMContentLoaded', function() {
    var inp = document.getElementById('<%= txtMessage.ClientID %>');
    if (inp) {
        inp.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                document.getElementById('<%= btnSend.ClientID %>').click();
            }
        });
    }
    scrollChat();
});
</script>
</asp:Content>
