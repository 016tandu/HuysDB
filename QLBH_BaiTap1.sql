/**
C�u 1: (1.5 ?i?m)
Vi?t th? t?c li?t k� danh s�ch m?t h�ng c� s? l??ng t?n nh? h?n ho?c b?ng 10.
C�u 2 (2 ?i?m)
Vi?t th? t?c x�a h�a ??n v� c�c d�ng chi ti?t li�n quan
C�u 3 (1.5 ?i?m)
Vi?t h�m tr? v? t?ng s? l??ng t?n c?a t?t c? m?t h�ng c� ??n gi� tr�n 1.500.000.
C�u 4 (2 ?i?m)
H�m t�nh t?ng ti?n c?a h�a ??n */


---		Cau 1	---
create procedure sp_tonKhoThap
as 
begin 
	select * from MatHang where SL_TON <= 10
end
go

exec sp_tonKhoTHap

---		Cau 2	---

--- test data de xoa 
select * from ChiTiet_HD
select * from HoaDon 

insert into HoaDon values  (5, 'NV001', 3, '2026-06-11', 0)
insert into ChiTiet_HD values (5, 'C0001', 1, 2000000.00 )

-- tao sp 

alter procedure sp_xoaHoaDon @MSHD int 
as
begin
	delete from ChiTiet_HD where MSHD = @MSHD
	delete from HoaDon where mshd = @mshd 
	-- note: khi xoa mot table -> phai xoa dung table phu thuoc vao no (co fk tro den no)
end
go

exec sp_xoaHoaDon 5

---  Cau 3	---


alter function dbo.fun_tongSoLuongTon()
returns int 
as 
	begin
	declare @Tong int 
	set @tong = (select sum(SL_TON) from MatHang where DONGIA > 1500000.00)
	return @Tong
	end
go

select * from MatHang
SELECT dbo.fun_tongSoLuongTon() AS TongSoLuongTonLonHon1_5Trieu;


---	Cau 4 ---

select * from MatHang
select * from HoaDon
select * from ChiTiet_HD


create function dbo.fun_tongTienHoaDon(@MSHD int)
returns int 
as 
	begin
	declare @TongTien int = 0
	set @TongTien = (
		select sum(SOLUONG * DONGIA) from 
		chitiet_hd ct join mathang mh on ct.msmh = mh.msmh
	)
	return cast(@TongTien as money)
	end
go


select  dbo.fun_TongTienHoaDon(5) as tonghoadon;