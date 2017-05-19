.header on
.mode column

delete from history where record_uuid = '8c11f18d-1043-4b47-b231-42c7abcdd6ee';

insert into
	history(
		version_uuid,
		record_uuid,
		jhash,
		links
	)
	
		select
			'85ead2b6-77e4-4478-a371-893783c9feb9',
			record_uuid,
			jhash,
			links
		from
			current
		where
			record_uuid = '8c11f18d-1043-4b47-b231-42c7abcdd6ee';

select * from history;