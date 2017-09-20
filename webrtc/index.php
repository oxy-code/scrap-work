<?php
	if (!isset($_GET['role']) && !$_GET['role']){
		echo 'Missing Role parameter!!!';exit;
	}
	extract($_GET);
	if(!session_id()){
		session_start();
	}
	if (!in_array($role, array('staff', 'student'))){
		echo 'Role must be staff / student';exit;
	}
	if (!isset($_SESSION['roles']) || !in_array($role, $_SESSION['roles'])){
		$_SESSION['roles'][] = $role;
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Whiteboard</title>
		<link rel="stylesheet" href="css/style.css">
		<link rel="stylesheet" href="css/bootstrap.min.css">
		<script src="js/jquery.min-1.11.js"></script>
	</head>
	<body>
		<div class="container-fluid">
			<div class="row">
				<nav class="navbar navbar-default">
					<a href="#" class="navbar-brand">Whiteboard v1.0 alpha <small>&copy; Velu</small></a>
					<span id="notify" style="color:#FFFFFF;padding:15px;" class="pull-left"></span>
					<ul class="list-unstyled pull-right" style="margin-top:15px;margin-right:15px;">
						<li><a href="#"><i class='glyphicon glyphicon-user' style='font-size:20px;'></i></a></li>
					</ul>
				</nav>
			</div>
			<div class="row">
				<div class="col-md-9" style="padding-left:0px;">
					<ul class="list-unstyled toolbox pull-left">
						<li><i class="glyphicon glyphicon-pencil"></i></li>
						<li><i class="glyphicon glyphicon-text-width"></i></li>
						<li><i>R</i></li>
						<li><i>B</i></li>
						<li><i>I</i></li>
						<li><i>T</i></li>
					</ul>
					<canvas id="myCanvas" width='982' height='580'>
						Sorry, your browser does not support white board technology. Kindly use latest browser.
					</canvas>
				</div>
				<div class="col-md-3" style="padding-right:0px;">
					<div class="panel panel-info">
						<div class="panel-heading">
							<h4>Attendees</h4>
						</div>
						<div class="panel-body">
							<ul class="list-unstyled">
								<li><a href="#">Velu (Staff)</a></li>
								<li><a href="#">student1</a></li>
								<li><a href="#">student2</a></li>
							</ul>
						</div>
					</div>
					<div class="panel panel-info">
						<div class="panel-heading">
							<h4>Chat</h4>
						</div>
						<div class="panel-body">
							<ul class="list-unstyled">
								<li><a href="#">To All</a></li>
								<li><a href="#">student1</a></li>
								<li><a href="#">student2</a></li>
							</ul>
						</div>
					</div>
				</div>
			</div>
		</div>
		<script type="text/javascript">
			var baseUrl = '<?php echo $_SERVER['PHP_SELF']; ?>';
			$(document).ready(function(){
				<?php
					switch ($role) {
						case 'staff':
							echo "createOffer();";
						break;
						default:
							echo "getOffer('$room');";
						break;
					}
					/*if (!isset($_SESSION['connectStatus']) || $_SESSION['connectStatus'] !='connected'){
						echo "connect();";
					}*/
				?>
			});
		</script>
		<script src="js/adapter.js"></script>
		<script src="js/app.js"></script>
		<script src="js/index.js"></script>
	</body>
</html>