  //set the variable of id const
  const player = document.getElementById('player');
  const canvas = document.getElementById('canvas');
  const photo = document.getElementById('photo');
  const context = canvas.getContext('2d');
  const captureButton = document.getElementById('capture');

  captureButton.addEventListener('click', () => {
	//cheking if camera is on
	if(player.srcObject!=null){
    context.drawImage(player, 0, 0, canvas.width, canvas.height);
	var data = canvas.toDataURL('image/jpg');
	console.log(data);
    photo.setAttribute('src', data);
    // Stop all video streams.
    player.srcObject.getVideoTracks().forEach(track => track.stop());
	player.srcObject = null;

	$("#btn_upload_camera").click();
	$("#myModal").hide();
	
	}
	else{
		alert("Camera is off");
	}
  });

 function startCapture() {
	//this method get the browser video input field  
	navigator.getUserMedia = navigator.getUserMedia ||
                         navigator.webkitGetUserMedia ||
                         navigator.mozGetUserMedia;
	//cheking the condition
	if (navigator.getUserMedia) {
	navigator.getUserMedia({ audio: false, video: true },
		function(stream) {
			  player.srcObject = stream;
			  player.onloadedmetadata = function(e) {
			  player.play();

			  $("#myModal").show();
			 };
		  },
		  function(err) {
			 console.log("The following error occurred: " + err.name);
		  }
	   );
	} else {
	   console.log("getUserMedia not supported");
	} 
   
}