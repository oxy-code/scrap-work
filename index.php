<?php
$jsondata = json_decode(file_get_contents('https://jsonplaceholder.typicode.com/posts'), true);

// sort
if (isset($_GET['sort']) && $_GET['sort']){
	list($field, $direction) = explode(':', $_GET['sort']);
	array_multisort(array_map(function($item) use ($field){
		return [$field => $item[$field]];
	}, $jsondata), $direction === 'desc' ? SORT_DESC : SORT_ASC, $jsondata);
	//echo "<pre>";print_r($jsondata);exit;
}

// limit
$limit = (isset($_GET['limit']) && $_GET['limit']) ? $_GET['limit'] : 10;

// page
$pageNo = (isset($_GET['page']) && $_GET['page']) ? $_GET['page'] : 1;

/*{
	start: Integer // index of the record
	end: Integer // index of the record
	total: Integer // overall records fetched by the query
	next: url string | boolean false // next page url along with same query params
	prev: url string | boolean false // previous page url along with same query params
	data: [] // records for the current page
}*/
$results = [
	'start' => (($pageNo * $limit) - $limit) + 1,
	'end' => $limit * $pageNo,
	'total' => 0,
	'next' => false,
	'prev' => false,
	'data' => []
];
$url = $_SERVER['QUERY_STRING'] ? $_SERVER['QUERY_STRING'] : 'sort=id:asc&limit=' . $limit . '&page=' . $pageNo;

// data based on limit and page no
if ($results['start'] - 1 > 0){
	$results['data'] = array_slice($jsondata, $results['start'] - 1, $limit);
}
else{
	$results['data'] = array_slice($jsondata, 0, $limit);
}
$results['total'] = count($jsondata);

// next page url - if next set of data is available
if ($results['end'] < $results['total'] && $results['total'] > ($limit * $pageNo)) {
	$results['next'] = str_replace('page='.$pageNo, 'page='.($pageNo+1), $url);
}
else{
	$results['end'] = $results['total'];
}

// prev page url - if prev set of data is available
if ($pageNo > 1){
	$results['prev'] = str_replace('page='.$pageNo, 'page='.($pageNo-1), $url);
}

echo json_encode($results);
?>