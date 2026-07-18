namespace CloudPhoria.Student
{
    public partial class DiscussionThread
    {
        protected global::System.Web.UI.WebControls.Literal litTitle;
        protected global::System.Web.UI.WebControls.Literal litAuthor;
        protected global::System.Web.UI.WebControls.Literal litDate;
        protected global::System.Web.UI.WebControls.Panel pnlError;
        protected global::System.Web.UI.WebControls.Literal litError;
        protected global::System.Web.UI.WebControls.Panel pnlThread;
        protected global::System.Web.UI.WebControls.Literal litBody;
        protected global::System.Web.UI.WebControls.Panel pnlDeleteThread;
        protected global::System.Web.UI.WebControls.LinkButton btnDeleteThread;
        protected global::System.Web.UI.WebControls.Panel pnlReplies;
        protected global::System.Web.UI.WebControls.Repeater rptReplies;
        protected global::System.Web.UI.WebControls.Panel pnlNoReplies;
        protected global::System.Web.UI.WebControls.Panel pnlReplySuccess;
        protected global::System.Web.UI.WebControls.TextBox txtReply;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvReply;
        protected global::System.Web.UI.WebControls.Button btnPostReply;
    }
}
