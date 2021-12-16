using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.Drawing;
using System.Text;

// using IronPython.Hosting;
// using IronPython.Runtime;
// using IronPython;
// using Microsoft.Scripting.Hosting;
// using Microsoft.Scripting;

namespace OITWS
{
    public partial class CTestCaseList : System.Web.UI.Page
    {
		string m_sDBUser = "";
		string m_sDBPassword = "";
		string m_sDBPath = "";
		string m_sDBName = "";
		string mErrMsg = "";
		string sAppPath = HttpContext.Current.Server.MapPath("~");
        protected void Page_Load(object sender, EventArgs e)
        {

			string response = "";
            Log.ErrorLog("action",Request.Form["action"]);
            Log.ErrorLog("querystring",Request.QueryString["action"]);
            if (Request.Form["action"] != null && Request.Form["action"] != "") {
                if (Request.Form["action"] == "GetTestResultList" ) {
                    response = GetTestResultList(Request.Form);
                }
            }
            

            if (!IsPostBack)
			{
				if(response != ""){
					Response.Clear();
					Response.Write(response);
					Response.End();
				}
			}
        }
		
		public string GetTestResultList(NameValueCollection form)
		{
			int nRetVal = 0;
			string query = "";
			string keyword = form["keyword"];
			CDBHelper dalObj = new CDBHelper();
            
            m_sDBPath = XMLConfig.Get("dbhost0");
            m_sDBName = XMLConfig.Get("dbname0");
            m_sDBUser = XMLConfig.Get("dbuser0");
            m_sDBPassword = XMLConfig.Get("dbpasswd0");
			dalObj.SetDB(m_sDBUser, m_sDBPassword, m_sDBPath, m_sDBName);
			if ( dalObj.Connect() == true ) {
                try{
					NameValueCollection pm = new NameValueCollection();
					if (keyword != null && keyword != "")
					{
						query = "select * from ocr_test where upper(test_desc) like upper(@keyword) order by test_dt desc";
						pm.Add("@keyword", "%"+keyword+"%");
						//nRetVal = dalObj.GetItems2(query, pm, "TestResultList");
						Log.ErrorLog("keyword", keyword);
					}
					else
					{
						query = "select * from ocr_test order by test_dt desc";
						
						Log.ErrorLog("nokeyword", "nokey");
					}
					nRetVal = dalObj.GetItems2(query, pm, "TestResultList");
					Log.ErrorLog("query", query);
				} 
				catch ( Exception ex ) {
                    mErrMsg = ex.ToString();
                    nRetVal = -1;
					}
				}
				
			var id = "";
            var tokenId = "";
            string reqDateTime = "";
            string respDateTime = DateTime.Now.ToString("yyyyMMddhhmmss zzz");

            ResultInfo result = new ResultInfo(id, nRetVal.ToString(), Request.Form["action"], mErrMsg, reqDateTime, respDateTime, tokenId);
                
            dalObj.dic.Add("Result", result);

            string response = CMessageServer.JQSerializern(dalObj.dic);
            return response;
		}
    }
}