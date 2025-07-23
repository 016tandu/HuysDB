-- ?? b�i 1: m?i l?n insert v�o table chiTietHD, m� kh�ng ?i?n th�ng tin v�o c?t thanhtien
-- th� trigger n�y s? t? ??ng t?o ph�p t�nh ?? c?p nh?t c?t th�nh ti?n 

CREATE TRIGGER trg_UpdateHoaDonTongTien
ON ChiTiet_HD
AFTER INSERT
AS
BEGIN
    -- ??m b?o trigger x? l� ???c tr??ng h?p nhi?u d�ng ???c th�m v�o c�ng l�c
    -- C?p nh?t TONGTIEN trong b?ng HoaDon
    UPDATE HD
    SET TONGTIEN = ISNULL(HD.TONGTIEN, 0) + (i.SOLUONG * MH.DONGIA)
    FROM HoaDon AS HD
    INNER JOIN INSERTED AS i ON HD.MSHD = i.MSHD -- L?y d? li?u t? c�c d�ng v?a ???c th�m v�o
    INNER JOIN MatHang AS MH ON i.MSMH = MH.MSMH; -- L?y ??n gi� t? b?ng MatHang
END;
GO


PRINT '--- TR??C KHI INSERT ---';
-- B??c 1: Xem TONGTIEN hi?n t?i c?a h�a ??n c� MSHD = '1'
SELECT MSHD, TONGTIEN FROM HoaDon WHERE MSHD = '1';

-- B??c 2: Th�m m?t chi ti?t h�a ??n m?i v�o ChiTietHD cho MSHD = '1'
-- Gi? s? th�m MSMH = 'M0002' (Mouse HP P/s 2) v?i SOLUONG = 5
-- DonGia c?a M0002 l� 56000.00
-- Expected increase: 5 * 56000 = 280000.00
-- TONGTIEN m?i d? ki?n: 2150000.00 + 280000.00 = 2430000.00
INSERT INTO ChiTiet_HD (MSHD, MSMH, SOLUONG, THANHTIEN)
VALUES ('3', 'C0001', 5, 0); -- THANHTIEN c� th? ?? 0 ho?c NULL, trigger s? c?p nh?t TONGTIEN




-- ??: t?o trigger t? ??ng gi?m s? l??ng t?n kho m?i khi m?t h�a ??n ???c xu?t
-- table ?nh h??ng:  Mat_Hang.SL_Ton

create TRIGGER trigger_giamSoLuongTon
ON dbo.ChiTiet_HD
after INSERT
AS
BEGIN
    UPDATE MH 
    set SL_TON = (SL_TON - i.SOLUONG)
    from MatHang MH inner join ChiTiet_HD CT on MH.MSMH = CT.MSMH
                    inner join INSERTED i on  i.MSMH = ct.MSMH
                    inner join HoaDon HD on HD.MSHD = ct.MSHD
END;
GO

select*
from NhanVien


/**
C�u 2: (2.5 ?i?m)
Trigger Ng?n Ch?n C?p Nh?t Th�ng Tin Quan Tr?ng c?a Nh�n Vi�n

Vi?t m?t trigger INSTEAD OF UPDATE tr�n b?ng NhanVien.
Trigger n�y s? ng?n ch?n vi?c c?p nh?t tr??ng MSNV (M� S? Nh�n Vi�n) c?a b?t k? nh�n vi�n n�o
. N?u ng??i d�ng c? g?ng c?p nh?t MSNV, trigger s? h?y b? thao t�c
v� ??a ra th�ng b�o l?i r� r�ng. ??i v?i c�c c?t kh�c, trigger v?n cho ph�p c?p nh?t b�nh th??ng.

Ki?n th?c v?n d?ng: Trigger INSTEAD OF, b?ng ?o INSERTED v� DELETED, 
ROLLBACK TRANSACTION, RAISERROR, UPDATE() function ?? ki?m tra c?t b? thay ??i.
*/

