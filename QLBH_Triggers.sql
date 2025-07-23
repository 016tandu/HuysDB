-- ?? bài 1: m?i l?n insert vào table chiTietHD, mà không ?i?n thông tin vào c?t thanhtien
-- thì trigger này s? t? ??ng t?o phép tính ?? c?p nh?t c?t thành ti?n 

CREATE TRIGGER trg_UpdateHoaDonTongTien
ON ChiTiet_HD
AFTER INSERT
AS
BEGIN
    -- ??m b?o trigger x? lý ???c tr??ng h?p nhi?u dòng ???c thêm vào cùng lúc
    -- C?p nh?t TONGTIEN trong b?ng HoaDon
    UPDATE HD
    SET TONGTIEN = ISNULL(HD.TONGTIEN, 0) + (i.SOLUONG * MH.DONGIA)
    FROM HoaDon AS HD
    INNER JOIN INSERTED AS i ON HD.MSHD = i.MSHD -- L?y d? li?u t? các dòng v?a ???c thêm vào
    INNER JOIN MatHang AS MH ON i.MSMH = MH.MSMH; -- L?y ??n giá t? b?ng MatHang
END;
GO


PRINT '--- TR??C KHI INSERT ---';
-- B??c 1: Xem TONGTIEN hi?n t?i c?a hóa ??n có MSHD = '1'
SELECT MSHD, TONGTIEN FROM HoaDon WHERE MSHD = '1';

-- B??c 2: Thêm m?t chi ti?t hóa ??n m?i vào ChiTietHD cho MSHD = '1'
-- Gi? s? thêm MSMH = 'M0002' (Mouse HP P/s 2) v?i SOLUONG = 5
-- DonGia c?a M0002 là 56000.00
-- Expected increase: 5 * 56000 = 280000.00
-- TONGTIEN m?i d? ki?n: 2150000.00 + 280000.00 = 2430000.00
INSERT INTO ChiTiet_HD (MSHD, MSMH, SOLUONG, THANHTIEN)
VALUES ('3', 'C0001', 5, 0); -- THANHTIEN có th? ?? 0 ho?c NULL, trigger s? c?p nh?t TONGTIEN




-- ??: t?o trigger t? ??ng gi?m s? l??ng t?n kho m?i khi m?t hóa ??n ???c xu?t
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
Câu 2: (2.5 ?i?m)
Trigger Ng?n Ch?n C?p Nh?t Thông Tin Quan Tr?ng c?a Nhân Viên

Vi?t m?t trigger INSTEAD OF UPDATE trên b?ng NhanVien.
Trigger này s? ng?n ch?n vi?c c?p nh?t tr??ng MSNV (Mã S? Nhân Viên) c?a b?t k? nhân viên nào
. N?u ng??i dùng c? g?ng c?p nh?t MSNV, trigger s? h?y b? thao tác
và ??a ra thông báo l?i rõ ràng. ??i v?i các c?t khác, trigger v?n cho phép c?p nh?t bình th??ng.

Ki?n th?c v?n d?ng: Trigger INSTEAD OF, b?ng ?o INSERTED và DELETED, 
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
Câu 3: (2.5 ?i?m)
Trigger ?i?u Ch?nh T?n Kho và Giá Tr? Hóa ??n khi C?p Nh?t S? L??ng Chi Ti?t

Vi?t m?t trigger AFTER UPDATE trên b?ng ChiTietHD. Trigger này s? th?c hi?n các công vi?c sau:

?i?u ch?nh s? l??ng t?n kho: Khi tr??ng SOLUONG c?a m?t chi ti?t hóa ??n b? thay ??i, hãy ?i?u ch?nh SL_TON (S? L??ng T?n) c?a m?t hàng t??ng ?ng trong b?ng MatHang. (L?u ý: c?n tính toán s? t?ng/gi?m ròng c?a s? l??ng).

