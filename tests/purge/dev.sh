clear
export db_path=`cat /tmp/utilibase/latest_new_db.txt`
echo $db_path
sqlite3 $db_path < dev.sql
