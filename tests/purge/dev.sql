.header on
.mode column
pragma foreign_keys = on;

select   unlinked
from     current
where    unlinked is not null;