C?p nh?t thành ti?n chi ti?t: C?p nh?t l?i THANHTIEN c?a chi ti?t hóa ??n ?ó.

C?p nh?t t?ng ti?n hóa ??n: C?p nh?t l?i TONGTIEN c?a hóa ??n liên quan trong b?ng HoaDon.

Ki?n th?c v?n d?ng: B?ng ?o INSERTED và DELETED, UPDATE() function, x? lý multi-row updates, các phép toán s? h?c.
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
    SET NOCOUNT ON; -- T?t thông báo s? dòng b? ?nh h??ng.

    -- Ki?m tra xem có b?t k? dòng nào ???c c?p nh?t không
    IF NOT EXISTS (SELECT 1 FROM INSERTED) OR NOT EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        RETURN; -- Không có gì ?? x? lý n?u không có dòng nào b? ?nh h??ng
    END;

    -- Ch? th?c thi logic n?u c?t SOLUONG ho?c MSMH b? thay ??i
    -- (Thêm ki?m tra MSMH vì thay ??i m?t hàng c?ng ?nh h??ng t?n kho và giá)
    IF UPDATE(SOLUONG) OR UPDATE(MSMH)
    BEGIN
        -- B?ng t?m ?? tính toán s? thay ??i s? l??ng t?n kho và t?n kho d? ki?n
        -- ?ây là chìa khóa ?? x? lý nhi?u dòng cùng lúc
        DECLARE @StockChanges TABLE (
            MSMH CHAR(6) PRIMARY KEY,
            QuantityChange INT,          -- S? thay ??i ròng v? s? l??ng (SOLUONG m?i - SOLUONG c?)
            CurrentStock INT,            -- S? l??ng t?n kho hi?n t?i c?a m?t hàng
            ProjectedStock INT           -- S? l??ng t?n kho d? ki?n sau khi c?p nh?t
        );

        -- Tính toán s? thay ??i s? l??ng cho t?ng m?t hàng b? ?nh h??ng
        -- và l?y s? l??ng t?n kho hi?n t?i.
        -- S? d?ng FULL OUTER JOIN ?? x? lý tr??ng h?p MSMH thay ??i
        INSERT INTO @StockChanges (MSMH, QuantityChange, CurrentStock)
        SELECT
            COALESCE(i.MSMH, d.MSMH) AS MSMH, -- L?y MSMH t? inserted ho?c deleted
            ISNULL(i.SOLUONG, 0) - ISNULL(d.SOLUONG, 0) AS QuantityChange, -- S? l??ng m?i - S? l??ng c?
            MH.SL_TON AS CurrentStock
        FROM INSERTED AS i
        FULL OUTER JOIN DELETED AS d ON i.MSHD = d.MSHD AND i.MSMH = d.MSMH
        INNER JOIN MatHang AS MH ON COALESCE(i.MSMH, d.MSMH) = MH.MSMH;

        -- Tính toán s? l??ng t?n kho d? ki?n
        UPDATE SC
        SET ProjectedStock = SC.CurrentStock - SC.QuantityChange -- T?n kho hi?n t?i - (S? l??ng m?i - S? l??ng c?)
        FROM @StockChanges AS SC;

        -- Ki?m tra xem có b?t k? m?t hàng nào có s? l??ng t?n kho d? ki?n b? âm không
        IF EXISTS (SELECT 1 FROM @StockChanges WHERE ProjectedStock < 0)
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR (N'L?i: Không ?? s? l??ng t?n kho cho m?t ho?c nhi?u m?t hàng sau khi c?p nh?t hóa ??n. Giao d?ch ?ã b? h?y b?.', 16, 1);
            RETURN;
        END;

        -- N?u ?? t?n kho, ti?n hành c?p nh?t SL_TON trong b?ng MatHang
        UPDATE MH
        SET SL_TON = SC.ProjectedStock
        FROM dbo.MatHang AS MH
        INNER JOIN @StockChanges AS SC ON MH.MSMH = SC.MSMH;

        -- C?p nh?t THANHTIEN cho các dòng ChiTietHD v?a ???c c?p nh?t
        -- S? d?ng INNER JOIN v?i INSERTED ?? l?y SOLUONG và DONGIA m?i
        UPDATE CT
        SET CT.THANHTIEN = i.SOLUONG * MH.DONGIA
        FROM dbo.ChiTietHD AS CT
        INNER JOIN INSERTED AS i ON CT.MSHD = i.MSHD AND CT.MSMH = i.MSMH
        INNER JOIN MatHang AS MH ON i.MSMH = MH.MSMH;

        -- C?p nh?t TONGTIEN cho các HoaDon b? ?nh h??ng
        -- S? d?ng b?ng inserted ?? l?y MSHD c?a các hóa ??n c?n c?p nh?t
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
Câu 4: (3 ?i?m)
Trigger Ki?m Tra T?n Kho T?ng Th? khi Thêm Hóa ??n M?i

