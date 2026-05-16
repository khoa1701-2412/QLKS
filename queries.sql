-- ====================================
-- TRUY VẤN SQL QUẢN LÝ KHÁCH SẠN
-- ====================================

-- 1. LẤY DANH SÁCH TẤT CẢ KHÁCH HÀNG
SELECT 
    MaKH,
    HoTen,
    SDT,
    Email,
    LoaiKH,
    TrangThai
FROM KHACH_HANG
ORDER BY NgayTao DESC;

-- 2. LẤY DANH SÁCH PHÒNG VÀ TRẠNG THÁI
SELECT 
    MaPhong,
    TenPhong,
    lp.TenLoaiPhong,
    Tang,
    GiaPhong,
    TrangThai
FROM PHONG p
LEFT JOIN LOAI_PHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
ORDER BY Tang, MaPhong;

-- 3. LẤY DANH SÁCH PHÒNG TRỐNG HÔNG NAY
SELECT 
    MaPhong,
    TenPhong,
    Tang,
    GiaPhong
FROM PHONG
WHERE TrangThai = N'Trống'
ORDER BY Tang;

-- 4. LẤY DANH SÁCH ĐẶT PHÒNG CÓ HIỆU LỰC
SELECT 
    dp.MaDatPhong,
    kh.HoTen,
    dp.MaPhong,
    dp.NgayNhanPhong,
    dp.NgayTraPhong,
    dp.SoLuongKhach,
    dp.TrangThai
FROM DAT_PHONG dp
INNER JOIN KHACH_HANG kh ON dp.MaKH = kh.MaKH
WHERE dp.TrangThai IN (N'Đã xác nhận', N'Đang ở')
ORDER BY dp.NgayNhanPhong;

-- 5. TÍNH DOANH THU THEO THÁNG
SELECT 
    YEAR(NgayThanhToan) AS Nam,
    MONTH(NgayThanhToan) AS Thang,
    COUNT(*) AS SoHoaDon,
    SUM(TongThanhToan) AS TongDoanhu
FROM HOA_DON
WHERE TrangThaiTT = N'Đã thanh toán'
GROUP BY YEAR(NgayThanhToan), MONTH(NgayThanhToan)
ORDER BY Nam DESC, Thang DESC;

-- 6. TÍNH DOANH THU THEO LOẠI PHÒNG
SELECT 
    lp.TenLoaiPhong,
    COUNT(DISTINCT dp.MaDatPhong) AS SoDonDat,
    SUM(hd.GiaPhong) AS TongTienPhong
FROM DAT_PHONG dp
INNER JOIN PHONG p ON dp.MaPhong = p.MaPhong
INNER JOIN LOAI_PHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
INNER JOIN HOA_DON hd ON dp.MaDatPhong = hd.MaDatPhong
WHERE hd.TrangThaiTT = N'Đã thanh toán'
GROUP BY lp.TenLoaiPhong
ORDER BY TongTienPhong DESC;

-- 7. LẤY CHI TIẾT HÓA ĐƠN
SELECT 
    hd.MaHD,
    kh.HoTen,
    hd.NgayThanhToan,
    hd.GiaPhong,
    hd.TongDichVu,
    hd.GiamGia,
    hd.TongThanhToan,
    hd.HinhThucTT,
    hd.TrangThaiTT
FROM HOA_DON hd
INNER JOIN DAT_PHONG dp ON hd.MaDatPhong = dp.MaDatPhong
INNER JOIN KHACH_HANG kh ON dp.MaKH = kh.MaKH
ORDER BY hd.NgayThanhToan DESC;

-- 8. LẤY DANH SÁCH DỊCH VỤ ĐƯỢC SỬ DỤNG NHIỀU NHẤT
SELECT 
    dv.MaDichVu,
    dv.TenDichVu,
    COUNT(ctdv.MaChiTietDV) AS SoLanSuDung,
    SUM(ctdv.ThanhTien) AS TongTien
FROM DICH_VU dv
LEFT JOIN CHI_TIET_DICH_VU ctdv ON dv.MaDichVu = ctdv.MaDichVu
GROUP BY dv.MaDichVu, dv.TenDichVu
ORDER BY SoLanSuDung DESC;

