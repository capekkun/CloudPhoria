<%@ Page Title="Consultations" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Consultations.aspx.cs"
    Inherits="CloudPhoria.Instructor.Consultations" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F4C5; Consultations</h2>
                <p>Define your availability slots and manage student bookings.</p>
            </div>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('slotModal')">
                + Add Slot
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

    <%-- Slots --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">My Availability Slots</h3>

    <asp:Panel ID="pnlSlots" runat="server" Visible="false">
        <div class="cp-table-wrap cp-mb-lg">
            <table class="cp-table" role="grid" aria-label="Consultation slots">
                <thead>
                    <tr>
                        <th scope="col">Date</th>
                        <th scope="col">Start</th>
                        <th scope="col">End</th>
                        <th scope="col">Available</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptSlots" runat="server"
                                  OnItemCommand="rptSlots_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;"><%# Convert.ToDateTime(Eval("SlotDate")).ToString("dd MMM yyyy (ddd)") %></td>
                                <td><%# Eval("StartTime") %></td>
                                <td><%# Eval("EndTime") %></td>
                                <td>
                                    <%# Convert.ToBoolean(Eval("IsAvailable"))
                                        ? "<span class='cp-badge cp-badge-green'>Available</span>"
                                        : "<span class='cp-badge cp-badge-grey'>Booked</span>" %>
                                </td>
                                <td>
                                    <asp:LinkButton runat="server"
                                        CommandName="Delete"
                                        CommandArgument='<%# Eval("SlotID") %>'
                                        CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                        OnClientClick="return confirm('Remove this slot?');">
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

    <asp:Panel ID="pnlNoSlots" runat="server" Visible="false">
        <div class="cp-empty-state cp-mb-lg">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4C5;</span>
            <h3>No slots defined</h3>
            <p>Add your available time slots so students can book consultations.</p>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('slotModal')">
                + Add Slot
            </button>
        </div>
    </asp:Panel>

    <%-- Bookings --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">Student Bookings</h3>

    <asp:Panel ID="pnlBookings" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Student bookings">
                <thead>
                    <tr>
                        <th scope="col">Student</th>
                        <th scope="col">Date &amp; Time</th>
                        <th scope="col">Topic</th>
                        <th scope="col">Status</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptBookings" runat="server"
                                  OnItemCommand="rptBookings_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;"><%# HttpUtility.HtmlEncode(Eval("StudentName").ToString()) %></td>
                                <td style="color:var(--cp-text-muted);">
                                    <%# Convert.ToDateTime(Eval("SlotDate")).ToString("dd MMM yyyy") %>
                                    <%# Eval("StartTime") %> &ndash; <%# Eval("EndTime") %>
                                </td>
                                <td><%# Eval("Topic") != DBNull.Value ? HttpUtility.HtmlEncode(Eval("Topic").ToString()) : "<em style='color:var(--cp-text-muted)'>None</em>" %></td>
                                <td>
                                    <%# GetBookingBadge(Eval("Status").ToString()) %>
                                </td>
                                <td>
                                    <%# Eval("Status").ToString() == "Pending" ? "" : "" %>
                                    <asp:LinkButton runat="server"
                                        CommandName="Confirm"
                                        CommandArgument='<%# Eval("BookingID") %>'
                                        CssClass='cp-btn cp-btn-success cp-btn-sm'
                                        Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                        OnClientClick="return confirm('Confirm this booking?');">
                                        Confirm
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server"
                                        CommandName="Cancel"
                                        CommandArgument='<%# Eval("BookingID") %>'
                                        CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                        Visible='<%# Eval("Status").ToString() != "Cancelled" %>'
                                        OnClientClick="return confirm('Cancel this booking?');">
                                        Cancel
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlNoBookings" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x2705;</span>
            <h3>No bookings yet</h3>
            <p>Students will appear here when they book one of your slots.</p>
        </div>
    </asp:Panel>

    <%-- Add Slot Modal --%>
    <div id="slotModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="slotTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button" onclick="hideModal('slotModal')" aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="slotTitle">Add Availability Slot</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtSlotDate.ClientID %>">Date <span class="required">*</span></label>
                <asp:TextBox ID="txtSlotDate" runat="server" CssClass="cp-input" TextMode="Date" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtSlotDate"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="AddSlot" ErrorMessage="Date is required." />
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtStartTime.ClientID %>">Start Time <span class="required">*</span></label>
                    <asp:TextBox ID="txtStartTime" runat="server" CssClass="cp-input" TextMode="Time" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtStartTime"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="AddSlot" ErrorMessage="Start time is required." />
                </div>
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtEndTime.ClientID %>">End Time <span class="required">*</span></label>
                    <asp:TextBox ID="txtEndTime" runat="server" CssClass="cp-input" TextMode="Time" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEndTime"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="AddSlot" ErrorMessage="End time is required." />
                </div>
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('slotModal')">Cancel</button>
                <asp:Button ID="btnAddSlot" runat="server" Text="Add Slot"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="AddSlot"
                            OnClick="btnAddSlot_Click" />
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
