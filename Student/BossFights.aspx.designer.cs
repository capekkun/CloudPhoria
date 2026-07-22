namespace CloudPhoria.Student
{
    public partial class BossFights
    {
        protected global::System.Web.UI.WebControls.Panel pnlError;
        protected global::System.Web.UI.WebControls.Literal litError;
        protected global::System.Web.UI.WebControls.Panel pnlRooms;
        protected global::System.Web.UI.WebControls.Repeater rptRooms;
        protected global::System.Web.UI.WebControls.Panel pnlEmpty;
        protected global::System.Web.UI.WebControls.Panel pnlHistory;
        protected global::System.Web.UI.WebControls.Repeater rptHistory;

        // Battle arena
        protected global::System.Web.UI.WebControls.Panel pnlBattle;
        protected global::System.Web.UI.WebControls.Panel pnlBattleStart;
        protected global::System.Web.UI.WebControls.Literal litStartBossName;
        protected global::System.Web.UI.WebControls.Button btnStartBattle;
        protected global::System.Web.UI.WebControls.Panel pnlBattleActive;
        protected global::System.Web.UI.WebControls.Literal litBattleBossName;
        protected global::System.Web.UI.WebControls.Literal litBossHP;
        protected global::System.Web.UI.WebControls.Literal litBossMaxHP;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl bossHPBar;
        protected global::System.Web.UI.WebControls.Literal litPlayerHP;
        protected global::System.Web.UI.WebControls.Literal litPlayerMaxHP;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl playerHPBar;
        protected global::System.Web.UI.WebControls.Literal litBattleQText;
        protected global::System.Web.UI.WebControls.Literal litDragOptions;
        protected global::System.Web.UI.WebControls.HiddenField hdnSelectedOption;
        protected global::System.Web.UI.WebControls.Button btnSubmitAnswer;
        protected global::System.Web.UI.WebControls.Panel pnlTurnResult;
        protected global::System.Web.UI.WebControls.Literal litTurnIcon;
        protected global::System.Web.UI.WebControls.Literal litTurnTitle;
        protected global::System.Web.UI.WebControls.Literal litTurnDesc;
        protected global::System.Web.UI.WebControls.Button btnNextTurn;
        protected global::System.Web.UI.WebControls.Panel pnlBattleResult;
        protected global::System.Web.UI.WebControls.Literal litResultIcon;
        protected global::System.Web.UI.WebControls.Literal litResultTitle;
        protected global::System.Web.UI.WebControls.Literal litResultSub;
        protected global::System.Web.UI.WebControls.Panel pnlResultXP;
        protected global::System.Web.UI.WebControls.Literal litResultXP;
    }
}