alter trigger dbo.BaoVeThongTin
on dbo.NhanVien 
instead of update 
as 
begin
    set nocount on 
    if update(MSNV)
        BEGIN
            RAISERROR('You cant update employee ids', 16, 1)
            rollback transaction
            RETURN
        END

    BEGIN
        update nv
        set nv.TENNV = i.tenNV, 
            nv.ngaysinh = i.ngaysinh,
            nv.phai = i.phai,
            nv.diachi = i.diachi,
            nv.dienthoai = i.dienthoai
        from
            nhanvien nv 
                join inserted i 
                    on I.msnv = nv.msnv
                join deleted d 
                    on d.msnv = nv.msnv 
        PRINT('UPDATE IS DONE')
    END
end
go 


update dbo.nhanvien set PHAI = 'Nu' where msnv = 'NV003'
select * from NhanVien

/**
C�u 3: (2.5 ?i?m)
Trigger ?i?u Ch?nh T?n Kho v� Gi� Tr? H�a ??n khi C?p Nh?t S? L??ng Chi Ti?t

Vi?t m?t trigger AFTER UPDATE tr�n b?ng ChiTietHD. Trigger n�y s? th?c hi?n c�c c�ng vi?c sau:

?i?u ch?nh s? l??ng t?n kho: Khi tr??ng SOLUONG c?a m?t chi ti?t h�a ??n b? thay ??i, h�y ?i?u ch?nh SL_TON (S? L??ng T?n) c?a m?t h�ng t??ng ?ng trong b?ng MatHang. (L?u �: c?n t�nh to�n s? t?ng/gi?m r�ng c?a s? l??ng).

C?p nh?t th�nh ti?n chi ti?t: C?p nh?t l?i THANHTIEN c?a chi ti?t h�a ??n ?�.

C?p nh?t t?ng ti?n h�a ??n: C?p nh?t l?i TONGTIEN c?a h�a ??n li�n quan trong b?ng HoaDon.

Ki?n th?c v?n d?ng: B?ng ?o INSERTED v� DELETED, UPDATE() function, x? l� multi-row updates, c�c ph�p to�n s? h?c.
*/


alter trigger dbo.UpdateChiTietHD
on dbo.ChiTIet_HD
after update
as 
begin
    set nocount on 
    if update(soluong)
        BEGIN
            declare @mshd int = (select mshd from inserted)
            declare @msmh char(6) = (select msmh from inserted)
            

            -- b0: update so luong ton 

            declare @soLuongMoi int = (select soluong from inserted)
            declare @soLuongCu int = (select soluong from deleted)
            declare @tonKhoMoi int = (select (SL_Ton + (@soLuongCu - @soLuongMoi)) from MatHang where msmh = @msmh ) 

            if(@tonKhoMoi < 0)
            begin 
                RAISERROR('The product is out of stock!', 16, 1)
                rollback transaction
                return
            end

            update MatHang set SL_TON = SL_Ton + (@soLuongCu - @soLuongMoi) where msmh = @msmh 
            
           -- b1: update thanh tien from chi tiet hoa don

            declare @thanhTien money
            set @thanhTIen = (
		        select (ct.SOLUONG * DONGIA) from 
		        chitiet_hd ct 
                    join mathang mh 
                    on ct.msmh = mh.msmh
                    join inserted i on mh.msmh = i.msmh and ct.mshd = i.mshd 
		        )
            update ChiTiet_HD set THANHTIEN = @thanhTien where mshd = @mshd and msmh = @msmh
            -- b2: update tong tien
            declare @tongtien money 
            set @tongtien = (
                select sum(ct.thanhtien)
                from ChiTiet_HD ct 
                      join inserted i 
                      on ct.mshd = i.mshd 
                )
            update hd set hd.TONGTIEN = @tongtien 
            from HoaDon hd join ChiTiet_HD ct 
            on ct.mshd = hd.mshd 
            join inserted i on i.mshd = ct.mshd
        END
end
go 

select * from ChiTiet_HD
select * from MatHang 
select * from HoaDon

--- test 
update ChiTiet_HD set soluong =  10 where mshd = 3 and msmh = 'C0001'




-- Cau 3: multi insert solution

IF OBJECT_ID('dbo.UpdateChiTietHD') IS NOT NULL
    DROP TRIGGER dbo.UpdateChiTietHD;
GO

