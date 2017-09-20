<?php
if(!session_id()){ session_start();	}
call_user_func($_GET['cb']);

function createFile($filename, $json){
	$file = fopen($filename, 'w');
	fwrite($file, $json);
	fclose($file);
}

function read($filename){
	$file = str_replace('ajax.php', $filename, $_SERVER['SCRIPT_FILENAME']);
	return @file_get_contents($file);
}

function saveOffer(){
	$result['result'] = 0;
	if (isset($_POST['room']) && isset($_POST['offer'])){
		$data = json_decode(read('info.json'), true);
		$data[$_POST['room']] = $_POST['offer'];
		createFile('info.json', json_encode($data));
		$result['result'] = 1;
	}
	echo json_encode($result);
}

function findOffer(){
	$result['result'] = 0;
	if (isset($_GET['room']) && $_GET['room']){
		$room = $_GET['room'];
		$data = json_decode(read('info.json'), true);
		if(array_search($room, array_keys($data))){
			$result['offer'] = json_decode($data[$room], true);
			$result['room'] = $room;
			$result['result'] = 1;
		}
	}
	echo json_encode($result);
}

function getClients(){
	$result['result'] = 0;
	if (isset($_GET['room']) && $_GET['room']){
		$room = $_GET['room'];
		$data = json_decode(read('clients.json'), true);
		if ($data && in_array($room, array_keys($data))){
			$result['clients'] = $data[$room];
			$result['result'] = 1;
		}
	}
	echo json_encode($result);
}

function saveClient(){
	$result['result'] = 0;
	if (isset($_POST['room']) && $_POST['room']){
		$room = $_POST['room'];
		$data = json_decode(read('clients.json'), true);
		switch ($_POST['type']) {
			/*case 'icecandidate':
				$data[$room][$key]['icecandidate'] = $_POST['candidate'];
			break;*/
			case 'answerDesc':
				$data[$room]['answer'][] = $_POST['answer'];
			break;
		}
		createFile('clients.json', json_encode($data));
		$result['result'] = 1;
	}
	echo json_encode($result);
}