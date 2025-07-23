SELECT TOP (1000) [MSKH]
      ,[TENKH]
      ,[PHAI]
      ,[DIACHI]
      ,[DIENTHOAI]
  FROM [QL_BanHang].[dbo].[KhachHang]

  print 'chi tiet hoa don'
  select * from dbo.ChiTiet_HD
  print 'hoa don'
  select * from dbo.HoaDon
  select * from KhachHang
  select * from MatHang

  insert into dbo.HoaDon
  values (4, 'NV001', 3, '2025-07-15', 0)

  insert into dbo.ChiTiet_HD 
  values (4, 'C0001', 1, 2000000.00)