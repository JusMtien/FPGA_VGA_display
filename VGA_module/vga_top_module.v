module vga_top_module (
    input  CLOCK_50,
    input   [0:0] KEY,
	 input grayscale,
    input [15:0]sram_data_in,
    output [9:0] VGA_R, VGA_G, VGA_B,
    output VGA_HS, VGA_VS, VGA_BLANK,VGA_CLK,
    output  [9:0] x,y,
    output   blank_on
);

   
    wire clk_25_tmp;

    vga_clock_divide  m1( .clk_50mhz (CLOCK_50), .rst_n(KEY[0]), .clk_25 (clk_25_tmp));    

    vga_controller  m2(.clk_25 (clk_25_tmp), 
    .rst_n(KEY[0]), 
    .h_sync(VGA_HS), 
    .v_sync(VGA_VS),
    .blank_on(blank_on),
    .x (x), .y(y));

    vga_color_display m3(
    .pixel_data(sram_data_in),
    .blank_on(blank_on), 
    .vga_r(VGA_R), 
    .vga_g(VGA_G), 
	 .grayscale(grayscale),
    .vga_b(VGA_B));
    
    assign VGA_CLK = clk_25_tmp;
    assign VGA_BLANK = blank_on; 

endmodule