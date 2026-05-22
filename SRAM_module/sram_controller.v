
module sram_controller (
    input  wire   CLOCK_50,          

    // Write port ( form uart_module)
    input  wire        wr_req,       
    input  wire [17:0] wr_addr,      
    input  wire [15:0] wr_data,      

    // Read port (from vga_module)
    input  wire [17:0] rd_addr,     
    output reg  [15:0] rd_data,     

    //  DE2 physical pin
    output wire [17:0] SRAM_ADDR,
    inout  wire [15:0] SRAM_DQ,
    output wire        sram_we_n,
    output wire        sram_oe_n,
    output wire        sram_ub_n,
    output wire        sram_lb_n,
    output wire        sram_ce_n
);

    //default setting
    assign sram_ce_n = 1'b0;
    assign sram_oe_n = 1'b0;
    assign sram_ub_n = 1'b0;
    assign sram_lb_n = 1'b0;

   // write
    assign SRAM_ADDR = wr_req ? wr_addr : rd_addr;
    assign sram_we_n = ~wr_req;   // sram_we_n =1 when write, 0 when read
                                   
    assign SRAM_DQ   = wr_req ? wr_data : 16'hzzzz;

   // read 
    always @(posedge CLOCK_50) begin
        if (!wr_req)
            rd_data <= SRAM_DQ;
    end

endmodule