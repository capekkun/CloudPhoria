<%@ Page Title="Welcome" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CloudPhoria._Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="body-content">
        <main>
            <section aria-labelledby="welcomeTitle">
                <h1 id="welcomeTitle">Welcome to CloudPhoria</h1>
                <p class="lead">A gamified cloud-computing learning platform for students and professionals.</p>
                <p>
                    <a href="LogIn.aspx" class="cp-btn cp-btn-primary">Log In to Get Started</a>
                </p>
            </section>
        </main>
    </div>
</asp:Content>
