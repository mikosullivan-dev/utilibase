clear
export db_path=/tmp/utilibase/zbhvluwj.utilibase
echo $db_path
rm -rf $db_path
touch $db_path
sqlite3 $db_path < dev.sql
