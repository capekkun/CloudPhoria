using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.UI;

namespace CloudPhoria
{
    public class BundleConfig
    {
        public static void RegisterBundles(BundleCollection bundles)
        {
            RegisterJQueryScriptManager();

            // Must be registered here for webopt:BundleReference to resolve it
            bundles.Add(new StyleBundle("~/Content/css").Include(
                            "~/Content/bootstrap.css",
                            "~/Content/Site.css"));

            bundles.Add(new ScriptBundle("~/bundles/WebFormsJs").Include(
                            "~/Scripts/WebForms/WebForms.js",
                            "~/Scripts/WebForms/WebUIValidation.js",
                            "~/Scripts/WebForms/MenuStandards.js",
                            "~/Scripts/WebForms/Focus.js",
                            "~/Scripts/WebForms/GridView.js",
                            "~/Scripts/WebForms/DetailsView.js",
                            "~/Scripts/WebForms/TreeView.js",
                            "~/Scripts/WebForms/WebParts.js"));

            // Order matters here - these scripts depend on each other
            bundles.Add(new ScriptBundle("~/bundles/MsAjaxJs").Include(
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjax.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxApplicationServices.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxTimer.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxWebForms.js"));

            // Switch to a custom build from modernizr.com before shipping to prod
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                            "~/Scripts/modernizr-*"));
        }

        public static void RegisterJQueryScriptManager()
        {
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery",
                new ScriptResourceDefinition
                {
                    Path = "~/scripts/jquery-3.7.0.min.js",
                    DebugPath = "~/scripts/jquery-3.7.0.js",
                    CdnPath = "http://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.7.0.min.js",
                    CdnDebugPath = "http://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.7.0.js"
                });
        }
    }
}