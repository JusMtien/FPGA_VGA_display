`timescale 1ns / 1ps

module vga_testbench();

    // 1. Khai báo các tín hiệu giả lập (Inputs là reg, Outputs là wire)
    reg         CLOCK_50;
    reg  [0:0]  KEY;          // Dùng KEY[0] làm reset
    reg         grayscale;
    reg  [15:0] sram_data_in;

    wire [9:0]  VGA_R, VGA_G, VGA_B;
    wire        VGA_HS, VGA_VS, VGA_BLANK, VGA_CLK;
    wire [9:0]  x, y;
    wire        blank_on;

    // 2. Gọi khối DUT (Device Under Test)
    vga_top_module dut (
        .CLOCK_50      (CLOCK_50),
        .KEY           (KEY),
        .grayscale     (grayscale),
        .sram_data_in  (sram_data_in),
        .VGA_R         (VGA_R),
        .VGA_G         (VGA_G),
        .VGA_B         (VGA_B),
        .VGA_HS        (VGA_HS),
        .VGA_VS        (VGA_VS),
        .VGA_BLANK     (VGA_BLANK),
        .VGA_CLK       (VGA_CLK),
        .x             (x),
        .y             (y),
        .blank_on      (blank_on)
    );

    // 3. Tạo xung Clock 50MHz (Chu kỳ 20ns)
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // =========================================================================
    // 4. Khối giả lập dữ liệu trả về từ SRAM dựa trên tọa độ X
    // =========================================================================
    always @(*) begin
        // Để dễ quan sát dạng sóng màu, ta chia màn hình thành 3 dải màu ảo
        if (x < 100) 
            sram_data_in = 16'hF800; // Dải 1: Màu Đỏ
        else if (x < 200) 
            sram_data_in = 16'h07E0; // Dải 2: Màu Xanh lá
        else 
            sram_data_in = 16'h001F; // Dải 3: Màu Xanh dương
    end

    // =========================================================================
    // 5. Kịch bản mô phỏng
    // =========================================================================
    initial begin
        // Khởi tạo trạng thái ban đầu
        KEY[0]    = 1'b0; // Đang nhấn Reset
        grayscale = 1'b0; // Chế độ màu bình thường

        // Đợi 100ns rồi nhả Reset để hệ thống bắt đầu chạy
        #100;
        KEY[0] = 1'b1;

        $display("He thong bat dau quet che do RGB mau binh thuong...");

        // Chờ khoảng 64us (đủ để quét xong 2 dòng ngang - H_SYNC)
        #64000; 

        // Bật chế độ Grayscale lên để xem màu xám xuất ra thế nào
        $display("Chuyen sang che do Grayscale...");
        grayscale = 1'b1;

        // Chờ thêm một thời gian để quan sát
        #32000;

        $display("Hoan tat mo phong. Hay kiem tra dang song!");
        $stop;
    end

endmodule