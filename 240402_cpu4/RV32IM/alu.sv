module alu(input  logic        clk   ,
           input  logic        rst   ,
           input  logic [31:0] a, b,
           input  logic [2:0]  alucontrol,
           input  logic [1:0]  alum,
           input  logic        i_div_flush,
           output logic        o_div_busy,
           output logic        o_div_valid,
           output logic [31:0] result_out,
           output logic        zero);

  logic [31:0] condinvb, sum, result, 
               quotient , remainder,  
               mult_high, mult_low;
  logic        v;              // overflow
  logic        isAddSub;       // true when is add or subtract operation
 // logic        div_i_start;    // div start

  assign condinvb = alucontrol[0] ? ~b : b;
  assign sum = a + condinvb + alucontrol[0];
  assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                    ~alucontrol[1] & alucontrol[0];
  //serdiv
  serdiv #(32) div1 (
    clk  , rst   ,
    i_div_flush, alucontrol[1]&alum[0], o_div_busy, o_div_valid, alucontrol[2],
    a, b, quotient , remainder );
  //mul
  mult #(32) mult1 (
    alucontrol[2], alucontrol[1],
     a, b,   
     mult_high, mult_low);

  //reset div  i_start

  always_comb
    case ({alum,alucontrol}) inside
      5'b00000:  result_out = sum;         // add
      5'b00001:  result_out = sum;         // subtract
      5'b00010:  result_out = a & b;       // and
      5'b00011:  result_out = a | b;       // or
      5'b00100:  result_out = a ^ b;       // xor
      5'b00101:  result_out = sum[31] ^ v; // slt
      5'b00110:  result_out = a << b[4:0]; // sll
      5'b00111:  result_out = a >> b[4:0]; // srl
      5'b11??0:  result_out= quotient;
      5'b11??1:  result_out= remainder;
      5'b10??0:  result_out= mult_low;
      5'b10??1:  result_out= mult_high;
      default:  result_out = 32'bx;
    endcase
  assign zero = (result_out == 32'b0);
  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
  
endmodule

module adder(input  [31:0] a, b,
             output [31:0] y);

assign y = a + b;

endmodule