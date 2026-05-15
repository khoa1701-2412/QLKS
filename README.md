# QLKS
SQL Quản Lý Khách Sạn
-- 1. Bảng Khách hàng (CẢI THIỆN)
CREATE TABLE KHACH_HANG (
    MaKH VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    DiaChi NVARCHAR(255),
    CCCD VARCHAR(15) UNIQUE NOT NULL,
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    LoaiKH NVARCHAR(30) DEFAULT N'Bình thường', -- Thân thiết, VIP, v.v.
    TrangThai NVARCHAR(20) DEFAULT N'Hoạt động', -- Hoạt động, Tạm khóa
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhat DATETIME DEFAULT GETDATE()
);

-- 2. Bảng Loại Phòng (MỚI - Tách riêng)
CREATE TABLE LOAI_PHONG (
    MaLoaiPhong VARCHAR(10) PRIMARY KEY,
    TenLoaiPhong NVARCHAR(50) NOT NULL,
    MoTa NVARCHAR(255),
    SucChua INT CHECK (SucChua > 0),
    GiaCoban DECIMAL(18, 2) CHECK (GiaCoban > 0),
    NgayTao DATETIME DEFAULT GETDATE()
);

-- 3. Bảng Phòng (CẢI THIỆN)
CREATE TABLE PHONG (
    MaPhong VARCHAR(10) PRIMARY KEY,
    TenPhong NVARCHAR(50) NOT NULL,
    MaLoaiPhong VARCHAR(10),
    Tang INT,
    GiaPhong DECIMAL(18, 2) CHECK (GiaPhong > 0),
    TrangThai NVARCHAR(30) DEFAULT N'Trống', 
    -- Trống, Đang sử dụng, Bảo trì, Vệ sinh, Không sử dụng
    MoTa NVARCHAR(500),
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhat DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Phong_LoaiPhong FOREIGN KEY (MaLoaiPhong) REFERENCES LOAI_PHONG(MaLoaiPhong)
);

-- 4. Bảng Lịch Sử Giá Phòng (MỚI)
CREATE TABLE LICH_SU_GIA_PHONG (
    MaLichSuGia VARCHAR(10) PRIMARY KEY,
    MaPhong VARCHAR(10) NOT NULL,
    GiaCu DECIMAL(18, 2),
    GiaMoi DECIMAL(18, 2) NOT NULL,
    NgayThayDoi DATETIME DEFAULT GETDATE(),
    LyDo NVARCHAR(255),
    CONSTRAINT FK_LichSuGia_Phong FOREIGN KEY (MaPhong) REFERENCES PHONG(MaPhong)
);

-- 5. Bảng Nhân viên (CẢI THIỆN)
CREATE TABLE NHAN_VIEN (
    MaNV VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15),
    Email VARCHAR(100),
    ChucVu NVARCHAR(50),
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    DiaChi NVARCHAR(255),
    NgayVaoLam DATE,
    TrangThai NVARCHAR(20) DEFAULT N'Đang làm', -- Đang làm, Nghỉ phép, Thôi việc
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhat DATETIME DEFAULT GETDATE()
);

-- 6. Bảng Dịch Vụ (MỚI)
CREATE TABLE DICH_VU (
    MaDichVu VARCHAR(10) PRIMARY KEY,
    TenDichVu NVARCHAR(100) NOT NULL,
    Gia DECIMAL(18, 2) CHECK (Gia > 0),
    MoTa NVARCHAR(255),
    TrangThai NVARCHAR(20) DEFAULT N'Hoạt động',
    NgayTao DATETIME DEFAULT GETDATE()
);