-- B??c 2: T?o TRIGGER UpdateChiTietHD
CREATE TRIGGER dbo.UpdateChiTietHD
ON dbo.ChiTietHD
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON; -- T?t th�ng b�o s? d�ng b? ?nh h??ng.

    -- Ki?m tra xem c� b?t k? d�ng n�o ???c c?p nh?t kh�ng
    IF NOT EXISTS (SELECT 1 FROM INSERTED) OR NOT EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        RETURN; -- Kh�ng c� g� ?? x? l� n?u kh�ng c� d�ng n�o b? ?nh h??ng
    END;

    -- Ch? th?c thi logic n?u c?t SOLUONG ho?c MSMH b? thay ??i
    -- (Th�m ki?m tra MSMH v� thay ??i m?t h�ng c?ng ?nh h??ng t?n kho v� gi�)
    IF UPDATE(SOLUONG) OR UPDATE(MSMH)
    BEGIN
        -- B?ng t?m ?? t�nh to�n s? thay ??i s? l??ng t?n kho v� t?n kho d? ki?n
        -- ?�y l� ch�a kh�a ?? x? l� nhi?u d�ng c�ng l�c
        DECLARE @StockChanges TABLE (
            MSMH CHAR(6) PRIMARY KEY,
            QuantityChange INT,          -- S? thay ??i r�ng v? s? l??ng (SOLUONG m?i - SOLUONG c?)
            CurrentStock INT,            -- S? l??ng t?n kho hi?n t?i c?a m?t h�ng
            ProjectedStock INT           -- S? l??ng t?n kho d? ki?n sau khi c?p nh?t
        );

        -- T�nh to�n s? thay ??i s? l??ng cho t?ng m?t h�ng b? ?nh h??ng
        -- v� l?y s? l??ng t?n kho hi?n t?i.
        -- S? d?ng FULL OUTER JOIN ?? x? l� tr??ng h?p MSMH thay ??i
        INSERT INTO @StockChanges (MSMH, QuantityChange, CurrentStock)
        SELECT
            COALESCE(i.MSMH, d.MSMH) AS MSMH, -- L?y MSMH t? inserted ho?c deleted
            ISNULL(i.SOLUONG, 0) - ISNULL(d.SOLUONG, 0) AS QuantityChange, -- S? l??ng m?i - S? l??ng c?
            MH.SL_TON AS CurrentStock
        FROM INSERTED AS i
        FULL OUTER JOIN DELETED AS d ON i.MSHD = d.MSHD AND i.MSMH = d.MSMH
        INNER JOIN MatHang AS MH ON COALESCE(i.MSMH, d.MSMH) = MH.MSMH;

        -- T�nh to�n s? l??ng t?n kho d? ki?n
        UPDATE SC
        SET ProjectedStock = SC.CurrentStock - SC.QuantityChange -- T?n kho hi?n t?i - (S? l??ng m?i - S? l??ng c?)
        FROM @StockChanges AS SC;

        -- Ki?m tra xem c� b?t k? m?t h�ng n�o c� s? l??ng t?n kho d? ki?n b? �m kh�ng
        IF EXISTS (SELECT 1 FROM @StockChanges WHERE ProjectedStock < 0)
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR (N'L?i: Kh�ng ?? s? l??ng t?n kho cho m?t ho?c nhi?u m?t h�ng sau khi c?p nh?t h�a ??n. Giao d?ch ?� b? h?y b?.', 16, 1);
            RETURN;
        END;

        -- N?u ?? t?n kho, ti?n h�nh c?p nh?t SL_TON trong b?ng MatHang
        UPDATE MH
        SET SL_TON = SC.ProjectedStock
        FROM dbo.MatHang AS MH
        INNER JOIN @StockChanges AS SC ON MH.MSMH = SC.MSMH;

        -- C?p nh?t THANHTIEN cho c�c d�ng ChiTietHD v?a ???c c?p nh?t
        -- S? d?ng INNER JOIN v?i INSERTED ?? l?y SOLUONG v� DONGIA m?i
        UPDATE CT
        SET CT.THANHTIEN = i.SOLUONG * MH.DONGIA
        FROM dbo.ChiTietHD AS CT
        INNER JOIN INSERTED AS i ON CT.MSHD = i.MSHD AND CT.MSMH = i.MSMH
        INNER JOIN MatHang AS MH ON i.MSMH = MH.MSMH;

        -- C?p nh?t TONGTIEN cho c�c HoaDon b? ?nh h??ng
        -- S? d?ng b?ng inserted ?? l?y MSHD c?a c�c h�a ??n c?n c?p nh?t
        UPDATE HD
        SET TONGTIEN = (SELECT SUM(CT_Inner.SOLUONG * MH_Inner.DONGIA)
                        FROM dbo.ChiTietHD AS CT_Inner
                        INNER JOIN dbo.MatHang AS MH_Inner ON CT_Inner.MSMH = MH_Inner.MSMH
                        WHERE CT_Inner.MSHD = HD.MSHD)
        FROM dbo.HoaDon AS HD
        INNER JOIN (SELECT DISTINCT MSHD FROM INSERTED) AS i_distinct ON HD.MSHD = i_distinct.MSHD;

    END; -- End IF UPDATE(SOLUONG) OR UPDATE(MSMH)
