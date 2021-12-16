<%@ Page Language="C#" AutoEventWireup="true" debug = "true" CodeFile="testcasedetails.aspx.cs" Inherits="OITWS.CTestCaseDetails"  %>

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml">

    <head>
        <title>Test OCR</title>

        <link rel="stylesheet" href="css/jquery-ui.min.css">
        <link rel="stylesheet" href="css/materialize.min.css" />
        <link href="css/materialdesignicons.min.css" media="all" rel="stylesheet" type="text/css" />
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

        <script language="javascript" src="scripts/jquery-3.0.0.min.js"></script>
        <script language="javascript" src="scripts/jquery-ui.min.js"></script>
        <script language="javascript" src="scripts/materialize.min.js"></script>

        <style>
		#txt_test_desc
		{
			height: 2em;
			padding: 3px 4px;
			box-sizing: border-box;
			background: rgba(0,0,0,0.02);
			border-radius: 5px;
			border: 1px solid #007AFF;
            width: 50%;
            margin-left: 25%;
	    }
		
        #div_main_ocr {
            /* position: relative;
            top: 110px; */
            margin: 20px;
        }

        .navbar_main {
            position: fixed;
            z-index: 2;
        }

        .div_pos {
            position: fixed;
            z-index: 2;
            background: rgba(255,255,255);
            top: 64px;
            height: 25px;
            line-height: 25px;
            width: 100%;
            border-bottom: 1px solid #C8C8C8;
            border-top: 1px solid #C8C8C8;
        }

        .div_hdr {
            margin-top: 15px;
        }

        .div_header {
            font-size: 17px;
            text-align: center;
            font-weight: bold;
            border-bottom: 1px solid #C8C8C8
        }

        .div_rec {
            border-bottom: 1px solid #c8c8c8;
        }

        .div_image {
            margin-bottom: 20px;
        }

        #div_accuracy {
            font-size: 18px;
            color: black;
            margin: 20px;
        }

        #div_accuracy .fld_value {
            display: inline-flex;
        }

        .img_rec {
            border-radius: 5px;
            border: 1px solid grey;
        }

		.but_testimage
		{
			/* border: 1px solid #007AFF;
			background: #fff;
			color: #007AFF;
            margin: 5px;
            margin-top: 1%;
			margin-left: 5px;
			cursor: pointer;
			border-radius: 5px; */
            height: 100%;
            line-height: 64px;
		}
		
		.but_pass:not(i)
		{
			border: 1px solid #19b319;
			background: #fff;
			cursor: pointer;
			border-radius: 5px;
			color: 	#19b319;
		}
		
		.but_fail:not(i)
		{
			border: 1px solid #cc3300;
			background: #fff;
			color: #cc3300;
			cursor: pointer;
			border-radius: 5px;
		}

        .but_pass:not(i).selected {
            background: green;
            color:white;
            border: 1px solid lightblue;
        }

        .but_fail:not(i).selected {
            background: radial-gradient(pink, transparent);
            background: red;
            color: white;
            border: 1px solid lightblue;
        }

        .div_eval_time_text {
            text-align: center;
        }

        .progress
        {
            position: fixed;
            top: 90px;
            width: 80%;
            margin-left: 10%;
            z-index: 2;
        }

        .sample { display:none }

        .fld_name {
            font-weight: 400;
            width: 15%;
            display: inline-block;
            font-size: 0.95em;
            color: rgba(0,0,0,0.7);
            text-align: right;
        }

        .fld_value {
            position: relative;
            width: 85%;
            display: inline-block;
            padding-left: 15px;
        }

        main {
            padding-top: 90px;
        }

        footer {
            margin-top: 90px;
            /* padding: 20px; */
        }

/* ------------------------------- */

        .breadcrumb, .breadcrumb:before {
            font-size: small;
            color: rgba(0,0,0,0.7);
        }

        .breadcrumb:first-child {
            margin-left: 20px;
        }

        .breadcrumb:last-child {
            color: rgba(0,0,0);
        }

/* media screen  */
        @media only screen and (max-width: 600px){
            .fld_name {
                width: 36%;
            }

            .fld_value {
                width: 64%;
            }
        }

        @media only screen and (min-width: 600px) and (max-width: 992px){
            .fld_name {
                width: 27%;
            }

            .fld_value {
                width: 73%;
            }
        }

        @media only screen and (min-width: 992px) and (max-width: 1200px) {
            .fld_name {
                width: 20%;
            }

            .fld_value {
                width: 80%;
            }
        }

        @media only screen and (min-width: 1200px) {
            .fld_name {
                width: 20%;
            }

            .fld_value {
                width: 80%;
            }
        }
