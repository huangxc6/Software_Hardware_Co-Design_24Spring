//r
module flopr #(parameter WIDTH = 8)
(input  logic             clk, reset,
 input  logic [WIDTH-1:0] d, 
 output logic [WIDTH-1:0] q);

always_ff @(posedge clk, posedge reset) begin
  if (reset) 
    q <= 0;
  else       
    q <= d;
end

endmodule

//r clear  flush  Decode/Eex
module floprc #(parameter WIDTH = 8)
(input                  clk, reset, clear,
 input      [WIDTH-1:0] d, 
 output reg [WIDTH-1:0] q);

always_ff @(posedge clk, posedge reset) begin
  if (reset)
    q <= #1 0;
  else if (clear) 
    q <= #1 0;
  else            
    q <= #1 d;
end

endmodule

//en r   stall  FETCH
module flopenr #(parameter WIDTH = 8)
  (input                  clk, reset,
   input                  en,
   input      [WIDTH-1:0] d, 
   output reg [WIDTH-1:0] q);

always_ff @(posedge clk, posedge reset)
if      (reset) q <= #1 0;
else if (en)    q <= #1 d;
endmodule

//en r clear  flush/stall/   Fetch/Decode
module flopenrc #(parameter WIDTH = 8, parameter VALUE_0 = 32'b0)
   (input                  clk, reset,
    input                  en, clear,
    input      [WIDTH-1:0] d, 
    output reg [WIDTH-1:0] q);

always_ff @(posedge clk, posedge reset)
if      (reset) q <= #1 VALUE_0;
else if (clear) q <= #1 VALUE_0;
else if (en)    q <= #1 d;
endmodule

module mux2 #(parameter WIDTH = 8)
(input  logic [WIDTH-1:0] d0, d1, 
input  logic             s, 
output logic [WIDTH-1:0] y);

assign y = s ? d1 : d0; 

endmodule

module mux3 #(parameter WIDTH = 8)
(input  logic [WIDTH-1:0] d0, d1, d2,
input  logic [1:0]       s, 
output logic [WIDTH-1:0] y);

assign y = s[1] ? d2 : (s[0] ? d1 : d0);   //01: d1  1X: d2  00:d0    s?a:b  | s=1:a  s=0:b

endmodule