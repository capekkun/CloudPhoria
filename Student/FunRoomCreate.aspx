<%@ Page Title="Create Fun Room" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="FunRoomCreate.aspx.cs"
    Inherits="CloudPhoria.Student.FunRoomCreate" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>&#x1F3AE; Create a Fun Room</h2>
        <p>Create a quiz room for others to enjoy. It will be reviewed by an admin before going live.</p>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success cp-mb-md">
            <asp:Literal ID="litSuccess" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlForm" runat="server">
    <div class="cp-card" style="max-width:700px;">
        <div class="cp-form-group">
            <label class="cp-label">Room Title <span class="required">*</span></label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="cp-input" MaxLength="150"
                placeholder="e.g. Cloud Computing Trivia" />
            <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                ControlToValidate="txtTitle" CssClass="cp-form-error"
                ErrorMessage="Title is required." Display="Dynamic" />
        </div>

        <div class="cp-form-group">
            <label class="cp-label">Description</label>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="cp-input" TextMode="MultiLine"
                Rows="3" MaxLength="2000"
                placeholder="Describe what your fun room is about..." />
        </div>

        <h3 style="font-size:15px;font-weight:700;margin:24px 0 12px;">Questions (add up to 10)</h3>
        <p style="font-size:13px;color:#64748B;margin:0 0 16px;">
            Each question needs 4 options. Mark the correct answer.
        </p>

        <div id="questionsContainer">
            <div class="fun-q-block" style="background:#F8FAFC;border:1px solid #E2E8F0;border-radius:10px;padding:16px;margin-bottom:14px;">
                <div class="cp-form-group" style="margin-bottom:10px;">
                    <label class="cp-label">Question 1 <span class="required">*</span></label>
                    <asp:TextBox ID="txtQ1" runat="server" CssClass="cp-input" MaxLength="500"
                        placeholder="Enter question text" />
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
                    <asp:TextBox ID="txtQ1O1" runat="server" CssClass="cp-input" placeholder="Option A (correct)" MaxLength="300" />
                    <asp:TextBox ID="txtQ1O2" runat="server" CssClass="cp-input" placeholder="Option B" MaxLength="300" />
                    <asp:TextBox ID="txtQ1O3" runat="server" CssClass="cp-input" placeholder="Option C" MaxLength="300" />
                    <asp:TextBox ID="txtQ1O4" runat="server" CssClass="cp-input" placeholder="Option D" MaxLength="300" />
                </div>
                <p style="font-size:11px;color:#64748B;margin:6px 0 0;">Option A is always the correct answer.</p>
            </div>

            <div class="fun-q-block" style="background:#F8FAFC;border:1px solid #E2E8F0;border-radius:10px;padding:16px;margin-bottom:14px;">
                <div class="cp-form-group" style="margin-bottom:10px;">
                    <label class="cp-label">Question 2</label>
                    <asp:TextBox ID="txtQ2" runat="server" CssClass="cp-input" MaxLength="500"
                        placeholder="Enter question text (optional)" />
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
                    <asp:TextBox ID="txtQ2O1" runat="server" CssClass="cp-input" placeholder="Option A (correct)" MaxLength="300" />
                    <asp:TextBox ID="txtQ2O2" runat="server" CssClass="cp-input" placeholder="Option B" MaxLength="300" />
                    <asp:TextBox ID="txtQ2O3" runat="server" CssClass="cp-input" placeholder="Option C" MaxLength="300" />
                    <asp:TextBox ID="txtQ2O4" runat="server" CssClass="cp-input" placeholder="Option D" MaxLength="300" />
                </div>
                <p style="font-size:11px;color:#64748B;margin:6px 0 0;">Option A is always the correct answer.</p>
            </div>

            <div class="fun-q-block" style="background:#F8FAFC;border:1px solid #E2E8F0;border-radius:10px;padding:16px;margin-bottom:14px;">
                <div class="cp-form-group" style="margin-bottom:10px;">
                    <label class="cp-label">Question 3</label>
                    <asp:TextBox ID="txtQ3" runat="server" CssClass="cp-input" MaxLength="500"
                        placeholder="Enter question text (optional)" />
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
                    <asp:TextBox ID="txtQ3O1" runat="server" CssClass="cp-input" placeholder="Option A (correct)" MaxLength="300" />
                    <asp:TextBox ID="txtQ3O2" runat="server" CssClass="cp-input" placeholder="Option B" MaxLength="300" />
                    <asp:TextBox ID="txtQ3O3" runat="server" CssClass="cp-input" placeholder="Option C" MaxLength="300" />
                    <asp:TextBox ID="txtQ3O4" runat="server" CssClass="cp-input" placeholder="Option D" MaxLength="300" />
                </div>
                <p style="font-size:11px;color:#64748B;margin:6px 0 0;">Option A is always the correct answer.</p>
            </div>
        </div>

        <div style="margin-top:20px;display:flex;gap:10px;">
            <asp:Button ID="btnCreate" runat="server" Text="Submit for Review"
                CssClass="cp-btn cp-btn-primary" OnClick="btnCreate_Click" />
            <a href="FunRooms.aspx" class="cp-btn cp-btn-ghost">Cancel</a>
        </div>
    </div>
    </asp:Panel>

</asp:Content>
