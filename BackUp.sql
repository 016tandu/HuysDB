---	 Back up ---

backup database QuanLyBanHang to disk = 'C:\Users\PC\Documents\SQL Server Management Studio\HuysDB'

-- restore

-- back up database if the PC doesnt 
restore database DoAn from disk = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\DoAn.bak'
-- if the pc already has the db 
restore database DoAn from disk = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\DoAn.bak' with replace