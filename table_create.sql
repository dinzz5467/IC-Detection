create table ocr_test (
id int identity(1,1)primary key,
test_desc varchar(200),
test_dt datetime,
total_image int,
total_test int,
total_passed int,
total_failed int,
accuracy int
)

create table ocr_test_item (
id int identity(1,1)primary key,
test_id int,
file_path varchar(300),
name varchar(300),
ic_no varchar(30),
address varchar(max),
name_result varchar(100),
ic_no_result varchar(100),
address_result varchar(100),
test_dt datetime,
eval_dt varchar(10)
)

