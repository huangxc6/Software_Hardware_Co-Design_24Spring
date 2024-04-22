module alu(input  logic [31:0] a, b,
           input  logic [2:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);

  wire [31:0] subtract = a-b;

  always_comb
    case (alucontrol)
      3'b000:  result = a + b   ;       // add
      3'b001:  result = subtract;       // subtract
      3'b010:  result = a & b   ;       // and
      3'b011:  result = a | b   ;       // or
      3'b100:  result = a ^ b   ;       // xor
      3'b101:  result = {31'b0, subtract[31]}; // slt
      3'b110:  result = a << b[4:0];    // sll
      3'b111:  result = a >> b[4:0];    // srl
      default: result = 32'bx;
    endcase

  assign zero = (result == 32'b0);

endmodule
