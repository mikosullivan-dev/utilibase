.header on
.mode column

-- select strftime('%Y-%m-%dT%H:%M:%S+%fZ', current_timestamp);
delete from traces;

insert into traces(trace_uuid) values('f39f2303-5104-4f62-a258-7a6cd68d7160');
select * from traces;
