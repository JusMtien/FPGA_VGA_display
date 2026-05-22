module vga_color_display (
    input  blank_on,
    input [15:0]pixel_data,
    input grayscale,
    output reg [9:0] vga_r, vga_b, vga_g
    
);
    //  RGB565
    
    wire [4:0] r5 = pixel_data[15:11];
    wire [5:0] g6 = pixel_data[10:5];
    wire [4:0] b5 = pixel_data[4:0];

    // gray scale
    wire [7:0] red_tmp   = {r5, r5[4:2]};
    wire [7:0] green_tmp = {g6, g6[5:4]};
    wire [7:0] blue_tmp  = {b5, b5[4:2]};

    // gray caculate
    wire[15:0] gray_tmp_16= ( red_tmp<<6)+(red_tmp<<3)+(red_tmp<<2)+red_tmp + (green_tmp<<7)+(green_tmp<<4)+(green_tmp<<2)+(green_tmp<<1)+
    (blue_tmp<<5)-(blue_tmp<<1)-blue_tmp;
     wire  [7:0] gray8  = gray_tmp_16[15:8];
    // display if blank on
    always @(*) begin
        
    if(blank_on==1'b1) begin
          if(grayscale==1'b1)begin 
        vga_r={gray8[7:3],gray8[7:3]};
        vga_g={gray8[7:2],gray8[7:4]};
        vga_b={gray8[7:3],gray8[7:3]};
        end
      else begin
        vga_r={r5,r5};
        vga_g={g6,g6[5:2]};
        vga_b={b5,b5};
       
    end
	 end
    
    else begin
    vga_r=0;
    vga_b=0;
    vga_g=0;
    end
end

endmodule