/* media screen  */
        </style>
        <script>
            var url = "testcasedetails.aspx";
            $(document).ready(function(e) {
                clearPage();

                $("input").attr("autocomplete", "off");

                var url_string = location.search.substring(1);
                if (url_string) {
                    url_string = url_string.split("/");
                    for ( var i = 0; i < url_string.length; i++ ) {

                        if (url_string[i].match("id")) {
                            $("#test_id").val(url_string[i].substring(3));
                            getImageDetails();
                        }

                    }

                } else {
                    M.toast({html: "New Test!"});
                }

                $(".but_camera").on("click", function(e) {
                    $("#div_camera").show();
                });

                $('.materialboxed').materialbox();

            });

			function testResult(obj)
			{
                // if ( $("#recognize_ind").val() == 0 ) {
                //     // alert("Kindly proceed with recognition process before deciding pass/fail");
                //     M.toast({html: "Kindly proceed with recognition process before deciding pass/fail", classes: 'rounded'});
                //     return;
                // }

			    var item_id = $(obj).closest(".div_rec").attr("item_id");
			    var test_id = $("#test_id").val();
			    var button = $(obj).hasClass("but_pass") ? "but_pass" : "but_fail";
                var field_name = $(obj).closest(".div_r").attr("field_name");
                button = button + "_" + field_name;
			    var data = {
                    action: 'TestResult',
                    object: 'CTestCaseDetails',
                    item_id: item_id,
					test_id:test_id,
					button: button
                }
                updateItem(url, data, function (data) {
                    console.log(data);
                    var res = $.parseJSON(data).Result;
                    if (res && typeof res === "object" && res != null) 
                    {
                        status = parseInt(res.RetCode);
                        if (status > 0) {
                            // alert("Accuracy Updated");
                            M.toast({html: "Accuracy Updated"});
                        }
                    }

                    var objs = $.parseJSON(data).Item;
                    if (objs && typeof objs === "object" && objs != null) {

                        switch ( $(obj).closest(".div_r").attr("field_name") ) {
                            case "name" : {

                                    if ( objs[0].name_result == "1" ) {
                                        $(obj).closest(".div_r").find(".but_pass").addClass("selected");
                                        $(obj).closest(".div_r").find(".but_fail").removeClass("selected");
                                        $(obj).closest(".div_r").find("i").not(".but_fail").removeClass("grey-text").addClass("green-text");
                                        $(obj).closest(".div_r").find("i").not(".but_pass").removeClass("red-text").addClass("grey-text");
                                    } else if ( objs[0].name_result == "0" ) {
                                        $(obj).closest(".div_r").find(".but_pass").removeClass("selected");
                                        $(obj).closest(".div_r").find(".but_fail").addClass("selected");
                                        $(obj).closest(".div_r").find("i").not(".but_fail").removeClass("green-text").addClass("grey-text");
                                        $(obj).closest(".div_r").find("i").not(".but_pass").removeClass("grey-text").addClass("red-text");
                                    }

                                }
                                break;
                            case "ic" : {

                                    if ( objs[0].ic_no_result == "1" ) {
                                        $(obj).closest(".div_r").find(".but_pass").addClass("selected");
                                        $(obj).closest(".div_r").find(".but_fail").removeClass("selected");
                                        $(obj).closest(".div_r").find("i").not(".but_fail").removeClass("grey-text").addClass("green-text");
                                        $(obj).closest(".div_r").find("i").not(".but_pass").removeClass("red-text").addClass("grey-text");
                                    } else if ( objs[0].ic_no_result == "0" ) {
                                        $(obj).closest(".div_r").find(".but_pass").removeClass("selected");
                                        $(obj).closest(".div_r").find(".but_fail").addClass("selected");
                                        $(obj).closest(".div_r").find("i").not(".but_fail").removeClass("green-text").addClass("grey-text");
                                        $(obj).closest(".div_r").find("i").not(".but_pass").removeClass("grey-text").addClass("red-text");
                                    }

                                }
                                break;
                            case "address" : {

                                    if ( objs[0].address_result == "1" ) {
                                        $(obj).closest(".div_r").find(".but_pass").addClass("selected");
                                        $(obj).closest(".div_r").find(".but_fail").removeClass("selected");
                                        $(obj).closest(".div_r").find("i").not(".but_fail").removeClass("grey-text").addClass("green-text");
                                        $(obj).closest(".div_r").find("i").not(".but_pass").removeClass("red-text").addClass("grey-text");
                                    } else if ( objs[0].address_result == "0" ) {
                                        $(obj).closest(".div_r").find(".but_pass").removeClass("selected");
                                        $(obj).closest(".div_r").find(".but_fail").addClass("selected");
                                        $(obj).closest(".div_r").find("i").not(".but_fail").removeClass("green-text").addClass("grey-text");
                                        $(obj).closest(".div_r").find("i").not(".but_pass").removeClass("grey-text").addClass("red-text");
                                    }

                                }
                                break;
                            default:
                                break;
                        }

                        var accuracy = objs[0].accuracy == "" ? "0.00" : parseFloat(objs[0].accuracy).toFixed(2);
                        $("#txt_accuracy").text(parseFloat(accuracy).toFixed(2));
                    }
                    // getImageDetails();
                })
			  
			}

            function clearPage() {
                $("#test_history").val("");
                $("#txt_test_desc").val("");
                $("#txt_accuracy").val("");
                $("#recognize_ind").val(0);
                $("#test_id").val("");
                $("#div_main_ocr .div_rec").not(".sample").remove();
                $("#div_accuracy").hide();
                $("#div_main_ocr .div_hdr").addClass("hide");
            }

            function clickUploadImageBtn() {

                if ( $("#txt_test_desc").val() == null || $("#txt_test_desc").val() == "" ) {
                    // alert("Kindly insert test description");
                    M.toast({html: "Kindly insert test description"});
                    return;
                }

                $('#file_uploadimageocr').click();
            }

            function uploadImagesLump(input) {
                
                $(".progress").show();
                var data = new FormData();

                var fcnt = input.files.length;
                for ( var i = 0; i < fcnt; i++ ) {
                    var file = input.files[i];
                    if ( file ) {
                        data.append("file", file);
                    }
                }

                data.append("action", "UploadImagesLump");
                data.append("test_desc", $("#txt_test_desc").val());
                data.append("test_id", $("#test_id").val());

                $.ajax({
                    url: url,
                    type: 'POST',
                    data: data,
                    cache: false,
                    contentType: false,
                    processData: false
                }).done(function(data){
                    // expecting list of candidate or error
                    $("#recognize_ind").val(0);
                    afterUploadImagesLump(data);
                }).fail(function() {
                    // alert(data);
                    M.toast({html: data});
                });
            }

            function afterUploadImagesLump(data) {
                console.log(data);
                $(".progress").hide();
                var res = $.parseJSON(data).Result;
                if (res && typeof res === "object" && res != null) {
                    var status = parseInt(res.RetCode);
                    if ( status > 0 ) $("#test_id").val(res.Id);
                }

                var objs = $.parseJSON(data).Item;
                if (objs && typeof objs === "object" && objs != null) {
                    var fcnt = objs.length;
                    if ( fcnt > 0 ) {
                        for (var prop in objs[0]) {
    			            if (objs[0].hasOwnProperty(prop)) {
                                // StreamFile
                            }
                        }
                    }
                }
                getImageDetails();
            }

            function getImageDetails(recognize_ind) {
                // console.log(recognize_ind);
                // if ( typeof recognize_ind !== "undefined" )
                // {
                //     $("#recognize_ind").val(1);
                // }

                var data = {
                    action: 'GetImageDetails',
                    object: 'CTestCaseDetails',
                    id: $("#test_id").val()
                }
                updateItem(url, data, afterGetImageDetails)
            }

            function afterGetImageDetails(data) {
                console.log(data);
                var res = $.parseJSON(data).Result;
                if (res && typeof res === "object" && res != null) {
                    var status = parseInt(res.RetCode);
                }

                var objs = $.parseJSON(data).Item;
                if (objs && typeof objs === "object" && objs != null) {
                    $("#txt_test_desc").val(objs[0].test_desc);
                    $("#a_test_desc").text(objs[0].test_desc);

                    var accuracy = objs[0].accuracy == "" ? "0.00" : parseFloat(objs[0].accuracy).toFixed(2);
                    $("#txt_accuracy").text(accuracy);
                }

                var tr = $("#div_main_ocr .div_rec").not(".sample").remove();
                var objs2 = $.parseJSON(data).ocr_test_item;
                if (objs2 && typeof objs2 === "object" && objs2 != null) {
                    $("#div_main_ocr, #div_accuracy").show();
                    $("#div_main_ocr .div_hdr").removeClass("hide");

                    var fcnt = objs2.length;
                    for ( i = 0; i < fcnt; i++ ) {
                        var tr = $("#div_main_ocr .div_rec.sample").clone();
                        tr.removeClass("sample");
                        tr.attr("item_id", objs2[i].id);
                        tr.find(".div_image img").attr("alt", objs2[i].file_path).attr("title",objs2[i].file_path);

                        var src = "testcasedetails.aspx?Action=StreamFile&file_name="+objs2[i].file_path;
                        tr.find(".div_image img").attr("src",src);

                        tr.find(".div_eval_time .div_eval_time_text").text(objs2[i].eval_dt);
                        tr.find(".div_r_name").text(objs2[i].name);
                        tr.find(".div_r_ic").text(objs2[i].ic_no);
                        tr.find(".div_r_address").text(objs2[i].address);
                        if (objs2[i].name_result == "1") {
                            tr.find(".row[field_name='name'] .but_pass").addClass("selected");
                            tr.find(".row[field_name='name'] i").not(".but_fail").removeClass("grey-text").addClass("green-text");
                            // tr.find(".but_analyseImage[entity_button='but_pass_name']").addClass("selected");
                        } else if (objs2[i].name_result == "0") {
                            tr.find(".row[field_name='name'] .but_fail").addClass("selected");
                            tr.find(".row[field_name='name'] i").not(".but_pass").removeClass("grey-text").addClass("red-text");
                            // tr.find(".but_analyseImage[entity_button='but_fail_name']").addClass("selected");
                        }
                        if (objs2[i].ic_no_result == "1") {
                            tr.find(".row[field_name='ic'] .but_pass").addClass("selected");
                            tr.find(".row[field_name='ic'] i").not(".but_fail").removeClass("grey-text").addClass("green-text");
                            // tr.find(".but_analyseImage[entity_button='but_pass_ic']").addClass("selected");
                        } else if (objs2[i].ic_no_result == "0") {
                            tr.find(".row[field_name='ic'] .but_fail").addClass("selected");
                            tr.find(".row[field_name='ic'] i").not(".but_pass").removeClass("grey-text").addClass("red-text");
                            // tr.find(".but_analyseImage[entity_button='but_fail_ic']").addClass("selected");
                        }
                        if (objs2[i].address_result == "1") {
                            tr.find(".row[field_name='address'] .but_pass").addClass("selected");
                            tr.find(".row[field_name='address'] i").not(".but_fail").removeClass("grey-text").addClass("green-text");
                            // tr.find(".but_analyseImage[entity_button='but_pass_address']").addClass("selected");
                        } else if (objs2[i].address_result == "0") {
                            tr.find(".row[field_name='address'] .but_fail").addClass("selected");
                            tr.find(".row[field_name='address'] i").not(".but_pass").removeClass("grey-text").addClass("red-text");
                            // tr.find(".but_analyseImage[entity_button='but_fail_address']").addClass("selected");
                        }
                        $("#div_main_ocr .sample").after(tr);
                    }
                }

                $('.materialboxed').materialbox();
            }

            function recognizeImage() {
                $(".progress").show();

                if ( $("#test_id").val() == "" ) {
                    // alert("Kindly upload images for recognition test");
                    M.toast({html: "Kindly upload images for recognition test"});
                    $(".progress").hide();
                    return;
                }

                var data = {
                    action: 'RecognizeImage',
                    object: 'CTestCaseDetails',
                    test_id: $("#test_id").val()
                }
                updateItem(url, data, afterRecognizeImage)
            }

            function afterRecognizeImage(data) {
            console.log(data);
                $("#recognize_ind").val(1);

                var res = $.parseJSON(data).Result;
                if (res && typeof res === "object" && res != null) {
                    status = parseInt(res.RetCode);
                    
                    if(status < 0)
                    {
                        alert(res.ErrMsg);
                        // M.toast({html: "Error!", classes: 'rounded'});
                        $(".progress").hide();
                        return;
                    }
                    else
                    {
                        M.toast({html: "Recognize Successful!"});
                        $(".progress").hide();
                        getImageDetails();
                        return;
                    }
                }
            }

            function uploadCameraImage() {
            
                $(".progress").show();
                var data = new FormData();

                var image = $("#div_captured").find("img").attr("src");

                if(image == null || image == "")
                {
                    M.toast("Please upload an image first.");
                    return;
                }
                
                data.append("image", image);
                data.append("action", "UploadCameraImage");
                data.append("test_desc", $("#txt_test_desc").val());
                data.append("test_id", $("#test_id").val());

                $.ajax({
                    url: url,
                    type: 'POST',
                    data: data,
                    cache: false,
                    contentType: false,
                    processData: false
                }).done(function(data){
                    // expecting list of candidate or error
                    $("#recognize_ind").val(0);
                    afteruploadCameraImage(data);
                }).fail(function() {
                    M.toast({html: data, classes: 'rounded'});
                });
            }

            function afteruploadCameraImage(data) {
                console.log(data);
                $(".progress").hide();
                var res = $.parseJSON(data).Result;
                if (res && typeof res === "object" && res != null) {
                    status = parseInt(res.RetCode);
                    //$("#test_id").val(status);
                }

                var objs = $.parseJSON(data).Item;
                if (objs && typeof objs === "object" && objs != null) {
                    var fcnt = objs.length;
                    if ( fcnt > 0 ) {
                        for (var prop in objs[0]) {
                            if (objs[0].hasOwnProperty(prop)) {
                                // StreamFile
                            }
                        }
                    }
                }
                getImageDetails();
            }

