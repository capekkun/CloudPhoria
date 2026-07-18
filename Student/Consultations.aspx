<%@ Page Title="Consultations" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Consultations.aspx.cs"
    Inherits="CloudPhoria.Student.Consultations" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Consultations</h2>
        <p>Browse available instructor consultation slots and book a session.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success cp-mb-md">
            <asp:Literal ID="litSuccess" runat="server" />
        </div>
    </asp:Panel>

    <%-- My bookings --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        My Bookings
    </h3>
    <asp:Panel ID="pnlBookings" runat="server" Visible="false">
        <div class="cp-table-wrap cp-mb-lg">
            <table class="cp-table">
                <thead>
                    <tr><th>Instructor</th><th>Date</th><th>Time</th><th>Status</th><th>Topic</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptBookings" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("InstructorName").ToString()) %></td>
                                <td><%# Convert.ToDateTime(Eval("SlotDate")).ToString("dd MMM yyyy") %></td>
                                <td><%# Eval("StartTime") %> – <%# Eval("EndTime") %></td>
                                <td>
                                    <%# Eval("Status").ToString() == "Confirmed"
                                        ? "<span class='cp-badge cp-badge-green'>Confirmed</span>"
                                        : Eval("Status").ToString() == "Cancelled"
                                            ? "<span class='cp-badge cp-badge-red'>Cancelled</span>"
                                            : "<span class='cp-badge cp-badge-amber'>Pending</span>" %>
                                </td>
                                <td><%# HttpUtility.HtmlEncode(Eval("Topic") != DBNull.Value ? Eval("Topic").ToString() : "—") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoBookings" runat="server" Visible="false">
        <div class="cp-card cp-mb-lg" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">
            You have no consultation bookings yet.
        </div>
    </asp:Panel>

    <%-- Available slots --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        Available Slots
    </h3>
    <asp:Panel ID="pnlSlots" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table">
                <thead>
                    <tr><th>Instructor</th><th>Date</th><th>Time</th><th>Action</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptSlots" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("InstructorName").ToString()) %></td>
                                <td><%# Convert.ToDateTime(Eval("SlotDate")).ToString("dd MMM yyyy") %></td>
                                <td><%# Eval("StartTime") %> – <%# Eval("EndTime") %></td>
                                <td>
                                    <asp:LinkButton runat="server"
                                        CommandArgument='<%# Eval("SlotID") %>'
                                        OnCommand="BookSlot_Command"
                                        CssClass="cp-btn cp-btn-primary cp-btn-sm"
                                        OnClientClick="return confirm('Book this slot?');">
                                        Book
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
        <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">
            No available consultation slots at the moment. Check back later.
        </div>
    </asp:Panel>

</asp:Content>
