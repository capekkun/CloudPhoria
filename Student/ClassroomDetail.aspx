<%@ Page Title="Classroom" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="ClassroomDetail.aspx.cs"
    Inherits="CloudPhoria.Student.ClassroomDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ================================================================
   CLASSROOM — Microsoft Teams-style layout
   ================================================================ */
.teams-layout{display:grid;grid-template-columns:260px 1fr;height:calc(100vh - 80px);
    margin:-24px -32px;overflow:hidden;background:#F5F5F5;}

/* Sidebar */
.teams-sidebar{background:#1E1E2E;color:#fff;display:flex;flex-direction:column;overflow:hidden;}
.teams-sidebar-header{padding:20px 18px 14px;border-bottom:1px solid rgba(255,255,255,0.08);}
.teams-sidebar-header h2{font-size:16px;font-weight:700;margin:0 0 4px;color:#fff;}
.teams-sidebar-header p{font-size:12px;color:rgba(255,255,255,0.5);margin:0;}
.teams-nav{flex:1;padding:10px 8px;overflow-y:auto;}
.teams-nav-item{display:flex;align-items:center;gap:10px;padding:10px 14px;border-radius:8px;
    cursor:pointer;font-size:13px;font-weight:500;color:rgba(255,255,255,0.7);
    transition:all 0.12s;margin-bottom:2px;text-decoration:none;}
.teams-nav-item:hover{background:rgba(255,255,255,0.08);color:#fff;text-decoration:none;}
.teams-nav-item.active{background:rgba(14,165,233,0.2);color:#38BDF8;text-decoration:none;}
.teams-nav-item span.icon{font-size:18px;width:24px;text-align:center;}
.teams-nav-divider{height:1px;background:rgba(255,255,255,0.06);margin:10px 14px;}
.teams-sidebar-footer{padding:14px 18px;border-top:1px solid rgba(255,255,255,0.08);}
.teams-logout{display:flex;align-items:center;gap:8px;padding:10px 14px;border-radius:8px;
    font-size:13px;color:rgba(255,255,255,0.6);cursor:pointer;background:none;border:none;
    width:100%;text-align:left;transition:all 0.12s;font-family:inherit;}
.teams-logout:hover{background:rgba(239,68,68,0.15);color:#EF4444;}

/* Main Content Area */
.teams-main{display:flex;flex-direction:column;overflow:hidden;background:#fff;}
.teams-main-header{padding:16px 24px;border-bottom:1px solid #E5E7EB;background:#fff;
    display:flex;align-items:center;justify-content:space-between;}
.teams-main-header h3{font-size:16px;font-weight:700;color:#111827;margin:0;
    display:flex;align-items:center;gap:8px;}
.teams-main-body{flex:1;overflow-y:auto;padding:0;}

/* Chat Panel */
.teams-chat{display:flex;flex-direction:column;height:100%;}
.teams-chat-messages{flex:1;overflow-y:auto;padding:20px 24px;display:flex;
    flex-direction:column;gap:16px;}
.teams-msg{display:flex;gap:12px;align-items:flex-start;}
.teams-msg-mine{flex-direction:row-reverse;}
.teams-msg-avatar{width:36px;height:36px;border-radius:50%;
    background:linear-gradient(135deg,#6366F1,#8B5CF6);
    display:flex;align-items:center;justify-content:center;
    font-size:12px;font-weight:700;color:#fff;flex-shrink:0;}
.teams-msg-avatar-instructor{background:linear-gradient(135deg,#F59E0B,#EF4444);}
.teams-msg-content{max-width:65%;}
.teams-msg-name{font-size:12px;font-weight:600;color:#374151;margin-bottom:4px;}
.teams-msg-mine .teams-msg-name{text-align:right;color:#6366F1;}
.teams-msg-bubble{background:#F3F4F6;border-radius:0 12px 12px 12px;padding:10px 14px;
    font-size:13px;line-height:1.6;color:#1F2937;word-break:break-word;}
.teams-msg-mine .teams-msg-bubble{background:#6366F1;color:#fff;border-radius:12px 0 12px 12px;}
.teams-msg-time{font-size:11px;color:#9CA3AF;margin-top:4px;}
.teams-msg-mine .teams-msg-time{text-align:right;}
.teams-chat-empty{flex:1;display:flex;align-items:center;justify-content:center;
    flex-direction:column;color:#9CA3AF;text-align:center;padding:40px;}
.teams-chat-empty span{font-size:52px;margin-bottom:12px;display:block;}
.teams-chat-input{display:flex;gap:10px;padding:16px 24px;border-top:1px solid #E5E7EB;
    background:#FAFBFC;}
.teams-chat-input input[type=text]{flex:1;padding:12px 16px;border:1px solid #E5E7EB;
    border-radius:10px;font-size:13px;outline:none;transition:border-color 0.15s;
    font-family:inherit;}
.teams-chat-input input[type=text]:focus{border-color:#6366F1;box-shadow:0 0 0 3px rgba(99,102,241,0.1);}
.teams-chat-send{padding:12px 24px;background:#6366F1;color:#fff;border:none;border-radius:10px;
    font-size:13px;font-weight:600;cursor:pointer;transition:background 0.15s;font-family:inherit;}
.teams-chat-send:hover{background:#4F46E5;}

/* Files Panel */
.teams-file-list{padding:20px 24px;display:flex;flex-direction:column;gap:10px;}
.teams-file-item{display:flex;align-items:center;gap:14px;padding:14px 18px;background:#F9FAFB;
    border:1px solid #E5E7EB;border-radius:10px;transition:border-color 0.15s;}
.teams-file-item:hover{border-color:#6366F1;}
.teams-file-icon{width:42px;height:42px;border-radius:8px;background:linear-gradient(135deg,#EEF2FF,#E0E7FF);
    display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;}
.teams-file-info{flex:1;min-width:0;}
.teams-file-name{font-size:14px;font-weight:600;color:#111827;white-space:nowrap;
    overflow:hidden;text-overflow:ellipsis;}
.teams-file-meta{font-size:12px;color:#6B7280;margin-top:2px;}
.teams-file-empty{text-align:center;padding:60px 24px;color:#9CA3AF;}
.teams-file-empty span{font-size:48px;display:block;margin-bottom:10px;}

/* Assignments Panel */
.teams-asgn-list{padding:20px 24px;display:flex;flex-direction:column;gap:12px;}
.teams-asgn-card{background:#fff;border:1px solid #E5E7EB;border-radius:12px;padding:18px 20px;
    border-left:4px solid #6366F1;transition:box-shadow 0.15s;}
.teams-asgn-card:hover{box-shadow:0 4px 12px rgba(0,0,0,0.06);}
.teams-asgn-title{font-size:15px;font-weight:700;color:#111827;margin:0 0 6px;}
.teams-asgn-meta{display:flex;gap:16px;font-size:12px;color:#6B7280;}
.teams-asgn-due{display:inline-flex;align-items:center;gap:4px;padding:4px 10px;
    background:#FEF3C7;border-radius:6px;font-size:11px;font-weight:600;color:#92400E;}
.teams-asgn-empty{text-align:center;padding:60px 24px;color:#9CA3AF;}
.teams-asgn-empty span{font-size:48px;display:block;margin-bottom:10px;}

/* Members panel */
.teams-members{padding:20px 24px;}
.teams-member-item{display:flex;align-items:center;gap:12px;padding:12px 0;
    border-bottom:1px solid #F3F4F6;}
.teams-member-item:last-child{border-bottom:none;}
.teams-member-avatar{width:38px;height:38px;border-radius:50%;
    background:linear-gradient(135deg,#6366F1,#8B5CF6);
    display:flex;align-items:center;justify-content:center;
    font-size:12px;font-weight:700;color:#fff;}
.teams-member-avatar-inst{background:linear-gradient(135deg,#F59E0B,#EF4444);}
.teams-member-info{flex:1;}
.teams-member-name{font-size:14px;font-weight:600;color:#111827;}
.teams-member-role{font-size:12px;color:#6B7280;}
.teams-member-badge{padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;}
.teams-member-badge-inst{background:#FEF3C7;color:#92400E;}
.teams-member-badge-student{background:#EEF2FF;color:#4338CA;}

/* Responsive */
@media(max-width:768px){
    .teams-layout{grid-template-columns:1fr;height:auto;margin:-16px -16px;}
    .teams-sidebar{display:none;}
    .teams-main{min-height:calc(100vh - 80px);}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger" style="margin:20px;">
        <asp:Literal ID="litError" runat="server" />
    </div>
</asp:Panel>

<asp:Panel ID="pnlContent" runat="server" Visible="false">
<div class="teams-layout">

    <%-- Sidebar --%>
    <div class="teams-sidebar">
        <div class="teams-sidebar-header">
            <h2><asp:Literal ID="litClassName" runat="server" /></h2>
            <p><asp:Literal ID="litInstructor" runat="server" /></p>
        </div>
        <div class="teams-nav">
            <a class="teams-nav-item active" href="javascript:void(0)" onclick="showTeamsPanel('chat',this)">
                <span class="icon">&#x1F4AC;</span> Chat
            </a>
            <a class="teams-nav-item" href="javascript:void(0)" onclick="showTeamsPanel('files',this)">
                <span class="icon">&#x1F4CE;</span> Files & Attachments
            </a>
            <a class="teams-nav-item" href="javascript:void(0)" onclick="showTeamsPanel('assignments',this)">
                <span class="icon">&#x1F4DD;</span> Assignments
            </a>
            <div class="teams-nav-divider"></div>
            <a class="teams-nav-item" href="javascript:void(0)" onclick="showTeamsPanel('members',this)">
                <span class="icon">&#x1F465;</span> Members
            </a>
        </div>
        <div class="teams-sidebar-footer">
            <a href="Classrooms.aspx" class="teams-nav-item" style="margin-bottom:6px;">
                <span class="icon">&#x2190;</span> Back to Classrooms
            </a>
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="teams-logout" OnClick="btnLogout_Click">
                <span style="font-size:16px;">&#x1F6AA;</span> Log Out
            </asp:LinkButton>
        </div>
    </div>

    <%-- Main Content --%>
    <div class="teams-main">

        <%-- Chat Panel --%>
        <div class="teams-panel active" id="panelChat">
            <div class="teams-main-header">
                <h3>&#x1F4AC; Chat</h3>
                <span style="font-size:12px;color:#6B7280;">
                    <asp:Literal ID="litMemberCount" runat="server" /> members
                </span>
            </div>
            <div class="teams-chat">
                <div class="teams-chat-messages" id="chatMessages">
                    <asp:Literal ID="litMessages" runat="server" />
                </div>
                <div class="teams-chat-input">
                    <asp:TextBox ID="txtMessage" runat="server"
                        placeholder="Type a message..."
                        MaxLength="2000" autocomplete="off" />
                    <asp:Button ID="btnSend" runat="server" Text="Send &#x27A4;"
                        CssClass="teams-chat-send" OnClick="btnSend_Click" />
                </div>
            </div>
        </div>

        <%-- Files Panel --%>
        <div class="teams-panel" id="panelFiles">
            <div class="teams-main-header">
                <h3>&#x1F4CE; Files & Attachments</h3>
                <span style="font-size:12px;color:#6B7280;">
                    Shared by instructor
                </span>
            </div>
            <div class="teams-main-body">
                <asp:Literal ID="litFiles" runat="server" />
            </div>
        </div>

        <%-- Assignments Panel --%>
        <div class="teams-panel" id="panelAssignments">
            <div class="teams-main-header">
                <h3>&#x1F4DD; Assignments</h3>
                <span style="font-size:12px;color:#6B7280;">
                    Posted by instructor
                </span>
            </div>
            <div class="teams-main-body">
                <asp:Literal ID="litAssignments" runat="server" />
            </div>
        </div>

        <%-- Members Panel --%>
        <div class="teams-panel" id="panelMembers">
            <div class="teams-main-header">
                <h3>&#x1F465; Members</h3>
            </div>
            <div class="teams-main-body">
                <asp:Literal ID="litMembers" runat="server" />
            </div>
        </div>

    </div>
</div>
</asp:Panel>

<script>
function showTeamsPanel(name, el) {
    // Hide all panels
    var panels = document.querySelectorAll('.teams-panel');
    for (var i = 0; i < panels.length; i++) panels[i].classList.remove('active');
    // Deactivate nav items
    var navs = document.querySelectorAll('.teams-nav-item');
    for (var i = 0; i < navs.length; i++) navs[i].classList.remove('active');
    // Activate
    el.classList.add('active');
    var panelMap = {chat:'panelChat', files:'panelFiles', assignments:'panelAssignments', members:'panelMembers'};
    var panel = document.getElementById(panelMap[name]);
    if (panel) panel.classList.add('active');
    // Scroll chat
    if (name === 'chat') scrollChat();
}
function scrollChat() {
    var el = document.getElementById('chatMessages');
    if (el) el.scrollTop = el.scrollHeight;
}
window.addEventListener('load', scrollChat);
document.addEventListener('DOMContentLoaded', function() {
    var input = document.getElementById('<%= txtMessage.ClientID %>');
    if (input) {
        input.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                document.getElementById('<%= btnSend.ClientID %>').click();
            }
        });
    }
});
</script>
<style>
.teams-panel{display:none;flex-direction:column;height:100%;}
.teams-panel.active{display:flex;}
</style>

</asp:Content>