// helper function
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
// helper function
        </script>
    </head>

    <body style="font-family:arial">
        <input type="hidden" id="test_id">
        <input type="hidden" id="recognize_ind">

        <nav class="nav-extended white navbar_main">
            <div class="nav-wrapper">
            <a href="#" class="black-text">
                OIT-OCR
            </a>
            <ul id="ul_action_main" class="left">
                <a href="testcaselist.aspx"><i class="material-icons black-text">arrow_back_ios_new</i></a>
            </ul>
            <ul id="nav-mobile" class="right">
                <li>
                    <a class="waves-effect waves-teal btn-flat hide-on-med-and-down but_testimage but_camera" onclick="startCapture()">Camera</a>
                    <a><i class="material-icons black-text hide-on-large-only but_camera" onclick="startCapture()">image</i></a>
                </li>
                <li>
                    <!-- button upload -->
                        <a class="waves-effect waves-teal btn-flat hide-on-med-and-down but_testimage" onclick="clickUploadImageBtn()">Upload</a>
                        <a><i class="material-icons black-text hide-on-large-only" onclick="clickUploadImageBtn()">image</i></a>
                        <input type="file" name="uploadimageocr" id="file_uploadimageocr" onchange="uploadImagesLump(this)" onclick="$(this).val('')" style="display:none" multiple>
                </li>
                <li>
                    <!-- button recognize -->
                    <a class="waves-effect waves-teal btn-flat hide-on-med-and-down but_testimage" onclick="recognizeImage()">Recognize</a>
                    <a><i class="material-icons black-text hide-on-large-only" onclick="recognizeImage()">crop_free</i></a>
                </li>
            </ul>
        </nav>

    <header>
        
        <div class="div_pos">
            <a href="testcaselist.aspx" class="breadcrumb">OCR List</a>
            <a href="#!" class="breadcrumb" id="a_test_desc">New Test</a>
        </div>

        <div class="progress col s12" style="display: none;">
            <div class="indeterminate"></div>
        </div>
    </header>

    <main>
        <div class="row col s12" id="div_camera" style="position: relative;top: 20px;display: none;">
            <!-- Modal -->
            <div class="col s12 offset-s5 xmodal fade" id="myModal" role="dialog" style="display:none">
                <div class="modal-dialog">  
                <!-- Modal content-->
                <div class="modal-content">
                    <div class="modal-body">
                        <video id="player" width="320" height="240" style="frameborder:0;" autoplay="autoplay"></video>
                    </div>
                    <div class="modal-footer" style="margin: 5px ;margin-left: 9%;">
                    <button class="btn btn-primary center-block" id="capture" type="button"  data-dismiss="modal">Take Photo</button>
                    <button type="button" class="btn btn-primary center-block" id="btn_upload_camera" onclick="uploadCameraImage()" style="display: none;">Upload</button>
                    </div>
                </div>
                </div>
            </div>
        
            <div class="col s6" id="div_captured">
                <div>
                <canvas id="canvas" width=320 height=240 style="display:none"></canvas>
                <img class="img-responsive img-rounded" id="photo" alt="The screen capture will appear in this box." src="http://via.placeholder.com/320x240" style="display:none">
                <br/>
                  <!-- Trigger the modal as wll as VideoMedia with a button -->
                <!--<button type="button" class="btn btn-primary center-block" data-toggle="modal" data-target="#myModal" data-backdrop="static" data-keyboard="false" onclick="startCapture()">Open Camera</button>-->
                
                </div>
            </div>
        </div>
        <script src="scripts/capture.js"></script>

        <div class="" id="div_main_ocr">
            <input type ="text" class =" input-field  " id ="txt_test_desc" placeholder="Test Desc">

            <div class="row div_hdr">
                <div class="col s5 m5 l4 div_header">Image</div>
                <div class="col s5 m5 l4 div_header">Result</div>
                <div class="col s2 m2 l2 div_header">Status</div>
                <div class="col s12 m2 l2 hide-on-med-and-down div_header">Evaluation Time</div>
            </div>
            <div class="row div_rec sample">
                <div class="col s5 m5 l4 div_image">
                    <div>
                        <a href='javascript:void(null)'><img class="materialboxed responsive-img img_rec" src="images/sample-1.jpg"></a>
                    </div>
                </div>
                <div class="col s7 m7 l6 div_result">
                    <div class="row valign-wrapper div_r" field_name="name">
                        <div class="col s8 valign-wrapper"><div class="fld_name">Name : </div><div class="fld_value div_r_name"></div></div>
                        <div class="col s4">
                            <div class="col s6">
                                <button onclick="testResult(this)" class="btn waves-effect waves-light hide-on-small-only but_pass"  type="submit" name="action">Pass</button>
                                <i onclick="testResult(this)" class="material-icons grey-text hide-on-med-and-up but_pass">check_circle</i>
                            </div>
                            <div class="col s6">
                                <button onclick="testResult(this)" class="btn waves-effect waves-light hide-on-small-only but_fail" type="submit" name="action">Fail</button>
                                <i onclick="testResult(this)" class="material-icons grey-text hide-on-med-and-up but_fail">cancel</i>
                            </div>
                        </div>
                    </div>
                    <div class="row valign-wrapper div_r" field_name="ic">
                        <div class="col s8 valign-wrapper"><div class="fld_name">IC No : </div><div class="fld_value div_r_ic"></div></div>
                        <div class="col s4">
                            <div class="col s6">
                                <button onclick="testResult(this)" class="btn waves-effect waves-light hide-on-small-only but_pass" type="submit" name="action">Pass</button>
                                <i onclick="testResult(this)" class="material-icons grey-text hide-on-med-and-up but_pass">check_circle</i>
                            </div>
                            <div class="col s6">
                                <button onclick="testResult(this)" class="btn waves-effect waves-light hide-on-small-only but_fail but_fail_ic" type="submit" name="action">Fail</button>
                                <i onclick="testResult(this)" class="material-icons grey-text hide-on-med-and-up but_fail">cancel</i>
                            </div>
                        </div>
                    </div>
                    <div class="row valign-wrapper div_r" field_name="address">
                        <div class="col s8 valign-wrapper"><div class="fld_name">Address : </div><div class="fld_value div_r_address"></div></div>
                        <div class="col s4">
                            <div class="col s6">
                                <button onclick="testResult(this)" class="btn waves-effect waves-light hide-on-small-only but_pass" type="submit" name="action">Pass</button>
                                <i onclick="testResult(this)" class="material-icons grey-text hide-on-med-and-up but_pass">check_circle</i>
                            </div>
                            <div class="col s6">
                                <button onclick="testResult(this)" class="btn waves-effect waves-light hide-on-small-only but_fail" type="submit" name="action">Fail</button>
                                <i onclick="testResult(this)" class="material-icons grey-text hide-on-med-and-up but_fail">cancel</i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col s12 m12 l2 div_eval_time">
                    <div class="row">
                        <div class="col s6 m6 hide-on-large-only">Evaluation Time: </div> <div class="col s6 m6 l12 div_eval_time_text">test 45</div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- todo: static while main scrollable -->
    <footer class="page-footer white">
            <div id="div_accuracy" class="row input-field right valign-wrapper">
                <div class="col s6 fld_name">Accuracy:</div><div class="col s6 fld_value"><div id="txt_accuracy"></div>%</div>
            </div>
    </footer>

    </body>

    </html>