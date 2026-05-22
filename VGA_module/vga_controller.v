module vga_controller (
    input clk_25,
    input rst_n,
    
   // out
    output  h_sync,
    output  v_sync,
    
    output blank_on, 
    output [9:0] x,
    output [9:0] y
);

    
    // horizon: Active(640) -> FP(16) -> Sync(96) -> BP(48) = 800
    parameter H_DISP  = 640, H_FP = 16, H_SYNC = 96, H_BP = 48, H_TOTAL = 800;
    // vertical: Active(480) -> FP(10) -> Sync(2) -> BP(33) = 525
    parameter V_DISP  = 480, V_FP = 10, V_SYNC = 2,  V_BP = 33, V_TOTAL = 525;
    reg [9:0] h_cnt;
    reg [9:0] v_cnt;

    always @(posedge clk_25 or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 0;
                if (v_cnt == V_TOTAL - 1)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

   // sync active low
    assign h_sync = (h_cnt >= (H_DISP + H_FP) && h_cnt < (H_DISP + H_FP + H_SYNC)) ? 1'b0 : 1'b1;
    assign v_sync = (v_cnt >= (V_DISP + V_FP) && v_cnt < (V_DISP + V_FP + V_SYNC)) ? 1'b0 : 1'b1;
  // blank =1 hien thi mau
    assign blank_on = (h_cnt < H_DISP && v_cnt < V_DISP) ? 1'b1 : 1'b0;
    // toa do
    assign x = h_cnt;
    assign y = v_cnt;

endmodule