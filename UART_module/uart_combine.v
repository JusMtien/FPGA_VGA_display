module uart_combine (
    input   CLOCK_50,
    input   finish, rst_n, // from uart module
    input  [7:0] data_in,
    
    output reg  [15:0] data_out, // data for sram module
    output reg  [17:0] addr, // addres for sram module
   // output reg  finish_signal, /// for debug pp
    output reg  sram_enb// enable sram module
);

    
    localparam WAIT_HIGH_BYTE = 1'b0;
    localparam WAIT_LOW_BYTE  = 1'b1;
    reg state=WAIT_HIGH_BYTE;
    reg next_state;
    reg [7:0] tmp_high_byte;

   
    always @(posedge CLOCK_50 or negedge rst_n) begin
        if (!rst_n) begin
            state <= WAIT_HIGH_BYTE;
            addr <= 18'd0;
            sram_enb <= 1'b0;
           // finish_signal <= 1'b0;
            data_out <= 16'd0;
            tmp_high_byte <= 8'd0;
        end 
        else begin  
            state <= next_state;
            sram_enb <= 1'b0;
           // finish_signal <= 1'b0;
            if (finish == 1'b1) begin 

case (state)
     WAIT_HIGH_BYTE: begin
         tmp_high_byte <= data_in; 
     end

    WAIT_LOW_BYTE: begin
                        
         data_out <= {tmp_high_byte, data_in}; 
         sram_enb <= 1'b1; 
         //finish_signal <= 1'b1;
                        
    end
 endcase
end
  if( sram_enb==1'b1)   begin
     if (addr == 18'd76799)
      addr <= 18'd0;
    else
      addr <= addr + 1'b1;
    end
end
 end

  
    always @(*) begin
        
        next_state = state; 
        if (finish == 1'b1) begin 
            case (state)
                WAIT_HIGH_BYTE: next_state = WAIT_LOW_BYTE;
                WAIT_LOW_BYTE:  next_state = WAIT_HIGH_BYTE;
            endcase
        end
    end

endmodule