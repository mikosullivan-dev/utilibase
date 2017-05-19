clear
export db_path=/tmp/utilibase/rmizxwbv.utilibase
echo $db_path
sqlite3 $db_path < dev.sql
