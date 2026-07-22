<%@ Page Title="Materials" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Materials.aspx.cs"
    Inherits="CloudPhoria.Instructor.Materials" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F4CE; Learning Materials</h2>
                <p>Upload and manage files attached to your subtopics.</p>
            </div>
            <div style="display:flex;gap:8px;">
                <a href="SubTopics.aspx" class="cp-btn cp-btn-ghost">&#x2190; Subtopics</a>
                <asp:Panel ID="pnlUploadBtn" runat="server" Visible="false">
                    <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('uploadModal')">
                        &#x2B06; Upload Material
                    </button>
                </asp:Panel>
            </div>
        </div>
    </div>

    <%-- Subtopic filter --%>
    <div class="cp-card cp-mb-md" style="padding:16px 20px;">
        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
            <label class="cp-label" style="margin:0;white-space:nowrap;" for="<%= ddlSubTopic.ClientID %>">Filter by Subtopic:</label>
            <asp:DropDownList ID="ddlSubTopic" runat="server" CssClass="cp-select"
                              AutoPostBack="true" OnSelectedIndexChanged="ddlSubTopic_Changed"
                              style="max-width:400px;" />
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

    <asp:Panel ID="pnlMaterials" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Learning materials">
                <thead>
                    <tr>
                        <th scope="col">File Name</th>
                        <th scope="col">Subtopic</th>
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
                                    <span style="font-size:16px;margin-right:6px;">&#x1F4C4;</span>
                                    <%# HttpUtility.HtmlEncode(Eval("FileName").ToString()) %>
                                </td>
                                <td style="color:var(--cp-text-muted);font-size:12px;">
                                    <%# HttpUtility.HtmlEncode(Eval("SubTopicName").ToString()) %>
                                </td>
                                <td style="color:var(--cp-text-muted);">
                                    <%# Convert.ToDateTime(Eval("UploadedAt")).ToString("dd MMM yyyy") %>
                                </td>
                                <td>
                                    <asp:LinkButton runat="server"
                                        CommandName="Delete"
                                        CommandArgument='<%# Eval("MaterialID") %>'
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
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4CE;</span>
            <h3>No materials yet</h3>
            <p>Upload files to support your lesson subtopics.</p>
        </div>
    </asp:Panel>

    <%-- Upload Modal --%>
    <div id="uploadModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="uploadTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button" onclick="hideModal('uploadModal')" aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="uploadTitle">Upload Material</h2>

            <div class="cp-alert cp-alert-info" style="margin-bottom:16px;">
                <span>&#x2139;</span>
                <span>Allowed file types: PDF, DOCX, PPTX, TXT, PNG, JPG. Max 10 MB.</span>
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= ddlSubTopicUpload.ClientID %>">Subtopic <span class="required">*</span></label>
                <asp:DropDownList ID="ddlSubTopicUpload" runat="server" CssClass="cp-select" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= fuMaterial.ClientID %>">File <span class="required">*</span></label>
                <asp:FileUpload ID="fuMaterial" runat="server" CssClass="cp-input" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtDescription.ClientID %>">Description (optional)</label>
                <asp:TextBox ID="txtDescription" runat="server" CssClass="cp-input"
                             MaxLength="500" placeholder="Brief note about this file..." />
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('uploadModal')">Cancel</button>
                <asp:Button ID="btnUpload" runat="server" Text="Upload"
                            CssClass="cp-btn cp-btn-primary"
                            OnClick="btnUpload_Click" />
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
