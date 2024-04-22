// Implements a subset of the base integer instructions:
//    lw, sw
//    add, sub, and, or, slt, 
//    addi, andi, ori, slti
//    beq
//    jal
// Exceptions, traps, and interrupts not implemented
// little-endian memory

// 31 32-bit registers x1-x31, x0 hardwired to 0
// R-Type instructions
//   add, sub, and, or, slt
//   INSTR rd, rs1, rs2
//   Instr[31:25] = funct7 (funct7b5 & opb5 = 1 for sub, 0 for others)
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// I-Type Instructions
//   lw, I-type ALU (addi, andi, ori, slti)
//   lw:         INSTR rd, imm(rs1)
//   I-type ALU: INSTR rd, rs1, imm (12-bit signed)
//   Instr[31:20] = imm[11:0]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// S-Type Instruction
//   sw rs2, imm(rs1) (store rs2 into address specified by rs1 + immm)
//   Instr[31:25] = imm[11:5] (offset[11:5])
//   Instr[24:20] = rs2 (src)
//   Instr[19:15] = rs1 (base)
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:0]  (offset[4:0])
//   Instr[6:0]   = opcode
// B-Type Instruction
//   beq rs1, rs2, imm (PCTarget = PC + (signed imm x 2))
//   Instr[31:25] = imm[12], imm[10:5]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:1], imm[11]
//   Instr[6:0]   = opcode
// J-Type Instruction
//   jal rd, imm  (signed imm is multiplied by 2 and added to PC, rd = PC+4)
//   Instr[31:12] = imm[20], imm[10:1], imm[11], imm[19:12]
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode

//   Instruction  opcode    funct3    funct7
//   add          0110011   000       0000000
//   sub          0110011   000       0100000
//   and          0110011   111       0000000
//   or           0110011   110       0000000
//   slt          0110011   010       0000000
//   addi         0010011   000       immediate
//   andi         0010011   111       immediate
//   ori          0010011   110       immediate
//   slti         0010011   010       immediate
//   beq          1100011   000       immediate
//   lw	          0000011   010       immediate
//   sw           0100011   010       immediate
//   jal          1101111   immediate immediate

module riscvpipe(input  logic        clk, reset,
                   output logic [31:0] PCF,
                   input  logic [31:0] Instr,
                   output logic        MemWriteM,
                   output logic [31:0] ALUResultM, WriteDataM,
                   input  logic [31:0] ReadDataM,
                   output logic [7:0] led);

  logic       ZeroE,div_stallE,flushE, ALUSrcE,ResultSrcE0,PCSrcE,
              RegWriteM,  RegWriteW;
  logic [1:0] ImmSrcD,ALUME,ResultSrcW;
  logic [2:0] alucontrolE;
  logic [31:0]InstrF,InstrD;

  assign InstrF=Instr;
  controller c(clk, reset,InstrD[6:0], InstrD[14:12], InstrD[30],InstrD[25],
                ZeroE,flushE,div_stallE,
               ImmSrcD,ALUSrcE,ResultSrcE0,PCSrcE,alucontrolE,ALUME,
               RegWriteM, MemWriteM,
               ResultSrcW,RegWriteW
               );

  datapath dp(clk, reset, ImmSrcD, ALUSrcE,ResultSrcE0,PCSrcE,alucontrolE,ALUME,RegWriteM,
              ResultSrcW,  RegWriteW,ZeroE,flushE, div_stallE, 
              PCF,InstrF,InstrD,ALUResultM, WriteDataM,ReadDataM,led);

endmodule