-- 7. Bảng Đặt phòng (CẢI THIỆN)
CREATE TABLE DAT_PHONG (
    MaDatPhong VARCHAR(10) PRIMARY KEY,
    MaKH VARCHAR(10) NOT NULL,
    MaPhong VARCHAR(10) NOT NULL,
    NgayDat DATETIME DEFAULT GETDATE(),
    NgayNhanPhong DATE NOT NULL,
    NgayTraPhong DATE NOT NULL,
    SoLuongKhach INT DEFAULT 1,
    GhiChu NVARCHAR(500),
    TrangThai NVARCHAR(30) DEFAULT N'Chờ xác nhận',
    -- Chờ xác nhận, Đã xác nhận, Đang ở, Đã trả phòng, Hủy
    NgayTao DATETIME DEFAULT GETDATE(),
    NgayCapNhat DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_DatPhong_KhachHang FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH),
    CONSTRAINT FK_DatPhong_Phong FOREIGN KEY (MaPhong) REFERENCES PHONG(MaPhong),
    CONSTRAINT CHK_NgayDatPhong CHECK (NgayTraPhong >= NgayNhanPhong)
);

-- 8. Bảng Chi Tiết Dịch Vụ (MỚI)
CREATE TABLE CHI_TIET_DICH_VU (
    MaChiTietDV VARCHAR(10) PRIMARY KEY,
    MaDatPhong VARCHAR(10) NOT NULL,
    MaDichVu VARCHAR(10) NOT NULL,
    SoLuong INT DEFAULT 1 CHECK (SoLuong > 0),
    DonGia DECIMAL(18, 2) CHECK (DonGia > 0),
    ThanhTien DECIMAL(18, 2) CHECK (ThanhTien > 0),
    NgayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ChiTietDV_DatPhong FOREIGN KEY (MaDatPhong) REFERENCES DAT_PHONG(MaDatPhong),
    CONSTRAINT FK_ChiTietDV_DichVu FOREIGN KEY (MaDichVu) REFERENCES DICH_VU(MaDichVu)
);

-- 9. Bảng Hóa đơn (CẢI THIỆN)
CREATE TABLE HOA_DON (
    MaHD VARCHAR(10) PRIMARY KEY,
    MaDatPhong VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10), -- Nhân viên tạo hóa đơn
    NgayThanhToan DATETIME DEFAULT GETDATE(),
    GiaPhong DECIMAL(18, 2),
    TongDichVu DECIMAL(18, 2) DEFAULT 0,
    TongTien DECIMAL(18, 2) CHECK (TongTien >= 0),
    GiamGia DECIMAL(18, 2) DEFAULT 0,
    TongThanhToan DECIMAL(18, 2) CHECK (TongThanhToan >= 0),
    HinhThucTT NVARCHAR(50), -- Tiền mặt, Chuyển khoản, Thẻ
    TrangThaiTT NVARCHAR(30) DEFAULT N'Chưa thanh toán', -- Chưa TT, Đã TT, Hoàn trả
    GhiChu NVARCHAR(255),
    CONSTRAINT FK_HoaDon_DatPhong FOREIGN KEY (MaDatPhong) REFERENCES DAT_PHONG(MaDatPhong),
    CONSTRAINT FK_HoaDon_NhanVien FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);

-- 10. Bảng Chi Tiết Thanh Toán (MỚI - Theo dõi cọc, thanh toán từng phần)
CREATE TABLE CHI_TIET_THANH_TOAN (
    MaCTTT VARCHAR(10) PRIMARY KEY,
    MaHD VARCHAR(10) NOT NULL,
    LoaiTT NVARCHAR(30), -- Cọc, Thanh toán, Hoàn trả
    SoTien DECIMAL(18, 2) CHECK (SoTien > 0),
    HinhThuc NVARCHAR(50),
    NgayTT DATETIME DEFAULT GETDATE(),
    GhiChu NVARCHAR(255),
    CONSTRAINT FK_CTTT_HoaDon FOREIGN KEY (MaHD) REFERENCES HOA_DON(MaHD)
);

-- 11. Bảng Audit Log (MỚI - Theo dõi thay đổi)
CREATE TABLE AUDIT_LOG (
    MaAudit VARCHAR(10) PRIMARY KEY,
    BangTen NVARCHAR(100),
    HanhDong NVARCHAR(50), -- INSERT, UPDATE, DELETE
    MaBanGhi VARCHAR(10),
    DuLieuCu NVARCHAR(MAX),
    DuLieuMoi NVARCHAR(MAX),
    MaNV VARCHAR(10),
    NgayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_AuditLog_NhanVien FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);
