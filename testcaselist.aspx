<%@ Page Language="C#" AutoEventWireup="true" debug = "true" CodeFile="testcaselist.aspx.cs" Inherits="OITWS.CTestCaseList"  %>

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml">

    <head>
        <title>Test Case List</title>

        <link rel="stylesheet" href="css/jquery-ui.min.css">
        <link rel="stylesheet" href="css/materialize.min.css" />
        <link href="css/materialdesignicons.min.css" media="all" rel="stylesheet" type="text/css" />
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

        <script language="javascript" src="scripts/jquery-3.0.0.min.js"></script>
        <script language="javascript" src="scripts/jquery-ui.min.js"></script>
        <script language="javascript" src="scripts/materialize.min.js"></script>

        <style>
		#but_search_test_case{
			cursor: pointer;
			vertical-align: middle;
			padding-bottom: 13px;
			padding-top: 1px;
		}
				
        .sample { display:none }

		.tbl_test_case_list td{
			padding: 6px ! important;
			font-size: 0.9em ! important;
			font-weight: 500 ! important;
         }
		 
		.tr_item:hover {
			background: #eee;
			cursor: pointer;
		}
		
        </style>
        <script>
            var url = "testcaselist.aspx";
            $(document).ready(function(e) {

				getTestResultList();
				
				$("#but_search_test_case").click(function(e) { 

					var keyword = $("#txt_test_desc").val();
					var data = {
						action: 'GetTestResultList',
						object: 'CUploadImagePython',
						keyword:keyword
						
						
					};

					var divref = $("#tbl_test_case_list");
					divref.find(".tr_item").not(".sample").remove();
					
					updateItem(url, data, function(data) {
					console.log(data);
					var res = $.parseJSON(data).Result;
					if (res && typeof res === "object" && res != null) {
						var status = parseInt(res.RetCode);
						console.log(status);
					}

					var objs = $.parseJSON(data).TestResultList;
					if(objs && typeof objs === "object" && objs != null) 
					{
						 var fcnt = objs.length;
						 for(var i=0;i<fcnt;i++)
						 {
						 
						 var tr = divref.find(".tr_item.sample").clone();
						 tr.attr("id", objs[i].id);
						 //tr.attr("status", objs[i].status); 
						 tr.removeClass("sample");
						 tr.find(".td_test_dt").text(objs[i].test_dt); 
						 tr.find(".td_test_desc").text(objs[i].test_desc); 
						 tr.find(".td_accuracy").text(objs[i].accuracy); 
						 divref.append(tr);
						}
					}
					});
				});
				
				   $("#tbl_test_case_list").on("click", ".tr_item", function(e) {
					  //getCustEngagementByList($(this).attr("id"));
					  //alert($(this).attr("id"));
						//location.href = "uploadimagepython.aspx";
						
						var id = $(this).attr("id"); // change here
						if (id != "") {
							location.href = "testcasedetails.aspx?id=" + id;
							//location.href = "uploadimagepython.aspx";
						} else
							alert('Oops.!!');
					
				   });
            });
			
			function getTestResultList()
			{
                //alert(obj);
				var data = {
                    action: 'GetTestResultList',
                    object: 'CUploadImagePython'
                }
				var divref = $("#tbl_test_case_list");
                divref.find(".tr_item").not(".sample").remove();
				updateItem(url, data, function(data) {
				console.log(data);
                var res = $.parseJSON(data).Result;
                if (res && typeof res === "object" && res != null) {
                    var status = parseInt(res.RetCode);
                    console.log(status);
                }
				//alert(obj);
                //$("#div_test_desc").remove();
				var objs = $.parseJSON(data).TestResultList;
				if(objs && typeof objs === "object" && objs != null) 
				{
					 var fcnt = objs.length;
					 for(var i=0;i<fcnt;i++)
					 {
					 
					 var tr = divref.find(".tr_item.sample").clone();
					 tr.attr("id", objs[i].id);
					 //tr.attr("status", objs[i].status); 
					 tr.removeClass("sample");
					 tr.find(".td_test_dt").text(objs[i].test_dt); 
					 tr.find(".td_test_desc").text(objs[i].test_desc);
					 tr.find(".td_total_image").text(objs[i].total_image); 
					 tr.find(".td_accuracy").text(objs[i].accuracy); 
					 divref.append(tr);
					//$("#div_test_desc").css("width", "Auto");
					//$("#div_test_desc").css({"max-height": "150px", "height": "auto"});
					}
				}
				});
               
			}
			
			function updateItem(url, data, callbackFunc)
            {
                $.ajax({
                    url: url,
                    type: 'POST',
                    data: data,
                    success: function(data, textStatus, jqXHR) {
                        //console.log('success');
                        //console.log(data); //geocoded data
                    },

                    error: function(jqXHR, textStatus, errorThrown) {
                        console.log(textStatus);
                        console.log(errorThrown);
                        console.log(jqXHR);
                    }
                })
                .done(function(data) {
                    callbackFunc(data);
                })
                .fail(function() {
                    // message("Sorry, there was an error relating to the database.");
                    M.toast(data, 4000);
                })
            }
		

            
        </script>
    </head>

    <body style="font-family:arial">
    <input type="hidden" id="test_id">
    <input type="hidden" id="recognize_ind">

    <div class = "row" id="div_main">
        <div class="col s12 div_title">

        </div>
        <div class="div_desc col s12">
            <input type ="text" class =" col s4 txt_test_desc" id ="txt_test_desc" placeholder="Please enter keyword">
			<!--<img class="but_add_entity" id="but_search_test_case" src="images/search.png">-->
			<span class="material-icons" id="but_search_test_case">search</span>
			<a href="testcasedetails.aspx"><i class="material-icons black-text" id="but_add_new_test" style="padding-top: 15px;">add_box</i></a>
        </div>
    </div>
	<div class="col s12" style="overflow:auto">
    <table class="tbl_test_case_list" id="tbl_test_case_list" cellpadding=0 cellspacing=0 style="margin:auto;width:85%;">
        <tr class="tr_hdr">
            <th class="th_test_dt">Date & Time</th>
            <th class="th_test_desc">Test Description</th>
			<th class="th_total_image">Total Image</th>
            <th class="th_accuracy">Accuracy %</th>
            
        </tr>
        
        <tr class="tr_item row sample">
            <td class="td_test_dt"></td>
            <td class="td_test_desc"></td>
			<td class="td_total_image"></td>
            <td class="td_accuracy" style="padding-top: 3%;padding-bottom: 3%;">
            </td>
        </tr>
    </table>
    </div>
    </body>

    </html>