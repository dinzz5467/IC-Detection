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
    public partial class CTestCaseDetails : System.Web.UI.Page
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
            
            if (Request.Form["action"] != null && Request.Form["action"] != "") {
                if (Request.Form["action"] == "UploadImagesLump") {
                    response = UploadImagesLump(Request.Form);
                } else if (Request.Form["action"] == "GetImageDetails" ) {
                    response = GetImageDetails(Request.Form);
                }
                else if (Request.Form["action"] == "RecognizeImage" ) {
                    response = RecognizeImage(Request.Form);
                }
                else if (Request.Form["action"] == "TestResult" ) {
                    response = TestResult(Request.Form);
                }
                else if (Request.Form["action"] == "UploadCameraImage" ) {
                    response = UploadCameraImage(Request.Form);
                }
            }

            if ( Request.QueryString["action"] != null && Request.QueryString["action"] != "" ) {
                if (Request.QueryString["action"] == "StreamFile") {
                    StreamFile(Request.QueryString);
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

		public string TestResult(NameValueCollection form)
		{
            List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            var nvc = new Dictionary<string, object>();
			int nRetVal = 0;
			NameValueCollection parameters = new NameValueCollection();
			string id = form["item_id"];
			string button = form["button"];
			string test_id = form["test_id"];
			string query = "";
			
			CDBHelper dalObj = new CDBHelper();
            
            m_sDBPath = XMLConfig.Get("dbhost0");
            m_sDBName = XMLConfig.Get("dbname0");
            m_sDBUser = XMLConfig.Get("dbuser0");
            m_sDBPassword = XMLConfig.Get("dbpasswd0");
			dalObj.SetDB(m_sDBUser, m_sDBPassword, m_sDBPath, m_sDBName);

			parameters.Add("@id", id);

			if(button == "but_pass_name")
			{
				query = "Update ocr_test_item set name_result = 1 where id =@id ";
			}
			else if(button == "but_pass_ic")
			{
				query = "Update ocr_test_item set ic_no_result = 1 where id =@id ";
			}
			else if(button == "but_pass_address")
			{
				query = "Update ocr_test_item set address_result = 1 where id =@id ";
			}
			else if(button == "but_fail_name")
			{
				query = "Update ocr_test_item set name_result = 0 where id =@id ";
			}
			else if(button == "but_fail_ic")
			{
				query = "Update ocr_test_item set ic_no_result = 0 where id =@id ";
			}
			else if(button == "but_fail_address")
			{
				query = "Update ocr_test_item set address_result = 0 where id =@id ";
			}

            nRetVal = dalObj.UpdateItem(query, parameters);

			parameters.Add("@test_id", test_id);
			query = "SELECT COUNT(id)*3 AS total_test FROM ocr_test_item WHERE test_id = @test_id";
			float total_test = float.Parse(dalObj.GetSingleFieldValue(query, "total_test", parameters));

			query = "select test_id,SUM(ISNULL(CAST(name_result AS float),0)) + SUM(ISNULL(CAST(ic_no_result AS float),0)) + SUM(ISNULL(CAST(address_result AS float),0)) AS total_pass from ocr_test_item where test_id = @test_id group by test_id";
			float total_pass = float.Parse(dalObj.GetSingleFieldValue(query, "total_pass", parameters));

			float accuracy = (total_pass/total_test)*100;

			query = "Update ocr_test set total_test = " + total_test + ", total_passed = " + total_pass + ", total_failed = " + (total_test - total_pass) +", accuracy = "+ accuracy +" where id = @test_id";
			nRetVal = dalObj.UpdateItem2(query, parameters);

            nvc.Add("accuracy", accuracy.ToString());

            query = "SELECT id, name_result, ic_no_result, address_result FROM ocr_test_item WHERE id=@id";
            dalObj.GetItems2(query, parameters);

            List<Dictionary<string, object>> list2 = ( List<Dictionary<string, object>> )dalObj.dic["Item"];

            foreach (KeyValuePair<string, object> entry in list2[0])
            {
                nvc.Add(entry.Key, entry.Value);
            }

            list.Add(nvc);

            dalObj.dic["Item"] = list;

            string response = CMessageServer.JQSerializern(dalObj.dic);
            return response;
		}

        private string UploadImagesLump(NameValueCollection form) {
            List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            var nvc = new Dictionary<string, object>();
			int nRetVal = 0;
            string id = "";

			CDBHelper dalObj = new CDBHelper();
            
            m_sDBPath = XMLConfig.Get("dbhost0");
            m_sDBName = XMLConfig.Get("dbname0");
            m_sDBUser = XMLConfig.Get("dbuser0");
            m_sDBPassword = XMLConfig.Get("dbpasswd0");
			dalObj.SetDB(m_sDBUser, m_sDBPassword, m_sDBPath, m_sDBName);

            try {

                NameValueCollection form3 = new NameValueCollection();  //form for child record

                int i = 0;
                int fcnt = HttpContext.Current.Request.Files.Count;

                for ( i = 0; i < fcnt; i++ ) {

                    var fileContent = HttpContext.Current.Request.Files[i];
					string extension = Path.GetExtension(fileContent.FileName).ToUpper();

					if ( extension != ".PNG"  &&
					     extension != ".JPG") {
						// invalid file type reject igonre the file
						mErrMsg = "Upsupported File";
						nRetVal = -2;
					}

					if (fileContent == null || fileContent.ContentLength <= 0) {	 
						// invalid file type reject igonre the file
						mErrMsg = "Invalid File. File is blank";
						nRetVal = -3;
					}

                    string newFileName = DateTime.Now.ToString("yyyyMMddHHmmss")+"_"+fileContent.FileName;
					string filePath = sAppPath + @"\ocr\App_Data\ocr\images\" + newFileName;

                    form3.Add("file_path_"+i, newFileName);
                    form3.Add("name", null);
                    form3.Add("ic_no", null);
                    form3.Add("address", null);
                    form3.Add("name_result", null);
                    form3.Add("ic_no_result", null);
                    form3.Add("address_result", null);
                    
					fileContent.SaveAs(filePath);

                    nvc.Add("file_name_"+i, newFileName.ToString());

                }

                if ( i == fcnt ) {

                    NameValueCollection form2 = new NameValueCollection();   // form for parent record

                    if ( form["test_id"] == null || form["test_id"] == "" ) {   // new test

                        form2.Add("test_desc", form["test_desc"]);
                        form2.Add("total_image", fcnt.ToString());
                        form2.Add("total_test", null);
                        form2.Add("total_passed", null);
                        form2.Add("total_failed", null);
                        form2.Add("accuracy", null);

                        id = PortletCryto.encrypt(SaveOCRTest(form2));  // encrypted because insertitem = true return id in int

                        nRetVal = 1;    // 1 because insert 1 ocr test

                        form3.Add("test_id", id);

                    } else {    // insert to existing test
                        form3.Add("test_id", form["test_id"].ToString());
                        id = form["test_id"];
                        nRetVal = fcnt; // follow how many pictures inserted

                        form2.Add("total_image", fcnt.ToString());
                        form2.Add("test_id", id);
                        form2.Add("fld_name", "total_image");
                        SaveOCRTest(form2); //update ocr test
                    }

                    if ( nRetVal > 0 ) {
                        try {

                            int ii = 0;
                            for ( ii = 0; ii < i; ii ++ ) {
                                SaveOCRTestItem(form3, ii);
                            }

                        } catch ( Exception ex ) {
                            mErrMsg = ex.ToString();
                            nRetVal = -1;
                        }
                    }
                }

                list.Add(nvc);
                dalObj.dic.Add("Item", list);

            } catch (Exception ex) {
				mErrMsg = ex.ToString();
				nRetVal = -1;
            }

            var tokenId = "";
            string reqDateTime = "";
            string respDateTime = DateTime.Now.ToString("yyyyMMddhhmmss zzz");

            ResultInfo result = new ResultInfo(id, nRetVal.ToString(), Request.Form["action"], mErrMsg, reqDateTime, respDateTime, tokenId);

            dalObj.dic.Add("Result", result);

            string response = CMessageServer.JQSerializern(dalObj.dic);
            return response;
        }

        private void StreamFile(NameValueCollection form) {
            string localPath = HttpContext.Current.Server.MapPath("./");
            string filePath = localPath + @"App_Data\ocr\images\" + form["file_name"];

            FileStream liveStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);

            byte[] buffer = new byte[(int)liveStream.Length];
            liveStream.Read(buffer, 0, (int)liveStream.Length);
            liveStream.Close();

            HttpContext.Current.Response.Clear();
            HttpContext.Current.Response.ContentType = "application/octet-stream";
            HttpContext.Current.Response.BinaryWrite(buffer);
            // HttpContext.Current.ApplicationInstance.CompleteRequest();
            HttpContext.Current.Response.End();
        }

        private string GetImageDetails(NameValueCollection form) {

            int nRetVal = 0;
            string query = "";

            CDBHelper dalObj = new CDBHelper();
            
            m_sDBPath = XMLConfig.Get("dbhost0");
            m_sDBName = XMLConfig.Get("dbname0");
            m_sDBUser = XMLConfig.Get("dbuser0");
            m_sDBPassword = XMLConfig.Get("dbpasswd0");
			dalObj.SetDB(m_sDBUser, m_sDBPassword, m_sDBPath, m_sDBName);

            if ( dalObj.Connect() == true ) {
                try{
                    NameValueCollection pm = new NameValueCollection();
                    query = "SELECT * FROM ocr_test WHERE id = @id";

                    pm.Add("@id", form["id"]);
                    nRetVal = dalObj.GetItems2(query, pm);

                    if ( nRetVal > 0 ) {
                        NameValueCollection pm2 = new NameValueCollection();
                        query = "SELECT * FROM ocr_test_item WHERE test_id = @id";

                        pm2.Add("@id", form["id"]);
                        nRetVal = dalObj.GetItems2(query, pm, "ocr_test_item");
                    }
                    // process sql
                } catch ( Exception ex ) {
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

        public string SaveOCRTest(NameValueCollection form) {
            int nRetVal = 0;
            string query = "";

            CDBHelper dalObj = new CDBHelper();
            
            m_sDBPath = XMLConfig.Get("dbhost0");
            m_sDBName = XMLConfig.Get("dbname0");
            m_sDBUser = XMLConfig.Get("dbuser0");
            m_sDBPassword = XMLConfig.Get("dbpasswd0");

			dalObj.SetDB(m_sDBUser, m_sDBPassword, m_sDBPath, m_sDBName);

            if ( dalObj.Connect() == true ) {
                try{

                    NameValueCollection pm = new NameValueCollection();

                    if ( form["test_id"] != null && form["id"] != "" ) {

                        pm.Add("@test_id", form["test_id"]);

                        string uquery = "";
                        if ( form["fld_name"] == "total_image" ) {

                            query = "SELECT " + form["fld_name"] + " FROM ocr_test WHERE id = @test_id";
                            string prev_total_images = dalObj.GetSingleFieldValue(query, form["fld_name"], pm);

                            uquery += form["fld_name"] + "=" + "@"+form["fld_name"];
                            pm.Add("@"+form["fld_name"], ( Int32.Parse(form[form["fld_name"]] ) + Int32.Parse(prev_total_images) ).ToString() );

                        } else {

                            uquery += form["fld_name"] + "=" + "@"+form["fld_name"];
                            pm.Add("@"+form["fld_name"], form[form["fld_name"]]);

                        }

                        query = "UPDATE ocr_test SET " + uquery + " WHERE id = @test_id";

                        nRetVal = dalObj.UpdateItem2(query, pm);

                    } else {

                    query = "INSERT INTO ocr_test (test_desc, test_dt, total_image, total_test, total_passed, total_failed, accuracy) VALUES (@test_desc, getdate(), @total_image, @total_test, @total_passed, @total_failed, @accuracy)";

                    pm.Add("@test_desc", form["test_desc"]);
                    pm.Add("@total_image", form["total_image"]);
                    pm.Add("@total_test", form["total_test"]);
                    pm.Add("@total_passed", form["total_passed"]);
                    pm.Add("@total_failed", form["total_failed"]);
                    pm.Add("@accuracy", form["accuracy"]);
                    nRetVal = dalObj.InsertItem2(query, pm, true);

                    }

                } catch ( Exception ex ) {
                    mErrMsg = ex.ToString();
                    nRetVal = -1;
                }
            }

            return nRetVal.ToString();
        }

        private int SaveOCRTestItem(NameValueCollection form, int ii) {

            int nRetVal = 0;
            string query = "";

            CDBHelper dalObj = new CDBHelper();
            
            m_sDBPath = XMLConfig.Get("dbhost0");
            m_sDBName = XMLConfig.Get("dbname0");
            m_sDBUser = XMLConfig.Get("dbuser0");
            m_sDBPassword = XMLConfig.Get("dbpasswd0");

			dalObj.SetDB(m_sDBUser, m_sDBPassword, m_sDBPath, m_sDBName);

            if ( dalObj.Connect() == true ) {
                try{

                    NameValueCollection pm = new NameValueCollection();
                    query = "INSERT INTO ocr_test_item (test_id, file_path, name, ic_no, address, name_result, ic_no_result, address_result, test_dt) VALUES ( @test_id, @file_path, @name, @ic_no, @address, @name_result, @ic_no_result, @address_result, getdate())";

                    pm.Add("@test_id", form["test_id"]);
                    pm.Add("@file_path", form["file_path_"+ii]);
                    pm.Add("@name", form["name"]);
                    pm.Add("@ic_no", form["ic_no"]);
                    pm.Add("@address", form["address"]);
                    pm.Add("@name_result", form["name_result"]);
                    pm.Add("@ic_no_result", form["ic_no_result"]);
                    pm.Add("@address_result", form["address_result"]);
                    nRetVal = dalObj.InsertItem2(query, pm, true);

                } catch ( Exception ex ) {
                    mErrMsg = ex.ToString();
                    nRetVal = -1;
                }
            }

            return nRetVal;
        }

        public string RecognizeImage(NameValueCollection form) 
        {
            int nRetVal = 0;
			string query = "";
            string response = "";
			
			CDBHelper dalObj = new CDBHelper();
            
            m_sDBPath = XMLConfig.Get("dbhost0");
            m_sDBName = XMLConfig.Get("dbname0");
            m_sDBUser = XMLConfig.Get("dbuser0");
            m_sDBPassword = XMLConfig.Get("dbpasswd0");

			dalObj.SetDB(m_sDBUser, m_sDBPassword, m_sDBPath, m_sDBName);
          
			try
			{
				NameValueCollection pm = new NameValueCollection();

                pm.Add("@test_id", form["test_id"]);
				
				query = " SELECT ot.test_desc,oti.id,oti.file_path from ocr_test ot join ocr_test_item oti on ot.id = oti.test_id where test_id = @test_id";
				nRetVal = dalObj.GetItems2(query, pm);

				dalObj.Close();

				if(nRetVal <= 0)
				{
					// cannot find record
					mErrMsg = "File_path Not Found. " + query + "," + nRetVal + ":" + dalObj.Error();
                    nRetVal = -1;
					return nRetVal.ToString();
				}
				
				List<Dictionary<string, object>> list = (List<Dictionary<string, object>>)dalObj.dic["Item"];
				int size = list.Count;
				if(size > 0)
				{
					for(int i=0;i<size;i++)
					{
						DateTime startDate = DateTime.Now;
						
						Dictionary<string, object> dicx = list[i];
						var file_path = dicx["file_path"];
                        
						var id = dicx["id"];

                        string test_desc = dicx["test_desc"].ToString();
                        string[] test_desc_split = test_desc.Split(new string[]{":"}, StringSplitOptions.None);
                        string version = test_desc_split[0];

                        bool isNumeric = Regex.IsMatch(version, @"^\d+$");
                        if(isNumeric == false)
                        {
                            mErrMsg = "Please specify the version in the test description.";
                            nRetVal = -1;

                            ResultInfo result = new ResultInfo(id.ToString(), nRetVal.ToString(), Request.Form["action"], mErrMsg, "", "", "");              
                            dalObj.dic.Add("Result", result);
                            response = CMessageServer.JQSerializern(dalObj.dic);

                            return response;
                        }
					
						var m_sAppPath = XMLConfig.Get("appdatapath");
						string dataPath = m_sAppPath +"\\ocr\\App_Data\\ocr\\images\\"+file_path;

						string cmd = "C:\\Program Files\\Python37\\python.exe";
						string imgPath = dataPath;	
                        
						string args = string.Format(m_sAppPath +"\\ocr\\image_loop_"+version+".py {0}", imgPath);
						
						try
						{			

						   ProcessStartInfo procStartInfo = new ProcessStartInfo(cmd, args);
						   procStartInfo.RedirectStandardOutput = true;
						   procStartInfo.UseShellExecute = false;
						   procStartInfo.RedirectStandardError = true;
						   procStartInfo.CreateNoWindow = true;

						   // start process
						   Process proc = new Process();
						   proc.StartInfo = procStartInfo;
									   
						   bool bstatus = proc.Start();
						   proc.WaitForExit();

						   // read process output
						   string cmdError = proc.StandardError.ReadToEnd();
						   string cmdOutput = proc.StandardOutput.ReadToEnd();

						   if(cmdError != "") { nRetVal = -1; }
						   else nRetVal = 1;
						   
						   DateTime endDate = DateTime.Now;
						   
						   TimeSpan evalDate = endDate - startDate;
						   string eval_Dt = String.Format(" {0} seconds", evalDate.Seconds);
						   
						   string[] cmdOutputSplit = cmdOutput.Split(';');
						   
						   string name_result = cmdOutputSplit[0];
						   string ic_result = cmdOutputSplit[1];
						   string address = cmdOutputSplit[2];
						   
						   pm.Add("@name_result", name_result);
						   pm.Add("@ic_result", ic_result);
						   pm.Add("@address_result", address);
						   pm.Add("@eval_Dt", eval_Dt);
						   pm.Add("@id", id.ToString());
						   
						   query = " UPDATE ocr_test_item SET name = @name_result, ic_no = @ic_result, address = @address_result, test_dt = getdate(), eval_dt = @eval_Dt WHERE id = @id ";
						   nRetVal = dalObj.UpdateItem2(query, pm);
							
						}
						catch (Exception ex)
						{
                            Log.ErrorLog("Error",ex.ToString());
						}

                        pm.Clear();
					}
        }
			} 
			catch(Exception ex) 
			{
				mErrMsg = ex.ToString();
				nRetVal = -1;
			}
            						
			ResultInfo result2 = new ResultInfo("", nRetVal.ToString(), Request.Form["action"], mErrMsg, "", "", "");              
            dalObj.dic.Add("Result", result2);
            response = CMessageServer.JQSerializern(dalObj.dic);

            return response;
        }
		
		public string GetTestResultList(NameValueCollection form)
		{
			int nRetVal = 0;
			CDBHelper dalObj = new CDBHelper();
            
            m_sDBPath = XMLConfig.Get("dbhost0");
            m_sDBName = XMLConfig.Get("dbname0");
            m_sDBUser = XMLConfig.Get("dbuser0");
            m_sDBPassword = XMLConfig.Get("dbpasswd0");
			dalObj.SetDB(m_sDBUser, m_sDBPassword, m_sDBPath, m_sDBName);
			if ( dalObj.Connect() == true ) {
                try{
					NameValueCollection pm = new NameValueCollection();

					string query = "SELECT id,test_desc,accuracy from ocr_test order by test_dt desc";
					nRetVal = dalObj.GetItems2(query, pm, "TestResultList");
					
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

        private string UploadCameraImage(NameValueCollection form) {
            List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            var nvc = new Dictionary<string, object>();
			int nRetVal = 0;
            string id = "";

			CDBHelper dalObj = new CDBHelper();
            
            m_sDBPath = XMLConfig.Get("dbhost0");
            m_sDBName = XMLConfig.Get("dbname0");
            m_sDBUser = XMLConfig.Get("dbuser0");
            m_sDBPassword = XMLConfig.Get("dbpasswd0");
			dalObj.SetDB(m_sDBUser, m_sDBPassword, m_sDBPath, m_sDBName);

            try {

                NameValueCollection form3 = new NameValueCollection();  //form for child record

                int i = 0;

                string base64String = form["image"];
				string base64String2 = base64String.Split(',')[1];
				byte[] image_bytes = Convert.FromBase64String(base64String2);

                string newFileName = DateTime.Now.ToString("yyyyMMddHHmmss")+"_image.png";
                string filePath = sAppPath + @"\ocr\App_Data\ocr\images\" + newFileName;

                form3.Add("file_path_"+i, newFileName);
                form3.Add("name", null);
                form3.Add("ic_no", null);
                form3.Add("address", null);
                form3.Add("name_result", null);
                form3.Add("ic_no_result", null);
                form3.Add("address_result", null);

                System.Drawing.Image image;
                using (MemoryStream ms = new MemoryStream(image_bytes))
                {
                    image = System.Drawing.Image.FromStream(ms);
                }

                image.Save(filePath, System.Drawing.Imaging.ImageFormat.Png);
                
                nvc.Add("file_name", newFileName.ToString());


                if ( form["test_id"] == null || form["test_id"] == "" ) {   // new test

                NameValueCollection form2 = new NameValueCollection();   // form for parent record
                form2.Add("test_desc", form["test_desc"]);
                form2.Add("total_image", "1");
                form2.Add("total_test", null);
                form2.Add("total_passed", null);
                form2.Add("total_failed", null);
                form2.Add("accuracy", null);

                id = PortletCryto.encrypt(SaveOCRTest(form2));  // encrypted because insertitem = true return id in int
                nRetVal = 1;    // 1 because insert 1 ocr test
                form3.Add("test_id", id);

                } else {    // insert to existing test
                    form3.Add("test_id", form["test_id"].ToString());
                    id = form["test_id"];
                    //nRetVal = fcnt;
                    nRetVal = Int32.Parse(PortletCryto.decrypt(id));
                }

                if ( nRetVal > 0 ) {
                    try {
                     SaveOCRTestItem(form3, i);
                        
                    } catch ( Exception ex ) {
                        mErrMsg = ex.ToString();
                        nRetVal = -1;
                    }
                }
                

                list.Add(nvc);
                dalObj.dic.Add("Item", list);

            } catch (Exception ex) {
				mErrMsg = ex.ToString();
				nRetVal = -1;
            }

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