module uart_module (
    input CLOCK_50, tx_in, rst_n,
    output reg [7:0] data,
    output reg finish
	 //output debug_led
);
// state
//assign debug_led = tx_in;
localparam  idle =2'b00 ;
localparam start =2'b01;
localparam tranm =2'b10;
localparam stop = 2'b11;

reg [1:0]state=idle;// default
reg [1:0]next_state;
reg [8:0]clk_cnt;
reg [2:0] bit_cnt;

always@(posedge CLOCK_50 or negedge rst_n)begin
    if(rst_n==1'b0) state<=idle;
    else begin
     state<=next_state;
    case(state)
    idle: begin
       clk_cnt<= 9'b0;
       bit_cnt<=1'b0;
       
       
    end
    start: begin
        if(clk_cnt==(54-1)/2
        ) clk_cnt<=9'b0;
        else clk_cnt<=clk_cnt+1;
    end
    tranm:begin
                
             if(clk_cnt<54-1) clk_cnt<=clk_cnt+1;
            else begin
                clk_cnt<=0;
                data[bit_cnt]<=tx_in;
                bit_cnt<=bit_cnt+1;
            end
        end
    stop: begin
          if (clk_cnt < 54-1)
                    clk_cnt <= clk_cnt + 1;
                else begin
                    clk_cnt <= 0;
                               
                end
                
                
     end
    endcase
 end
        
end


always@(*) begin
    next_state = state;
    finish=0;
  

   
    case(state)
    idle:begin
        if(tx_in==1'b0) next_state= start;
         
    end
    start: begin // check noise
        if( clk_cnt==(54-1)/2) begin
            if( tx_in ==1'b0) next_state=tranm;
            else next_state=idle;
            
        end
    end
    tranm: begin
        if( clk_cnt==54-1 && bit_cnt==7)
        next_state= stop;
        
      
    end
    stop: begin
        if(clk_cnt==54-1) begin 
             finish=1;
            next_state=idle;
        end
    end
    

    endcase
    
end
    

endmodule