Vi?t m?t trigger AFTER INSERT trên b?ng HoaDon. Trigger này s? ki?m tra xem t?t c? các m?t hàng trong t?t c? các ChiTietHD liên quan ??n HoaDon v?a ???c t?o có ?? SL_TON (S? L??ng T?n) trong b?ng MatHang hay không. N?u t?ng s? l??ng yêu c?u c?a b?t k? m?t hàng nào trong các chi ti?t hóa ??n v??t quá SL_TON hi?n có c?a nó, trigger s? h?y b? toàn b? giao d?ch INSERT (bao g?m c? HoaDon và các ChiTietHD c?a nó) và ??a ra thông báo l?i. N?u ??, trigger s? ti?n hành tr? SL_TON cho các m?t hàng.

Ki?n th?c v?n d?ng: Trigger AFTER INSERT trên b?ng cha, b?ng ?o INSERTED (c?a b?ng cha), JOIN v?i b?ng con (ChiTietHD) và b?ng MatHang, s? d?ng SUM() và GROUP BY ?? t?ng h?p s? l??ng, EXISTS ho?c NOT EXISTS ?? ki?m tra ?i?u ki?n, ROLLBACK TRANSACTION, RAISERROR. Có th? c?n s? d?ng b?ng t?m th?i (#TableName ho?c @tableVariable) ?? tính toán trung gian.
*/

/**
Câu 5: (3.5 ?i?m)
Trigger B?o V? D? Li?u L?ch S? Hóa ??n

Vi?t m?t trigger INSTEAD OF DELETE trên b?ng HoaDon. Trigger này s? không th?c s? xóa hóa ??n kh?i b?ng HoaDon. Thay vào ?ó, nó s?:

Chuy?n hóa ??n sang b?ng l?u tr?: Di chuy?n hóa ??n (và t?t c? các chi ti?t hóa ??n liên quan t? ChiTietHD) sang m?t b?ng l?ch s? m?i có tên HoaDonLichSu và ChiTietHDLichSu (b?n c?n t? ??nh ngh?a c?u trúc c?a hai b?ng này, có th? thêm c?t NgayXoa và NguoiXoa).

Ng?n ch?n xóa n?u không ?? quy?n: N?u ng??i dùng c? g?ng xóa hóa ??n nh?ng không ph?i là ng??i qu?n tr? (ví d?: SUSER_SNAME() <> 'sa'), trigger s? ng?n ch?n thao tác và ??a ra thông báo l?i.

Ghi log: Ghi l?i s? ki?n "xóa" này vào m?t b?ng log riêng bi?t (ví d?: AuditLog).

Ki?n th?c v?n d?ng: Trigger INSTEAD OF DELETE, b?ng ?o DELETED, INSERT INTO ... SELECT FROM ..., DELETE (trên b?ng g?c), ROLLBACK TRANSACTION, RAISERROR, SUSER_SNAME(), t?o b?ng log m?i.