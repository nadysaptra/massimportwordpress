<?php

$arrDB = [
 'gedungwani',
 'gedungwanitimur',
 'kebondamar',
 'mandalasari',
 'kotaraman',
 'ramanaji',
 'ruktisediyo',
 'brajagemilang',
];

$HOST = '';
$USER = '';
$PASS = '';

foreach ($arrDB as $k => $v) {
 $DB = $v . 'lamtim';
 $connection = new mysqli($HOST, $USER, $PASS, $DB);

 $postQuery = 'SELECT ID as id, meta.meta_value as image_id, post.post_type FROM wp_posts as post LEFT JOIN wp_postmeta as meta ON meta.post_id = post.ID AND meta.meta_key = "_thumbnail_id" WHERE post.post_type = "post"';
 $getImage = 'SELECT meta_id, post_id, meta_key, meta_value FROM wp_postmeta WHERE meta_key = "_wp_attached_file"';
 $getExistImage = "SELECT ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count
FROM wp_posts where post_type = 'attachment' and post_mime_type = 'image/jpeg'";

 if ($connection->connect_errno > 0) {
  die('Unable to connect to database [' . $connection->connect_error . ']');
 }

 if (!$result = $connection->query($postQuery)) {
  die('There was an error running query[' . $connection->error . ']');
 }
 $containerIds = [];
 $containerImage = [];
 $containerImageExist = [];
 while ($row = $result->fetch_assoc()) {
  if ($row['image_id'] == '') {
   array_push($containerIds, $row['id']);
  }
 }

 if (!$resultImage = $connection->query($getImage)) {
  die('There was an error running query[' . $connection->error . ']');
 }
 while ($rowImage = $resultImage->fetch_assoc()) {
  if (!preg_match("#(.*?)" . $DB . "(.*?)#", $rowImage['meta_value'])) {
   array_push($containerImage, $rowImage['meta_value']);
  }
 }

 if (!$resultImageExist = $connection->query($getExistImage)) {
  die('There was an error running query[' . $connection->error . ']');
 }
 while ($rowImageExist = $resultImageExist->fetch_assoc()) {
  if ($rowImageExist['guid'] !== '') {
   array_push($containerImageExist, $rowImageExist['guid']);
  }
 }
 $containerIds = array_unique($containerIds);
 $containerImage = array_unique($containerImage);
 $containerImageExist = array_unique($containerImageExist);

 foreach ($containerIds as $key => $value) {
  $postid = $value;
  $rand = rand(0, count($containerImageExist));
  $fileUrl = $containerImageExist[$rand];
  $explodeImageExist = explode('uploads/', $fileUrl);
  $fileName = $explodeImageExist[1];
  echo "POST: " . $postid . " : " . $rand . " : " . $fileUrl;
  echo "<br>";
  //  STEP 1 -> insert the thumbnail that exist
  $queryInsert = "INSERT INTO wp_posts(post_type, guid, post_status, post_mime_type,post_parent) VALUES ('attachment', '" . $fileUrl . "', 'inherit', 'image/jpeg'," . $postid . ");";
  if (!$result = $connection->query($queryInsert)) {
   die('There was an error running query[' . $connection->error . ']');
  }
  $lastIdthumbnail = $connection->insert_id;
  // STEP 2 -> insert post meta record
  $queryInsertMeta = "INSERT INTO wp_postmeta (meta_value, meta_key, post_id) VALUES ('" . $fileName . "', '_wp_attached_file'," . $lastIdthumbnail . ")";
  if (!$result = $connection->query($queryInsertMeta)) {
   die('There was an error running query[' . $connection->error . ']');
  }
  // STEP 3 -> insert postmeta
  $queryInsertPost = "INSERT INTO wp_postmeta (meta_value, meta_key, post_id) VALUES (" . $lastIdthumbnail . ", '_thumbnail_id'," . $postid . ")";
  if (!$result = $connection->query($queryInsertPost)) {
   die('There was an error running query[' . $connection->error . ']');
  }
 }

}
