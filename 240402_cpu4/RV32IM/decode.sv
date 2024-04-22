module controller(input  logic       clk, reset,
                  input  logic [6:0] op,  
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic       funct7b0,
                  input  logic       ZeroE,
                  input  logic       flushE,
                  input  logic       div_stallE,                 
                  output logic [1:0] ImmSrcD,
                  output logic       ALUSrcE,ResultSrcE0,PCSrcE,
                  output logic [2:0] alucontrolE,
                  output logic [1:0] ALUME,
                  output logic       RegWriteM, MemWriteM,
                  output logic [1:0] ResultSrcW,
                  output logic       RegWriteW
                  );

  logic [1:0] ALUOpD, ResultSrcD,ALUMD; //,ImmSrcD
  logic [2:0] alucontrolD;
  logic       MemWriteD, BranchD, ALUSrcD, RegWriteD, JumpD; 

  logic [1:0] ResultSrcE;
  //logic [2:0] alucontrolE;
  logic       MemWriteE, BranchE,  RegWriteE, JumpE; //ALUSrcE,

  logic [1:0] ResultSrcM;
  logic       div_flushE; 
  assign      div_flushE=ALUME[0];

 // logic [1:0] ResultSrcW;
 // logic       RegWriteW;       

  maindec md(op, ResultSrcD, MemWriteD, BranchD,
             ALUSrcD, RegWriteD, JumpD, ImmSrcD, ALUOpD);
  aludec  ad(op[5], funct3, funct7b5,funct7b0, ALUOpD, alucontrolD, ALUMD);

  

  //pipeline registers
  flopenrc #(11) regE(clk, reset,~div_stallE, flushE,
                  {ResultSrcD,alucontrolD[2],alucontrolD[0], MemWriteD, BranchD, ALUSrcD, RegWriteD, JumpD, ALUMD}, 
                  {ResultSrcE,alucontrolE[2],alucontrolE[0], MemWriteE, BranchE, ALUSrcE, RegWriteE, JumpE, ALUME});
   //for div reset_i_start;
  floprc #(1) reset_i_startE(clk, reset, div_flushE|flushE, alucontrolD[1],alucontrolE[1]);//下周期div_i_startE=0
  flopenr #(4) regM(clk, reset, ~div_stallE,
                  {ResultSrcE, MemWriteE, RegWriteE},
                  {ResultSrcM, MemWriteM, RegWriteM});
  flopenr #(3) regW(clk, reset, ~div_stallE,
                  {ResultSrcM, RegWriteM},
                  {ResultSrcW, RegWriteW});  

  assign PCSrcE = BranchE & ZeroE | JumpE;
  assign ResultSrcE0=ResultSrcE[0];   

endmodule

module maindec(input  logic [6:0] op,
               output logic [1:0] ResultSrc,
               output logic       MemWrite,
               output logic       Branch, ALUSrc,
               output logic       RegWrite, Jump,
               output logic [1:0] ImmSrc,
               output logic [1:0] ALUOp);

  logic [10:0] controls;

  assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
          ResultSrc, Branch, ALUOp, Jump} = controls;

  always_comb
    case(op)
    // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type 
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // non-implemented instruction
    endcase
endmodule

module aludec(input  logic       opb5,
              input  logic [2:0] funct3,
              input  logic       funct7b5,
              input  logic       funct7b0, 
              input  logic [1:0] ALUOp,
              output reg [2:0] ALUControl,
              output logic [1:0]     ALU_M);
//TODO

endmodule

module extend(input  logic [31:7] instr,
              input  logic [1:0]  immsrc,
              output logic [31:0] immext);
 
always_comb begin
  case(immsrc) 
    // I-type 
    2'b00:   immext = {{20{instr[31]}}, instr[31:20]};  
             // S-type (stores)
    2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
             // B-type (branches)
    2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; 
             // J-type (jal)
    2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; 
    default: immext = 32'bx; // undefined
  endcase       
end

endmodule