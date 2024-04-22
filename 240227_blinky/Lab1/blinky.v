`timescale 1ns / 1ps

module blinky(
    input clk_p,
    input clk_n,
    output led
);
    
    wire clk;
 
    IBUFGDS clk_inst (
        .O  (clk    ),
        .I  (clk_p  ),
        .IB (clk_n  )
    );
    
    reg [24:0] count = 0;
    always @ (posedge(clk)) 
        count <= count + 1;

    assign led = count[24];

endmodule
