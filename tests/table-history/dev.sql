.header on
.mode column

pragma table_info(history);
pragma index_list(history);
pragma index_xinfo(history_update_stat);
pragma index_info(history_update_stat);
-- select strftime('%Y-%m-%dT%H:%M:%S+%fZ', 'now');
-- select '2017-03-24T04:04:18+18.098Z' like '____-__-__T__:__:__+__.___Z';


