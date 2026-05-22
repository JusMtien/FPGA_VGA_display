import os
import time
import numpy as np
import cv2
import serial
from matplotlib import pyplot as plt

# ==========================================
# CÁC HÀM CHUYỂN ĐỔI HỆ MÀU (8-bit sang RGB565)
# ==========================================
def EightBitsTo5Bits(adc):
    return bin(int((adc * 31.0) / 255.0))[2:].zfill(5)

def EightBitsTo6Bits(adc):
    return bin(int((adc * 63.0) / 255.0))[2:].zfill(6)

# ==========================================
# HÀM XỬ LÝ ẢNH VÀ TẠO FILE .COE
# ==========================================
def imgToMemoryFile(fileName, WH={'W': 320, 'H': 240}):
    print(f"Đang xử lý ảnh: {fileName}...")
    
    # Đọc ảnh và Resize về đúng độ phân giải
    img = cv2.imread(fileName)
    if img is None:
        print(f"LỖI: Không tìm thấy ảnh '{fileName}'. Vui lòng kiểm tra lại đường dẫn!")
        return False
        
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB) # Chuyển hệ màu của OpenCV sang RGB chuẩn
    img = cv2.resize(img, (WH['W'], WH['H']))

    # Chuyển đổi sang hệ màu RGB565
    EightBitsTo5Bits_V = np.vectorize(EightBitsTo5Bits)
    EightBitsTo6Bits_V = np.vectorize(EightBitsTo6Bits)

    r = EightBitsTo5Bits_V(img[:, :, 0]).reshape(-1, 1)
    g = EightBitsTo6Bits_V(img[:, :, 1]).reshape(-1, 1)
    b = EightBitsTo5Bits_V(img[:, :, 2]).reshape(-1, 1)

    st = ''
    for i in range(r.shape[0]):
        # Ghép 5 bit R + 6 bit G + 5 bit B thành chuỗi nhị phân 16-bit, sau đó chuyển sang HEX
        hex_val = hex(int(r[i][0] + g[i][0] + b[i][0], 2))[2:].zfill(4)
        st += hex_val + ',\n'

    # Tạo thư mục chứa file nếu chưa có
    os.makedirs('./ImageMemoryFile', exist_ok=True)
    
    # Lưu ra file MemoryFile.coe
    coe_path = './ImageMemoryFile/MemoryFile.coe'
    with open(coe_path, 'w+') as f:
        f.write('memory_initialization_radix=16;\nmemory_initialization_vector=\n')
        f.write(st[:-2] + ';')
    
    print(f"Đã tạo xong file dữ liệu ảnh tại: {coe_path}")
    return True

# ==========================================
# HÀM TRUYỀN DỮ LIỆU QUA UART CHO FPGA
# ==========================================
def sendBRAMData(ser, fileName=''):
    try:
        with open(fileName) as fil:
            lisa = list(map(lambda x: x.strip()[:-1], fil.readlines()))[2:]
    except FileNotFoundError:
        print(f"LỖI: Không tìm thấy file {fileName}")
        return

    print(f"Bắt đầu gom {len(lisa)} pixel vào Buffer...")
    
    # Tạo một mảng byte trống
    tx_buffer = bytearray()
    
    for i in range(len(lisa)):
        val = int('0x' + lisa[i], 16)
        high_byte = (val >> 8) & 0xFF
        low_byte  = val & 0xFF
        
        # Nhét 2 byte vào mảng thay vì gửi đi ngay
        tx_buffer.append(high_byte)
        tx_buffer.append(low_byte)

    print(f"Đã gom xong! Bắt đầu truyền một mạch {len(tx_buffer)} bytes xuống FPGA...")
    
    # Đo thời gian truyền thực tế
    start_time = time.time()
    
    # Gửi TOÀN BỘ mảng đi trong 1 câu lệnh duy nhất
    ser.write(tx_buffer)
    
    # Bắt buộc phải có lệnh này để chờ phần cứng gửi xong toàn bộ Buffer mới đi tiếp
    ser.flush() 
    
    end_time = time.time()
    print(f"Truyền ảnh hoàn tất! Thời gian mất: {round(end_time - start_time, 2)} giây.")

# ==========================================
# CHƯƠNG TRÌNH CHÍNH (MAIN)
# ==========================================
if __name__ == '__main__':
    # 1. Cấu hình ban đầu
    IMAGE_NAME = r'D:\HDL_verilog_lab\HDL_project\hdl_vscode\python_image_converter/ttlab.jpg'  # Tên file ảnh cần truyền (để cùng thư mục với code)
    RESOLUTION = {'W': 320, 'H': 240} # Độ phân giải (để dùng Pixel Doubling)
    
   
    SERIAL_PORT = 'COM6' 
    BAUDRATE = 921600
    DELAY_TIME = 0.0002 # Giữ thời gian delay nhỏ nhất để truyền nhanh hơn

    # 2. Tiền xử lý ảnh
    success = imgToMemoryFile(IMAGE_NAME, RESOLUTION)
    
    # 3. Mở cổng Serial và truyền dữ liệu
    if success:
        try:
            print(f"Đang mở cổng {SERIAL_PORT} ở baudrate {BAUDRATE}...")
            ser = serial.Serial(SERIAL_PORT, BAUDRATE)
            time.sleep(2) # Chờ cổng Serial ổn định
            
            sendBRAMData(ser, fileName='./ImageMemoryFile/MemoryFile.coe')
            
            ser.close()
            print("Đã đóng cổng Serial.")
        except serial.SerialException as e:
            print(f"LỖI CỔNG SERIAL: {e}")
            print(f"Hãy chắc chắn bạn đã cắm cáp USB-UART và nhập đúng tên cổng {SERIAL_PORT}.")