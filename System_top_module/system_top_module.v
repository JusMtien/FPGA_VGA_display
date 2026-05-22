module system_top_module (
    input          CLOCK_50,
    input   [17:17]SW,     
	 input grayscale,
    // UART
    input  wire        tx_in,   // uart start bit
    //input  wire        tx_en,  

    // SRAM 
    output [17:0] SRAM_ADDR,
    inout  [15:0] SRAM_DQ,
    output   SRAM_WE_N, SRAM_OE_N, SRAM_UB_N, SRAM_LB_N, SRAM_CE_N,
    // VGA
    output [9:0] VGA_R,
    output  [9:0] VGA_G,
    output  [9:0] VGA_B,
    output   VGA_HS, VGA_VS, VGA_BLANK, VGA_CLK,
	 output finish_signal
);

    

    //  uart_top_module
    wire [15:0] uart_pixel;
    wire [17:0] uart_addr;
    wire        uart_sram_enb;

    // vga_top_module 
    wire  [9:0] vga_x, vga_y;
    wire        blank_on;

    //  sram_controller and vga_top_module
    wire [15:0] sram_pixel;

    //  UART
    uart_top_module m_uart (
        .CLOCK_50      (CLOCK_50),
        .rst_n         (SW[17]),
        //.tx_en         (SW[16]),
        .tx_in         (tx_in),
        .data_out      (uart_pixel),
        .addrs         (uart_addr),
        //.finish_signal (),
        .sram_enb      (uart_sram_enb)
    );

    // SRAM Controller 
   

    sram_controller m_sram (
        .CLOCK_50  (CLOCK_50),

       // uart write
        .wr_req    (uart_sram_enb),
        .wr_addr   (uart_addr[17:0]),
        .wr_data   (uart_pixel),

       //vga read
        .rd_addr   (rd_addr),
        .rd_data   (sram_pixel),

   
        .SRAM_ADDR (SRAM_ADDR),
        .SRAM_DQ   (SRAM_DQ),
        .sram_we_n (SRAM_WE_N),
        .sram_oe_n (SRAM_OE_N),
        .sram_ub_n (SRAM_UB_N),
        .sram_lb_n (SRAM_LB_N),
        .sram_ce_n (SRAM_CE_N)
    );
    // double pixel
    wire [8:0] x_img = vga_x[9:1];
    wire [8:0] y_img = vga_y[9:1];

    wire [17:0] rd_addr = ({10'b0, y_img} << 8)   // y_img * 256
                    + ({10'b0, y_img} << 6)   // y_img * 64
                    + {9'b0, x_img};           // x_img
    //  VGA 
    vga_top_module m_vga (
        .CLOCK_50   (CLOCK_50),
        .KEY        (SW[17]),
        .sram_data_in (sram_pixel),   
        .VGA_R      (VGA_R),
        .VGA_G      (VGA_G),
        .VGA_B      (VGA_B),
        .VGA_HS     (VGA_HS),
        .VGA_VS     (VGA_VS),
        .VGA_BLANK  (VGA_BLANK),
        .VGA_CLK    (VGA_CLK),
        .x          (vga_x),        
        .y          (vga_y),
        .blank_on   (blank_on),
		  .grayscale(grayscale)
		  
    );
	assign finish_signal=blank_on;
endmodule