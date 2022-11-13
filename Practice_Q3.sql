--QLBH
USE QLBH;
--Ngôn ngữ truy vấn dữ liệu
--1. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất.
SELECT MASP,TENSP
FROM SANPHAM
WHERE NUOCSX='Trung Quoc'

--2. In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”.
SELECT MASP,TENSP
FROM SANPHAM
WHERE DVT IN ('cay','quyen')

--3. In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết thúc là “01”.
SELECT MASP,TENSP
FROM SANPHAM
WHERE MASP LIKE 'B%01'
--4. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 đến 40.000.
SELECT MASP,TENSP
FROM SANPHAM
WHERE NUOCSX='Trung Quoc' AND (GIA BETWEEN 30000 AND 40000)

--5. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản xuất có giá từ 30.000 đến 40.000.
SELECT MASP,TENSP
FROM SANPHAM
WHERE NUOCSX IN ('Trung Quoc','Thai Lan') AND (GIA BETWEEN 30000 AND 40000)

--6. In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007.
SET DATEFORMAT DMY;

SELECT SOHD,TRIGIA
FROM HOADON
WHERE NGHD IN ('1/1/2007','2/1/2007')
--7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007, sắp xếp theo ngày (tăng dần) và trị giá của hóa đơn (giảm dần).
SELECT SOHD,TRIGIA
FROM HOADON
WHERE NGHD BETWEEN '1/1/2007' AND '31/1/2007'
ORDER BY NGHD ASC, TRIGIA DESC
--8. In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007.
SELECT A.MAKH,HOTEN
FROM KHACHHANG A
INNER JOIN HOADON B ON A.MAKH = B.MAKH
WHERE NGHD='1/1/2007'

--9. In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày 28/10/2006.
SELECT SOHD,TRIGIA
FROM HOADON A
INNER JOIN NHANVIEN B ON A.MANV = B.MANV
WHERE B.HOTEN ='Nguyen Van B' AND NGHD='28/10/2006'
--10. In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” mua trong tháng 10/2006.
SELECT A.MASP, TENSP
FROM SANPHAM A
INNER JOIN CTHD B ON A.MASP = B.MASP
INNER JOIN HOADON C ON B.SOHD = C.SOHD
INNER JOIN KHACHHANG D ON C.MAKH = D.MAKH
WHERE HOTEN='Nguyen Van A' AND ( NGHD BETWEEN '01/10/2006' AND '31/10/2006')

--QLDV: Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):
USE QLGV;
--1. Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại. 
--Thêm vào 3 thuộc tính GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN.
ALTER TABLE HOCVIEN ADD GHICHU VARCHAR(20);
ALTER TABLE HOCVIEN ADD DIEMTB numeric(4,2);
ALTER TABLE HOCVIEN ADD XEPLOAI VARCHAR(10);
--2. Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên trong lớp. VD: “K1101”
CREATE TRIGGER trg_ins_upd_HOCVIEN
ON HOCVIEN
FOR INSERT, UPDATE 
AS
BEGIN
	DECLARE @SISO INT, @MAHV VARCHAR(5), @MALOP VARCHAR(3)

	SELECT @MAHV = MAHV, @MALOP = MALOP FROM INSERTED
	SELECT @SISO = SISO FROM LOP WHERE LOP.MALOP = @MALOP

	IF LEFT(@MAHV,3) <> @MALOP
	BEGIN
		PRINT('3 Ký tự đầu của MAHV phải là MALOP')
		ROLLBACK TRANSACTION
	END
	
	ELSE IF CAST(RIGHT(@MAHV, 2) AS INT) NOT BETWEEN 1 AND @SISO
	BEGIN
		PRINT('2 ký tự cuối của MAHV phải là số thứ tự học viên trong lớp')
		ROLLBACK TRANSACTION
	END
END
--3. Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”.
ALTER TABLE GIAOVIEN ADD CONSTRAINT CHECK_GTGV CHECK (GIOITINH IN ('Nam','Nu'))
ALTER TABLE HOCVIEN ADD CONSTRAINT CHECK_GTHV CHECK (GIOITINH IN ('Nam','Nu'))
--4. Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22).
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_DIEM CHECK (DIEM BETWEEN 0 AND 10 
												AND RIGHT(CAST(DIEM AS VARCHAR), 3) LIKE '.__')
--5. Kết quả thi là “Dat” nếu điểm từ 5 đến 10  và “Khong dat” nếu điểm nhỏ hơn 5.
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_KETQUA CHECK ((KQUA ='Dat' AND DIEM BETWEEN 5 AND 10) 
														OR (KQUA ='Khong dat' AND DIEM <5 ))
--6. Học viên thi một môn tối đa 3 lần.
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_LAN_THI CHECK (LANTHI <=3)
--7. Học kỳ chỉ có giá trị từ 1 đến 3.
ALTER TABLE GIANGDAY ADD CONSTRAINT CHECK_HOCKY CHECK (HOCKY BETWEEN 1 AND 3)
--8. Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”.
ALTER TABLE GIAOVIEN ADD CONSTRAINT CHECK_HOCVI CHECK (HOCVI IN ('CN','KS','Ths','TS','PTS'))
-- 9. Lớp trưởng của một lớp phải là học viên của lớp đó.
CREATE TRIGGER trg_ins_udt_LopTruong ON LOP
FOR INSERT, UPDATE
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM INSERTED I, HOCVIEN HV
	WHERE I.TRGLOP = HV.MAHV AND I.MALOP = HV.MALOP)
	BEGIN
		PRINT 'Error: Lớp trưởng của một lớp phải là học viên của lớp đó'
		ROLLBACK TRANSACTION
	END
END

CREATE TRIGGER trg_del_HOCVIEN ON HOCVIEN
FOR DELETE
AS
BEGIN
	IF EXISTS (SELECT * FROM DELETED D, INSERTED I, LOP L 
	WHERE D.MAHV = L.TRGLOP AND D.MALOP = L.MALOP)
	BEGIN
		PRINT 'Error: Học viên hiện tại đang là trưởng lớp'
		ROLLBACK TRANSACTION
	END
END
--10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
CREATE TRIGGER trg_khoa ON KHOA
FOR INSERT, UPDATE
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM INSERTED I, GIAOVIEN GV
	WHERE I.TRGKHOA = GV.MAGV AND I.MAKHOA = GV.MAGV AND GV.HOCVI IN ('TS','PTS'))
	BEGIN
		PRINT 'Error: Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”'
		ROLLBACK TRANSACTION
	END
END

--11. Học viên ít nhất là 18 tuổi.
ALTER TABLE HOCVIEN ADD CONSTRAINT CHECK_TUOIHV CHECK (YEAR(GETDATE())-YEAR(NGSINH) >=18)
--12. Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY).
ALTER TABLE GIANGDAY ADD CONSTRAINT CHECK_NGAY_GD CHECK (TUNGAY <DENNGAY)
--13. Giáo viên khi vào làm ít nhất là 22 tuổi.
ALTER TABLE GIAOVIEN ADD CONSTRAINT CHECK_TUOI_GV CHECK (YEAR(NGVL)-YEAR(NGSINH) >=22)