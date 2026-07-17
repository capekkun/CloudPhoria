using System;
using System.Web.UI;

namespace CloudPhoria
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Mark this as a public page so the Master Page skips the auth check.
            SiteMaster master = (SiteMaster)this.Master;
            if (master != null)
            {
                master.IsPublicPage = true;
            }
        }
    }
}
