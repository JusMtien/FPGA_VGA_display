`timescale 1ns / 1ps

module uart_testbench();

    // 1. Khai báo các tín hiệu giả lập
    reg         CLOCK_50;
    reg         rst_n;
    reg         tx_in;
    
    wire [15:0] data_out;
    wire [17:0] addrs;
    wire        sram_enb;

    // 2. Gọi module cần test (Device Under Test - DUT)
    uart_top_module dut (
        .CLOCK_50 (CLOCK_50),
        .rst_n    (rst_n),
        .tx_in    (tx_in),
        .data_out (data_out),
        .addrs    (addrs),
        .sram_enb (sram_enb)
    );

    // 3. Tạo xung Clock 50MHz (Chu kỳ 20ns -> Đảo trạng thái mỗi 10ns)
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // =========================================================================
    // TASK: Giả lập quá trình máy tính gửi 1 Byte qua chuẩn UART
    // Khung truyền: 1 Start bit (0) + 8 Data bits (LSB first) + 1 Stop bit (1)
    // =========================================================================
    task send_uart_byte;
        input [7:0] data_byte;
        integer i;
        begin
            // Truyền Start Bit (kéo xuống 0)
            tx_in = 1'b0;
            #(54 * 20); // Chờ đúng 54 chu kỳ clock

            // Truyền 8 bit Dữ liệu (Truyền từ bit thấp LSB đến bit cao MSB)
            for (i = 0; i < 8; i = i + 1) begin
                tx_in = data_byte[i];
                #(54 * 20);
            end

            // Truyền Stop Bit (kéo lên 1)
            tx_in = 1'b1;
            #(54 * 20);
        end
    endtask

    // 4. Kịch bản test (Test Scenario)
    initial begin
        // Khởi tạo trạng thái ban đầu: Dây UART luôn ở mức 1 khi rảnh rỗi (Idle)
        tx_in = 1'b1;
        
        // Reset hệ thống
        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;
        #100;

        // ---------------------------------------------------------
        // Test gửi PIXEL 1 (Màu Đỏ tinh khiết: RGB565 = 16'hF800)
        // ---------------------------------------------------------
        $display("Dang gui Pixel 1...");
        send_uart_byte(8'hF8); // Gửi Byte Cao trước
        #5000;                 // Máy tính nghỉ một chút
        send_uart_byte(8'h00); // Gửi Byte Thấp sau
        
        // Chờ module combine xử lý xong
        #2000; 

        // ---------------------------------------------------------
        // Test gửi PIXEL 2 (Màu Xanh lá tinh khiết: RGB565 = 16'h07E0)
        // ---------------------------------------------------------
        $display("Dang gui Pixel 2...");
        send_uart_byte(8'h07); // Gửi Byte Cao trước
        #5000;
        send_uart_byte(8'hE0); // Gửi Byte Thấp sau
        
        #5000;
        
        // Kết thúc mô phỏng
        $display("Mo phong hoan tat!");
        $stop;
    end

endmodule