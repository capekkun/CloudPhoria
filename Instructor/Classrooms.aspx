<%@ Page Title="Classrooms" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Classrooms.aspx.cs"
    Inherits="CloudPhoria.Instructor.Classrooms" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F3EB; Classrooms</h2>
                <p>Create and manage your instructor-led classrooms.</p>
            </div>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Classroom
            </button>
        </div>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span>&#x2714;</span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span>&#x26A0;</span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <%-- Classroom cards --%>
    <asp:Panel ID="pnlClassrooms" runat="server" Visible="false">
        <asp:Repeater ID="rptClassrooms" runat="server"
                      OnItemCommand="rptClassrooms_ItemCommand">
            <ItemTemplate>
                <div class="cp-card" style="margin-bottom:16px;">
                    <div class="cp-flex-between" style="flex-wrap:wrap;gap:12px;">
                        <div>
                            <div style="font-size:17px;font-weight:700;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("ClassroomName").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                                Invite Code: <strong style="color:var(--cp-primary);letter-spacing:0.08em;">
                                    <%# HttpUtility.HtmlEncode(Eval("InviteCode").ToString()) %>
                                </strong>
                                &bull; Created <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                            <span class="cp-badge cp-badge-indigo">
                                <%# Eval("StudentCount") %> student(s)
                            </span>
                            <a href='Classrooms.aspx?id=<%# Eval("ClassroomID") %>'
                               class="cp-btn cp-btn-outline cp-btn-sm">View Students</a>
                            <asp:LinkButton runat="server"
                                CommandName="Delete"
                                CommandArgument='<%# Eval("ClassroomID") %>'
                                CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                OnClientClick="return confirm('Delete this classroom and all its content?');">
                                Delete
                            </asp:LinkButton>
                        </div>
                    </div>

                    <%-- Show enrolled students if this classroom is expanded --%>
                    <%# Eval("EnrolledHTML") %>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F3EB;</span>
            <h3>No classrooms yet</h3>
            <p>Create a classroom and share the invite code with your students.</p>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Classroom
            </button>
        </div>
    </asp:Panel>

    <%-- Student list panel (when ?id= is provided) --%>
    <asp:Panel ID="pnlStudents" runat="server" Visible="false">
        <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:24px 0 12px;">
            Enrolled Students &mdash;
            <asp:Literal ID="litSelectedClassroom" runat="server" />
        </h3>
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Enrolled students">
                <thead>
                    <tr>
                        <th scope="col">Student Name</th>
                        <th scope="col">Email</th>
                        <th scope="col">Enrolled</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptStudents" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;"><%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %></td>
                                <td style="color:var(--cp-text-muted);"><%# HttpUtility.HtmlEncode(Eval("Email").ToString()) %></td>
                                <td style="color:var(--cp-text-muted);"><%# Convert.ToDateTime(Eval("EnrolledAt")).ToString("dd MMM yyyy") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <%-- Classroom Materials panel (when ?id= is provided) --%>
    <asp:Panel ID="pnlClassroomMaterialsSection" runat="server" Visible="false">
        <div class="cp-page-header-row" style="margin:24px 0 12px;">
            <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0;">
                &#x1F4CE; Classroom Materials
            </h3>
            <button type="button" class="cp-btn cp-btn-primary cp-btn-sm" onclick="showModal('uploadMaterialModal')">
                &#x2B06; Upload Material
            </button>
        </div>

        <asp:Panel ID="pnlClassroomMaterials" runat="server" Visible="false">
            <div class="cp-table-wrap">
                <table class="cp-table" role="grid" aria-label="Classroom materials">
                    <thead>
                        <tr>
                            <th scope="col">File Name</th>
                            <th scope="col">Description</th>
                            <th scope="col">Uploaded</th>
                            <th scope="col">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptClassroomMaterials" runat="server"
                                      OnItemCommand="rptClassroomMaterials_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td style="font-weight:600;">
                                        <span style="font-size:16px;margin-right:6px;">&#x1F4C4;</span>
                                        <%# HttpUtility.HtmlEncode(Eval("FileName").ToString()) %>
                                    </td>
                                    <td style="color:var(--cp-text-muted);font-size:12px;">
                                        <%# Eval("Description") == DBNull.Value ? "&mdash;" : HttpUtility.HtmlEncode(Eval("Description").ToString()) %>
                                    </td>
                                    <td style="color:var(--cp-text-muted);">
                                        <%# Convert.ToDateTime(Eval("UploadedAt")).ToString("dd MMM yyyy") %>
                                    </td>
                                    <td>
                                        <asp:LinkButton runat="server"
                                            CommandName="DeleteMaterial"
                                            CommandArgument='<%# Eval("ClassroomMaterialID") %>'
                                            CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                            OnClientClick="return confirm('Remove this material?');">
                                            Remove
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlNoMaterials" runat="server" Visible="false">
            <div class="cp-empty-state">
                <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4CE;</span>
                <h3>No materials shared yet</h3>
                <p>Upload files for students in this classroom to see under Files & Attachments.</p>
            </div>
        </asp:Panel>
    </asp:Panel>

    <%-- Upload Classroom Material Modal --%>
    <div id="uploadMaterialModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="uploadMaterialTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button" onclick="hideModal('uploadMaterialModal')" aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="uploadMaterialTitle">Upload Classroom Material</h2>

            <div class="cp-alert cp-alert-info" style="margin-bottom:16px;">
                <span>&#x2139;</span>
                <span>Allowed file types: PDF, DOCX, PPTX, TXT, PNG, JPG. Max 10 MB. Students will see this under Files & Attachments in the classroom.</span>
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= fuClassroomMaterial.ClientID %>">File <span class="required">*</span></label>
                <asp:FileUpload ID="fuClassroomMaterial" runat="server" CssClass="cp-input" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtMaterialDescription.ClientID %>">Description (optional)</label>
                <asp:TextBox ID="txtMaterialDescription" runat="server" CssClass="cp-input"
                             MaxLength="500" placeholder="Brief note about this file..." />
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('uploadMaterialModal')">Cancel</button>
                <asp:Button ID="btnUploadMaterial" runat="server" Text="Upload"
                            CssClass="cp-btn cp-btn-primary"
                            OnClick="btnUploadMaterial_Click" />
            </div>
        </div>
    </div>

    <%-- Create Classroom Modal --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="createCTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button" onclick="hideModal('createModal')" aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="createCTitle">New Classroom</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtClassName.ClientID %>">Classroom Name <span class="required">*</span></label>
                <asp:TextBox ID="txtClassName" runat="server" CssClass="cp-input"
                             MaxLength="100" placeholder="e.g. Cloud Basics - Morning Group" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtClassName"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateC" ErrorMessage="Classroom name is required." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtInviteCode.ClientID %>">
                    Invite Code <span class="required">*</span>
                    <span style="font-weight:400;color:var(--cp-text-muted);font-size:11px;">(unique, shared with students)</span>
                </label>
                <asp:TextBox ID="txtInviteCode" runat="server" CssClass="cp-input"
                             MaxLength="20" placeholder="e.g. CLOUD2025A" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtInviteCode"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateC" ErrorMessage="Invite code is required." />
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('createModal')">Cancel</button>
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
function showModal(id) { document.getElementById(id).classList.add('open'); document.body.style.overflow='hidden'; }
function hideModal(id) { document.getElementById(id).classList.remove('open'); document.body.style.overflow=''; }
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el){
    el.addEventListener('click',function(e){ if(e.target===el) hideModal(el.id); });
});
</script>
</asp:Content>