-- 9. LẤY DANH SÁCH NHÂN VIÊN VÀ SỐ HÓA ĐƠN ĐÃ LẬP
SELECT 
    nv.MaNV,
    nv.HoTen,
    nv.ChucVu,
    COUNT(hd.MaHD) AS SoHoaDon,
    SUM(hd.TongThanhToan) AS TongGiaTriHoaDon
FROM NHAN_VIEN nv
LEFT JOIN HOA_DON hd ON nv.MaNV = hd.MaNV
WHERE nv.TrangThai = N'Đang làm'
GROUP BY nv.MaNV, nv.HoTen, nv.ChucVu
ORDER BY SoHoaDon DESC;

-- 10. TÌM KHÁCH HÀNG VIP (DOANH THU CAO NHẤT)
SELECT 
    kh.MaKH,
    kh.HoTen,
    kh.LoaiKH,
    COUNT(dp.MaDatPhong) AS SoLanDat,
    SUM(hd.TongThanhToan) AS TongDoanhuTuKH
FROM KHACH_HANG kh
LEFT JOIN DAT_PHONG dp ON kh.MaKH = dp.MaKH
LEFT JOIN HOA_DON hd ON dp.MaDatPhong = hd.MaDatPhong
GROUP BY kh.MaKH, kh.HoTen, kh.LoaiKH
HAVING COUNT(dp.MaDatPhong) > 0
ORDER BY TongDoanhuTuKH DESC;

-- 11. KIỂM TRA LỊCH SỬ GIÁ PHÒNG
SELECT 
    p.MaPhong,
    p.TenPhong,
    lsg.GiaCu,
    lsg.GiaMoi,
    lsg.NgayThayDoi,
    lsg.LyDo
FROM LICH_SU_GIA_PHONG lsg
INNER JOIN PHONG p ON lsg.MaPhong = p.MaPhong
ORDER BY lsg.NgayThayDoi DESC;

-- 12. TẤT CẢ THANH TOÁN CỦA HÓA ĐƠN
SELECT 
    hd.MaHD,
    kh.HoTen,
    cttt.LoaiTT,
    cttt.SoTien,
    cttt.HinhThuc,
    cttt.NgayTT
FROM CHI_TIET_THANH_TOAN cttt
INNER JOIN HOA_DON hd ON cttt.MaHD = hd.MaHD
INNER JOIN DAT_PHONG dp ON hd.MaDatPhong = dp.MaDatPhong
INNER JOIN KHACH_HANG kh ON dp.MaKH = kh.MaKH
ORDER BY cttt.NgayTT DESC;

-- 13. XEM AUDIT LOG - THEO DÕI THAY ĐỔI
SELECT 
    MaAudit,
    BangTen,
    HanhDong,
    MaBanGhi,
    DuLieuCu,
    DuLieuMoi,
    MaNV,
    NgayTao
FROM AUDIT_LOG
ORDER BY NgayTao DESC;

-- 14. TÍNH TỶ LỆ CHIẾM DỤNG PHÒNG
SELECT 
    lp.TenLoaiPhong,
    COUNT(DISTINCT p.MaPhong) AS TongPhong,
    COUNT(CASE WHEN p.TrangThai = N'Đang sử dụng' THEN 1 END) AS PhongDangSuDung,
    CAST(COUNT(CASE WHEN p.TrangThai = N'Đang sử dụng' THEN 1 END) * 100.0 / 
         COUNT(DISTINCT p.MaPhong) AS DECIMAL(5,2)) AS TyLeChiemDung
FROM PHONG p
LEFT JOIN LOAI_PHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
GROUP BY lp.TenLoaiPhong;

-- 15. LẤY ĐƠN ĐẶT PHÒNG TRONG KHOẢNG THỜI GIAN
SELECT 
    dp.MaDatPhong,
    kh.HoTen,
    dp.MaPhong,
    dp.NgayNhanPhong,
    dp.NgayTraPhong,
    DATEDIFF(DAY, dp.NgayNhanPhong, dp.NgayTraPhong) AS SoNgayO,
    dp.TrangThai
FROM DAT_PHONG dp
INNER JOIN KHACH_HANG kh ON dp.MaKH = kh.MaKH
WHERE dp.NgayNhanPhong >= '2026-05-16' 
  AND dp.NgayNhanPhong <= '2026-06-16'
ORDER BY dp.NgayNhanPhong;
