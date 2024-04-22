module datapath(input  logic        clk, 
                input  logic        reset,
                input  logic [1:0]  ResultSrc, 
                input  logic        PCSrc, 
                input  logic        ALUSrc,
                input  logic        RegWrite,
                input  logic [1:0]  ImmSrc,
                input  logic [2:0]  ALUControl,
                output logic        Zero,
                output logic [31:0] PC,
                input  logic [31:0] Instr,
                output logic [31:0] ALUResult,  // Mem addr;
                output logic [31:0] WriteData,
                input  logic [31:0] ReadData,
                output logic [31:0] sim_t3,
                output logic [31:0] sim_t4,
                output logic [31:0] sim_t5,
                output logic [31:0] sim_t6);

  logic [31:0] PCNext, PCPlus4, PCTarget;
  logic [31:0] ImmExt;
  logic [31:0] reg1, reg2; // from reg file.
  logic [31:0] SrcA, SrcB; // to alu.
  logic [31:0] Result;

  // 1. next PC update logic:
  assign PCPlus4 = PC + 32'd4;
  assign PCTarget = PC + ImmExt;
  assign PCNext = PCSrc ? PCTarget : PCPlus4;

  always_ff @(posedge clk, posedge reset)begin
    if (reset) PC <= 0;
    else       PC <= PCNext;
  end

  // 2. register file logic:
  regfile rf( .clk(clk        ), 
              .we3(RegWrite   ),  // rd write enable
              .a1(Instr[19:15]),  // rs1 index
              .a2(Instr[24:20]),  // rs2 index 
              .a3(Instr[11:7] ),  // rd  index
              .wd3(Result     ),  // rd write data
              .rd1(reg1       ), 
              .rd2(reg2       ),
              .sim_t3(sim_t3  ),
              .sim_t4(sim_t4  ),
              .sim_t5(sim_t5  ),
              .sim_t6(sim_t6  ));

  extend      ext(Instr[31:7], ImmSrc, ImmExt);

  // 3. ALU logic:
  assign SrcA = reg1;
  assign SrcB = ALUSrc ? ImmExt : reg2;
  alu         alu(SrcA, SrcB, ALUControl, ALUResult, Zero);

  // 4. Store logic:
  assign WriteData = reg2;
  // WriteAddr is AluResult.

  // 5. Write back to Destination Register logic:
  assign Result = ResultSrc[1] ? PCPlus4 : (ResultSrc[0] ? ReadData: ALUResult);

endmodule