END;
GO


/**
C�u 4: (3 ?i?m)
Trigger Ki?m Tra T?n Kho T?ng Th? khi Th�m H�a ??n M?i

Vi?t m?t trigger AFTER INSERT tr�n b?ng HoaDon. Trigger n�y s? ki?m tra xem t?t c? c�c m?t h�ng trong t?t c? c�c ChiTietHD li�n quan ??n HoaDon v?a ???c t?o c� ?? SL_TON (S? L??ng T?n) trong b?ng MatHang hay kh�ng. N?u t?ng s? l??ng y�u c?u c?a b?t k? m?t h�ng n�o trong c�c chi ti?t h�a ??n v??t qu� SL_TON hi?n c� c?a n�, trigger s? h?y b? to�n b? giao d?ch INSERT (bao g?m c? HoaDon v� c�c ChiTietHD c?a n�) v� ??a ra th�ng b�o l?i. N?u ??, trigger s? ti?n h�nh tr? SL_TON cho c�c m?t h�ng.

Ki?n th?c v?n d?ng: Trigger AFTER INSERT tr�n b?ng cha, b?ng ?o INSERTED (c?a b?ng cha), JOIN v?i b?ng con (ChiTietHD) v� b?ng MatHang, s? d?ng SUM() v� GROUP BY ?? t?ng h?p s? l??ng, EXISTS ho?c NOT EXISTS ?? ki?m tra ?i?u ki?n, ROLLBACK TRANSACTION, RAISERROR. C� th? c?n s? d?ng b?ng t?m th?i (#TableName ho?c @tableVariable) ?? t�nh to�n trung gian.
*/

/**
C�u 5: (3.5 ?i?m)
Trigger B?o V? D? Li?u L?ch S? H�a ??n

Vi?t m?t trigger INSTEAD OF DELETE tr�n b?ng HoaDon. Trigger n�y s? kh�ng th?c s? x�a h�a ??n kh?i b?ng HoaDon. Thay v�o ?�, n� s?:

Chuy?n h�a ??n sang b?ng l?u tr?: Di chuy?n h�a ??n (v� t?t c? c�c chi ti?t h�a ??n li�n quan t? ChiTietHD) sang m?t b?ng l?ch s? m?i c� t�n HoaDonLichSu v� ChiTietHDLichSu (b?n c?n t? ??nh ngh?a c?u tr�c c?a hai b?ng n�y, c� th? th�m c?t NgayXoa v� NguoiXoa).

Ng?n ch?n x�a n?u kh�ng ?? quy?n: N?u ng??i d�ng c? g?ng x�a h�a ??n nh?ng kh�ng ph?i l� ng??i qu?n tr? (v� d?: SUSER_SNAME() <> 'sa'), trigger s? ng?n ch?n thao t�c v� ??a ra th�ng b�o l?i.

Ghi log: Ghi l?i s? ki?n "x�a" n�y v�o m?t b?ng log ri�ng bi?t (v� d?: AuditLog).

Ki?n th?c v?n d?ng: Trigger INSTEAD OF DELETE, b?ng ?o DELETED, INSERT INTO ... SELECT FROM ..., DELETE (tr�n b?ng g?c), ROLLBACK TRANSACTION, RAISERROR, SUSER_SNAME(), t?o b?ng log m?i.