namespace CloudPhoria.Admin
{
    public partial class Courses
    {
        protected global::System.Web.UI.WebControls.Panel pnlSuccess;
        protected global::System.Web.UI.WebControls.Literal litSuccess;
        protected global::System.Web.UI.WebControls.Panel pnlError;
        protected global::System.Web.UI.WebControls.Literal litError;

        protected global::System.Web.UI.WebControls.Panel pnlModulesSection;
        protected global::System.Web.UI.WebControls.Repeater rptPathwaysAdmin;
        protected global::System.Web.UI.WebControls.DropDownList ddlModulePathway;
        protected global::System.Web.UI.WebControls.TextBox txtModuleName;
        protected global::System.Web.UI.WebControls.TextBox txtModuleDesc;
        protected global::System.Web.UI.WebControls.DropDownList ddlModuleDifficulty;
        protected global::System.Web.UI.WebControls.TextBox txtModuleXP;
        protected global::System.Web.UI.WebControls.TextBox txtModuleExamDuration;
        protected global::System.Web.UI.WebControls.TextBox txtModulePassMark;
        protected global::System.Web.UI.WebControls.Button btnCreateModule;
        protected global::System.Web.UI.WebControls.Repeater rptModulesAdmin;

        protected global::System.Web.UI.WebControls.Panel pnlManageSubTopics;
        protected global::System.Web.UI.WebControls.Literal litManageModuleTitle;
        protected global::System.Web.UI.WebControls.TextBox txtSTName;
        protected global::System.Web.UI.WebControls.TextBox txtSTContent;
        protected global::System.Web.UI.WebControls.TextBox txtSTOrder;
        protected global::System.Web.UI.WebControls.TextBox txtSTXPReward;
        protected global::System.Web.UI.WebControls.Button btnAddSubTopic;
        protected global::System.Web.UI.WebControls.Panel pnlSubTopicsList;
        protected global::System.Web.UI.WebControls.Repeater rptManageSubTopics;
        protected global::System.Web.UI.WebControls.Panel pnlNoSubTopics;

        protected global::System.Web.UI.WebControls.Panel pnlManageQuestions;
        protected global::System.Web.UI.WebControls.Literal litManageSubTopicTitle;
        protected global::System.Web.UI.WebControls.TextBox txtQText;
        protected global::System.Web.UI.WebControls.DropDownList ddlQuestionType;
        protected global::System.Web.UI.WebControls.TextBox txtQXPReward;
        protected global::System.Web.UI.WebControls.TextBox txtQOrder;
        protected global::System.Web.UI.WebControls.TextBox txtQCorrectAnswer;
        protected global::System.Web.UI.WebControls.Panel pnlMCQOptionsAdmin;
        protected global::System.Web.UI.WebControls.Repeater rptQOptions;
        protected global::System.Web.UI.WebControls.Button btnAddQuestion;
        protected global::System.Web.UI.WebControls.Panel pnlQuestionsList;
        protected global::System.Web.UI.WebControls.Repeater rptManageQuestions;
        protected global::System.Web.UI.WebControls.Panel pnlNoQuestions;
    }
}
