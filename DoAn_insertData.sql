-- 1. SINHVIEN
INSERT INTO SINHVIEN VALUES
('97TH01', N'Nguy?n V?n An', '9688543', '97TH1', N'12 NTMK'),
('97TH02', N'Tr?n Hùng', '8453443', '97TH1', N'13/4 LCT'),
('97TH03', N'Lê Thuý H?ng', '8544457', '97TH1', N'20 Pasteur'),
('97TH04', N'Ngô Khoa', '8545439', '97TH2', N'54/12 LHP'),
('97TH05', N'Ph?m Tài', '8149023', '97TH2', N'12 HBT'),
('97TH06', N'?inh Ti?n', '8956123', '97TH1', N'31 TH?');

-- 2. DETAI
INSERT INTO DETAI VALUES
('97001', N'Qu?n lý th? vi?n'),
('97002', N'Nh?n d?ng vân tay'),
('97003', N'Bán ??u giá trên m?ng'),
('97004', N'Qu?n lý siêu th?'),
('97005', N'X? lý ?nh');

-- 3. SV_DETAI
INSERT INTO SV_DETAI VALUES
('97TH01', '97004'),
('97TH02', '97005'),
('97TH03', '97001'),
('97TH04', '97002'),
('97TH05', '97003'),
('97TH06', '97005');

-- 4. HOCHAM
INSERT INTO HOCHAM VALUES
(1, N'Phó giáo s?'),
(2, N'Giáo s?');

-- 5. GIAOVIEN
INSERT INTO GIAOVIEN VALUES
(1, N'Nguy?n V?n A', N'11 NV?', '8754321', NULL, '1996-01-01'),
(2, N'Tr?n Thu Trang', N'56 XVNT', '8964334', NULL, '1996-01-01'),
(3, N'Lê Trung', N'12/5 CMTT', '8903561', NULL, '1996-01-01'),
(4, N'Nguy?n Th? Loan', N'321 BTX', '8012864', NULL, '1997-01-01'),
(5, N'Chu V Ti?n', N'1/60 TV?', '8157906', NULL, '1997-01-01');

-- 6. HOCVI
INSERT INTO HOCVI VALUES
(1, N'KS'),
(2, N'CN'),
(3, N'Th.S'),
(4, N'TS'),
(5, N'TSKH');

-- 7. CHUYENNGANH
INSERT INTO CHUYENNGANH VALUES
(1, N'H? th?ng thông tin'),
(2, N'M?ng'),
(3, N'?? h?a'),
(4, N'Công ngh? ph?n m?m');

-- 8. GV_HV_CN
INSERT INTO GV_HV_CN VALUES
(1, 1, 1, '1999-01-01'),
(1, 1, 2, '1999-01-01'),
(1, 2, 1, '1998-01-01'),
(2, 3, 2, '1997-01-01'),
(3, 2, 4, '1997-01-01'),
(4, 3, 2, '1996-01-01');

-- 9. GV_HDDT
INSERT INTO GV_HDDT VALUES
(1, '97001', 7),
(2, '97002', 8),
(5, '97003', 9),
(4, '97004', 8.5),
(3, '97005', 7);

-- 10. GV_PBDT
INSERT INTO GV_PBDT VALUES
(1, '97002', 5),
(2, '97001', 7),
(5, '97004', 6),
(4, '97003', 8.5),
(5, '97005', 8);

-- 11. GV_UVDT
INSERT INTO GV_UVDT VALUES
(1, '97005', 6),
(2, '97005', 5),
(4, '97005', 5),
(3, '97001', 7),
(4, '97001', 7),
(5, '97001', 8),
(3, '97003', 10),
(4, '97003', 7),
(5, '97003', 7),
(1, '97004', 8),
(2, '97004', 9),
(5, '97004', 5),
(2, '97002', 9),
(4, '97002', 9),
(5, '97002', 6);

-- 12. HOIDONG
INSERT INTO HOIDONG VALUES
(1, 2, '2001-10-30 07:00:00', '2001-10-30', N'Th?t', 1),
(2, 102, '2001-10-30 07:00:00', '2001-10-30', N'Th?', 2),
(3, 3, '2001-10-31 08:00:00', '2001-10-31', N'Th?', 3);

-- 13. HOIDONG_GV
INSERT INTO HOIDONG_GV VALUES
(1,1), (1,2), (1,3), (1,4),
(2,3), (2,2), (2,5), (2,4);

-- 14. HOIDONG_DT
INSERT INTO HOIDONG_DT VALUES
(1, '97001', N'???c'),
(1, '97002', N'???c'),
(2, '97003', N'Không'),
(2, '97004', N'Không'),
(1, '97005', N'???c');
