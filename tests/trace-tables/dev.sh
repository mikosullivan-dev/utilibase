clear
export db_path=/tmp/utilibase/ckbzraqt.utilibase
echo $db_path
sqlite3 $db_path < dev.sql
