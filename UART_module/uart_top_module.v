module uart_top_module (
    input CLOCK_50,
    input rst_n, 
   // input  tx_en, 
    input tx_in,
    output  [15:0] data_out,
    output  [17:0] addrs,
    output   sram_enb
);


    wire       tmp_finish;
    wire [7:0] tmp_data_in;

    
    uart_module m1 (
        .CLOCK_50 (CLOCK_50),
        .tx_in    (tx_in),
        //.tx_en    (tx_en),
        .rst_n    (rst_n),
        .finish   (tmp_finish), 
        .data     (tmp_data_in)
    );

   
    uart_combine m2 (
        .CLOCK_50      (CLOCK_50), 
        .rst_n         (rst_n),        
        .finish        (tmp_finish), 
        .data_in       (tmp_data_in), 
       // .finish_signal (finish_signal), 
        .data_out      (data_out), 
        .addr          (addrs), 
        .sram_enb      (sram_enb)
    );


endmodule