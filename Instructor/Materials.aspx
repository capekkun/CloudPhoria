<%@ Page Title="Materials" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Materials.aspx.cs"
    Inherits="CloudPhoria.Instructor.Materials" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* Upload choice cards */
.cp-upload-cards {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-bottom: 28px;
}
@media (max-width: 560px) { .cp-upload-cards { grid-template-columns: 1fr; } }

.cp-upload-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 10px;
    padding: 28px 20px;
    background: var(--cp-surface);
    border: 2px dashed var(--cp-border);
    border-radius: 14px;
    cursor: pointer;
    transition: border-color 0.18s, background 0.18s, transform 0.15s;
    text-align: center;
}
.cp-upload-card:hover {
    border-color: var(--cp-primary);
    background: rgba(14,165,233,0.04);
    transform: translateY(-2px);
}
.cp-upload-card .cp-uc-icon {
    font-size: 36px;
    line-height: 1;
}
.cp-upload-card .cp-uc-title {
    font-size: 15px;
    font-weight: 700;
    color: var(--cp-text);
}
.cp-upload-card .cp-uc-sub {
    font-size: 12px;
    color: var(--cp-text-muted);
}

/* Type badge colours */
.cp-badge-classroom  { background: rgba(139,92,246,0.12); color: #7c3aed; }
.cp-badge-subtopic   { background: rgba(14,165,233,0.12); color: #0284c7; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Page header (no upload button here anymore) --%>
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Learning Materials</h2>
                <p>Upload and manage files for your subtopics and classrooms.</p>
            </div>
            <a href="SubTopics.aspx" class="cp-btn cp-btn-ghost">&#x2190; Subtopics</a>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════
         SECTION 1 — Upload choice cards
    ═══════════════════════════════════════════ --%>
    <div class="cp-upload-cards">

        <%-- Card: Upload for Subtopic --%>
        <asp:Panel ID="pnlSubtopicCard" runat="server">
            <div class="cp-upload-card" role="button" tabindex="0"
                 onclick="showModal('uploadSubtopicModal')"
                 onkeydown="if(event.key==='Enter'||event.key===' ')showModal('uploadSubtopicModal')">
                <div class="cp-uc-icon"></div>
                <div class="cp-uc-title">Upload for Subtopic</div>
                <div class="cp-uc-sub">Attach a file to a specific lesson subtopic</div>
            </div>
        </asp:Panel>

        <%-- Card: Upload for Classroom --%>
        <asp:Panel ID="pnlClassroomCard" runat="server">
            <div class="cp-upload-card" role="button" tabindex="0"
                 onclick="showModal('uploadClassroomModal')"
                 onkeydown="if(event.key==='Enter'||event.key===' ')showModal('uploadClassroomModal')">
                <div class="cp-uc-icon"></div>
                <div class="cp-uc-title">Upload for Classroom</div>
                <div class="cp-uc-sub">Share a file with students in a classroom</div>
            </div>
        </asp:Panel>

    </div>

    <%-- Feedback banners --%>
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span></span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span></span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <%-- ═══════════════════════════════════════════
         SECTION 2 — Filter + Uploaded Materials table
    ═══════════════════════════════════════════ --%>
    <h3 style="font-size:15px;font-weight:700;color:var(--cp-text);margin:0 0 14px;">
        Uploaded Materials
    </h3>

    <%-- Filter row — two dropdowns side by side, wraps on small screens --%>
    <div style="display:flex;flex-wrap:wrap;align-items:center;gap:10px;margin-bottom:16px;">

        <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
            <label class="cp-label" style="margin:0;white-space:nowrap;font-size:13px;"
                   for="<%= ddlTypeFilter.ClientID %>">Type:</label>
            <asp:DropDownList ID="ddlTypeFilter" runat="server" CssClass="cp-select"
                              AutoPostBack="true"
                              OnSelectedIndexChanged="ddlTypeFilter_Changed"
                              style="width:150px;">
                <asp:ListItem Value="All"       Selected="True">All Types</asp:ListItem>
                <asp:ListItem Value="Subtopic">Subtopic</asp:ListItem>
                <asp:ListItem Value="Classroom">Classroom</asp:ListItem>
            </asp:DropDownList>
        </div>

        <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
            <asp:Literal ID="litSecondaryLabel" runat="server" Text="Filter by:" />
            <asp:DropDownList ID="ddlSecondaryFilter" runat="server" CssClass="cp-select"
                              AutoPostBack="true"
                              OnSelectedIndexChanged="ddlSecondaryFilter_Changed"
                              style="width:240px;max-width:100%;overflow:hidden;text-overflow:ellipsis;" />
        </div>

    </div>

    <asp:Panel ID="pnlMaterials" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Uploaded materials">
                <thead>
                    <tr>
                        <th scope="col">File Name</th>
                        <th scope="col">Type</th>
                        <th scope="col">Linked To</th>
                        <th scope="col">Uploaded</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptMaterials" runat="server"
                                  OnItemCommand="rptMaterials_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;">
                                    <span style="font-size:15px;margin-right:6px;" aria-hidden="true">
                                    </span>
                                    <%# HttpUtility.HtmlEncode(Eval("FileName").ToString()) %>
                                </td>
                                <td>
                                    <%# Eval("MaterialType").ToString() == "Classroom"
                                        ? "<span class='cp-badge cp-badge-classroom'>Classroom</span>"
                                        : "<span class='cp-badge cp-badge-subtopic'>Subtopic</span>" %>
                                </td>
                                <td style="color:var(--cp-text-muted);font-size:12px;">
                                    <%# HttpUtility.HtmlEncode(Eval("LinkedTo").ToString()) %>
                                </td>
                                <td style="color:var(--cp-text-muted);font-size:12px;">
                                    <%# Convert.ToDateTime(Eval("UploadedAt")).ToString("dd MMM yyyy") %>
                                </td>
                                <td>
                                    <a href='<%# Eval("FilePath") %>'
                                       target="_blank" rel="noopener noreferrer"
                                       class="cp-btn cp-btn-outline cp-btn-sm"
                                       title="Open in new tab">
                                        View
                                    </a>
                                    <asp:LinkButton runat="server"
                                        CommandName="Delete"
                                        CommandArgument='<%# Eval("RecordID") + "|" + Eval("MaterialType") %>'
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

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <h3>No materials yet</h3>
            <p>Use the cards above to upload files for your subtopics or classrooms.</p>
        </div>
    </asp:Panel>

    <%-- ═══════════════════════════════════════════
         MODAL — Upload for Subtopic
    ═══════════════════════════════════════════ --%>
    <div id="uploadSubtopicModal" class="cp-modal-backdrop" role="dialog"
         aria-modal="true" aria-labelledby="stUploadTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button"
                    onclick="hideModal('uploadSubtopicModal')" aria-label="Close"></button>
            <h2 class="cp-modal-title" id="stUploadTitle">
                Upload for Subtopic
            </h2>

            <div class="cp-alert cp-alert-info" style="margin-bottom:16px;">
                <span>&#x2139;</span>
                <span>Allowed: PDF, DOCX, PPTX, TXT, PNG, JPG &mdash; Max 10 MB</span>
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= ddlSubTopicUpload.ClientID %>">
                    Subtopic <span class="required">*</span>
                </label>
                <asp:DropDownList ID="ddlSubTopicUpload" runat="server" CssClass="cp-select" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= fuMaterial.ClientID %>">
                    File <span class="required">*</span>
                </label>
                <asp:FileUpload ID="fuMaterial" runat="server" CssClass="cp-input" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtDescription.ClientID %>">
                    Description (optional)
                </label>
                <asp:TextBox ID="txtDescription" runat="server" CssClass="cp-input"
                             MaxLength="500" placeholder="Brief note about this file..." />
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost"
                        onclick="hideModal('uploadSubtopicModal')">Cancel</button>
                <asp:Button ID="btnUploadSubtopic" runat="server"
                            Text="Upload"
                            CssClass="cp-btn cp-btn-primary"
                            OnClick="btnUploadSubtopic_Click" />
            </div>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════
         MODAL — Upload for Classroom
    ═══════════════════════════════════════════ --%>
    <div id="uploadClassroomModal" class="cp-modal-backdrop" role="dialog"
         aria-modal="true" aria-labelledby="clUploadTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button"
                    onclick="hideModal('uploadClassroomModal')" aria-label="Close"></button>
            <h2 class="cp-modal-title" id="clUploadTitle">
                Upload for Classroom
            </h2>

            <div class="cp-alert cp-alert-info" style="margin-bottom:16px;">
                <span>&#x2139;</span>
                <span>Allowed: PDF, DOCX, PPTX, TXT, PNG, JPG &mdash; Max 10 MB</span>
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= ddlClassroomUpload.ClientID %>">
                    Classroom <span class="required">*</span>
                </label>
                <asp:DropDownList ID="ddlClassroomUpload" runat="server" CssClass="cp-select" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= fuClassroomMaterial.ClientID %>">
                    File <span class="required">*</span>
                </label>
                <asp:FileUpload ID="fuClassroomMaterial" runat="server" CssClass="cp-input" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtClassroomDescription.ClientID %>">
                    Description (optional)
                </label>
                <asp:TextBox ID="txtClassroomDescription" runat="server" CssClass="cp-input"
                             MaxLength="500" placeholder="Brief note about this file..." />
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost"
                        onclick="hideModal('uploadClassroomModal')">Cancel</button>
                <asp:Button ID="btnUploadClassroom" runat="server"
                            Text="Upload"
                            CssClass="cp-btn cp-btn-primary"
                            OnClick="btnUploadClassroom_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function showModal(id) {
    document.getElementById(id).classList.add('open');
    document.body.style.overflow = 'hidden';
}
function hideModal(id) {
    document.getElementById(id).classList.remove('open');
    document.body.style.overflow = '';
}
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el) {
    el.addEventListener('click', function(e) { if (e.target === el) hideModal(el.id); });
});
</script>
</asp:Content>
