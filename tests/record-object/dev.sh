clear
export db_path=/tmp/utilibase/xwefujbn.utilibase
echo $db_path
sqlite3 $db_path < dev.sql
