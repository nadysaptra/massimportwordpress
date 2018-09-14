UPDATE wp_options SET option_value = REPLACE(option_value, 'http://{OLD_URL}', 'http://{NEW_URL}') WHERE option_name = 'home' OR option_name = 'siteurl';
UPDATE wp_posts SET guid = REPLACE(guid, 'http://{OLD_URL}','http://{NEW_URL}');
UPDATE wp_posts SET post_content = REPLACE(post_content, 'http://{OLD_URL}', 'http://{NEW_URL}');
UPDATE wp_postmeta SET meta_value = REPLACE(meta_value,'http://{OLD_URL}','http://{NEW_URL}');