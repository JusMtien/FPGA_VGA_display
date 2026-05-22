module vga_clock_divide (
    input   clk_50mhz, 
    input   rst_n,     
    output reg  clk_25  );

    always @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n)
            clk_25 <= 1'b0;
        else
            clk_25 <= ~clk_25; 
    end

endmodule