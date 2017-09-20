var sendChannel, receiveChannel, roomID;
var peerConfig = {
	iceServers : [
		{urls: "stun:23.21.150.121"},
		{urls: "stun:stun.l.google.com:19302"},
		{urls: "turn:numb.viagenie.ca", credential: "P@ssword001", username: "velu_developer@yahoo.com"}
    ]
};
var pc = new RTCPeerConnection(peerConfig);

/*pc.onicecandidate = function(e){
	if (!e.candidate) return;
	console.log(e.candidate.candidate)
	//pc.addIceCandidate(e.candidate);
    //send("icecandidate", JSON.stringify(e.candidate));
}*/

function answerOffer(offer){
    pc.ondatachannel = function(event){
    	receiveChannel = event.channel;
		receiveChannel.onmessage = handleReceiveMessage;
		receiveChannel.onopen = handleReceiveChannelStatusChange;
		receiveChannel.onclose = handleReceiveChannelStatusChange;
    };
    offer = new RTCSessionDescription(offer);
    pc.setRemoteDescription(offer);

    pc.createAnswer(function (answer) {
        pc.setLocalDescription(answer, function() {
        	console.log('Answered');
        	$('#notify').text('Connected');
        	var postParams = {
        		answer : JSON.stringify(pc.localDescription),
        		type : 'answerDesc',
        		room : roomID
        	};
        	$.ajax({
        		type : 'POST',
	    		url : baseUrl.replace('index.php', 'ajax.php?') + 'cb=saveClient',
	    		data : postParams,
	    		success : function(data){
	    			data = $.parseJSON(data);
	    			if (data.result){
	    				//$('#notify').text("Share URL : "+shareUrl);
	    			}
	    		}
        	});
        }, handleError);
    }, handleError);
}

function createOffer(){
	roomID = generateRoomID();
	sendChannel = pc.createDataChannel("Channel"+roomID);
	sendChannel.onopen = handleSendChannelStatusChange;
	sendChannel.onclose = handleSendChannelStatusChange;
	pc.createOffer(function (offer) {
		$('#notify').text('please wait...');
	    pc.setLocalDescription(offer, function() {
	    	console.log('OFFER send');
	    	var shareUrl = location.href;
	    	shareUrl = shareUrl.replace('role=staff', 'role=student');
	    	shareUrl += '&room='+roomID;
	    	var postParams = {
	    		offer: JSON.stringify(pc.localDescription),
	    		room: roomID
	    	};
	    	$.ajax({
	    		type : 'POST',
	    		url : baseUrl.replace('index.php', 'ajax.php?') + 'cb=saveOffer',
	    		data : postParams,
	    		success : function(data){
	    			data = $.parseJSON(data);
	    			if (data.result){
	    				$('#notify').text("Share URL : "+shareUrl);
	    			}
	    		}
	    	});
	    }, handleError);
	}, handleError/*, {offerToReceiveAudio: true, offerToReceiveVideo: true}*/);

	//For retriving new clients
	var noOfClients = 0;
	var interval = window.setInterval(function(){
		$.ajax({
			type:'GET',
			url: baseUrl.replace('index.php', 'ajax.php?') + 'cb=getClients&room='+roomID,
			success:function(data){
				data = $.parseJSON(data);
				if(data.result) {
					var clients = data.clients.answer;
					if (clients.length > noOfClients){
						answer = new RTCSessionDescription(JSON.parse(clients.pop()));
						pc.setRemoteDescription(answer, function(){
							console.info('Remote accepted');
							//createOffer();
							noOfClients++;
							//clearInterval(interval);
						}, function(err){ console.warn(err); });
					}
					//$('#notify').text('Connected with (1) student');
				}
				else {
					console.log("Requesting for client peers..")
				}
			}
		});
	}, 1500);
}

function getOffer(ID){
	$('#notify').text('please wait...');
	roomID = ID;
	$.ajax({
		type : 'GET',
		url : baseUrl.replace('index.php', 'ajax.php?') + 'cb=findOffer&room='+roomID,
		success:function(data){
			data = $.parseJSON(data);
			if (data.result){
				answerOffer(data.offer);
			}
		}
	});
}

function generateRoomID() {
    var text = "";
    var possible = "ABCDEFGHIJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz123456789";

    for( var i=0; i < 8; i++ ){
        text += possible.charAt(Math.floor(Math.random() * possible.length));
    }
    return text;
}

function handleReceiveChannelStatusChange(event) {
	if (receiveChannel) {
		console.log("Receive Channel Status : " + receiveChannel.readyState);
	}
}

function handleSendChannelStatusChange(event) {
	if (sendChannel) {
		var state = sendChannel.readyState;
		console.log('Send Channel Status : '+state);
		if (state === "open") {
			//sendChannel.send('Hello velu!!!');	
		}
	}
}
function handleReceiveMessage(event){
	var data = JSON.parse(event.data);
	var myCanvas = document.getElementById("myCanvas");
	var ctx = myCanvas.getContext("2d");
	if ('started' in data){
		var coordinates = data.started;
		ctx.beginPath();
		ctx.moveTo(coordinates.x, coordinates.y);
	}
	else if('line' in data){
		var coordinates = data.line;
		ctx.lineTo(coordinates.x, coordinates.y);
		ctx.stroke();
	}
}
function handleError(event){
	console.error(event.name +':'+ event.message);
}
/*
function connect(){
	if (localConnection && remoteConnection) {
		// Ice Candidate
		localConnection.onicecandidate = e => !e.candidate || remoteConnection.addIceCandidate(e.candidate).catch(handleError);
		remoteConnection.onicecandidate = e => !e.candidate || localConnection.addIceCandidate(e.candidate).catch(handleError);

		// Creating and answer the offer
		localConnection.createOffer()
		    .then(offer => localConnection.setLocalDescription(offer))
		    .then(() => remoteConnection.setRemoteDescription(localConnection.localDescription))
		    .then(() => remoteConnection.createAnswer())
		    .then(answer => remoteConnection.setLocalDescription(answer))
		    .then(() => localConnection.setRemoteDescription(remoteConnection.localDescription))
		    .catch(handleError);
	}
}
*/