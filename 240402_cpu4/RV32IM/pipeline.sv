module datapath(input  logic        clk, reset,
                input  logic [1:0]  ImmSrcD,
                input  logic        ALUSrcE,ResultSrcE0,PCSrcE,
                input  logic [2:0]  alucontrolE,
                input  logic [1:0]  ALUME,   
                input  logic        RegWriteM,
                input  logic [1:0]  ResultSrcW,
                input  logic        RegWriteW,
                output logic        ZeroE,
                output logic        flushE, div_stall,          
                output logic [31:0] PCF,
                input  logic [31:0] instrF,
                output logic [31:0] instrD,
                output logic [31:0] ALUResultM, WriteDataM,
                input  logic [31:0] ReadDataM,
                output logic [7:0] led);

  logic [4:0]  rs1D, rs2D, rs1E, rs2E,rdD, rdE, rdM, rdW;
  logic [31:0] PCNext, PCD,PCE,PCPlus4F, PCPlus4D,PCPlus4E,PCPlus4M,PCPlus4W, PCTargetE;
  // logic [31:0] instrD;
  logic [31:0] ImmExtD,ImmExtE;
  logic [31:0] RD1D,RD2D,RD1E,RD2E, SrcAE, SrcBE;
  logic [31:0] ALUResultE, ALUResultW, WriteDataE, ReadDataW,ResultW;
  logic [1:0]  forwardaE, forwardbE;    
  logic        stallF, stallD,flushD;  
  logic        DIV_flushE,DIV_busyE,DIV_validE,div_stallE;
  logic        RtypedivE,div_i_startE;

  assign div_stall=div_stallE;

  assign RtypedivE=ALUME[0];
  assign div_i_startE=RtypedivE & ALUME[0];

  // hazard detection
  hazard h(rs1D, rs2D, rs1E, rs2E, rdE, rdM, rdW,
         RegWriteM, RegWriteW, ResultSrcE0,PCSrcE,RtypedivE,DIV_validE,
         div_stallE,
         forwardaE, forwardbE, 
         stallF, stallD,flushD,flushE);

  // next PC logic
  mux2 #(32)  pcbrmux(PCPlus4F, PCTargetE, PCSrcE, PCNext);

  // Fetch stage logic
  flopenr #(32) pcreg(clk, reset, ~(stallD|div_stallE),PCNext,PCF);
  adder       pcadd4(PCF, 32'd4, PCPlus4F);

  // Decode stage
  flopenrc #(32) pcd(clk, reset, ~(stallD|div_stallE), flushD, PCF,PCD);
  flopenrc #(32) PC4D(clk, reset, ~(stallD|div_stallE), flushD, PCPlus4F,PCPlus4D);

  //need to reset to addi X0, X0, 0
  flopenrc #(32,32'b0010011) INSTD(clk, reset, ~(stallD|div_stallE), flushD, instrF, instrD);
  
  assign rs1D = instrD[19:15];
  assign rs2D = instrD[24:20];
  assign rdD = instrD[11:7];

  //register file logic
  regfile rf(clk, RegWriteW, rs1D, rs2D, rdW, ResultW, RD1D, RD2D, led);
  extend  ext(instrD[31:7], ImmSrcD, ImmExtD);

  //Execute stage 
  flopenrc #(32) rdata1E(clk, reset, ~div_stallE, flushE, RD1D, RD1E);
  flopenrc #(32) rdata2E(clk, reset, ~div_stallE, flushE, RD2D, RD2E);
  flopenrc #(32) immE   (clk, reset, ~div_stallE, flushE, ImmExtD, ImmExtE);
  flopenrc #(32) pcplus4E(clk, reset,~div_stallE, flushE, PCPlus4D, PCPlus4E);
  flopenrc #(32) pcE(clk, reset,     ~div_stallE, flushE, PCD, PCE);
  flopenrc #(5)  rs11E(clk, reset,   ~div_stallE, flushE, rs1D, rs1E);
  flopenrc #(5)  rs22E(clk, reset,   ~div_stallE, flushE, rs2D, rs2E);
  flopenrc #(5)  rddE(clk, reset,    ~div_stallE, flushE, rdD, rdE);
 
  mux3 #(32)  forwardaemux(RD1E, ResultW, ALUResultM, forwardaE, SrcAE);
  mux3 #(32)  forwardbemux(RD2E, ResultW, ALUResultM, forwardbE, WriteDataE);
  mux2 #(32)  srcbmux(WriteDataE, ImmExtE, ALUSrcE, SrcBE);

  // ALU logic
  //assign DIV_flushE = flushE;
  alu    alu(clk, reset,SrcAE, SrcBE, alucontrolE, ALUME,flushE,DIV_busyE,DIV_validE, ALUResultE, ZeroE);
  adder  pcaddJAL(PCE, ImmExtE, PCTargetE);
  
  // Memory stage 
  //add div  when div is valid, continue the pipeline 
 
  flopenr #(32) r1M    (clk, reset,  ~div_stallE  , WriteDataE, WriteDataM);
  flopenr #(32) r2M    (clk, reset,  ~div_stallE  ,ALUResultE, ALUResultM);
  flopenr #(32) pcplus4M(clk, reset, ~div_stallE  ,  PCPlus4E, PCPlus4M);
  flopenr #(5)  rdm(clk, reset,      ~div_stallE  , rdE, rdM);
  
  //flopr #(1) con_pipe(clk, reset, Con_pipeM, Con_pipeW);
  //writeback stage
  flopenr #(32) aluM(clk, reset, ~div_stallE, ALUResultM, ALUResultW);
  flopenr #(32) pcplus4w(clk, reset, ~div_stallE, PCPlus4M, PCPlus4W);
  flopenr #(32) resultW(clk, reset, ~div_stallE, ReadDataM, ReadDataW);
  flopenr #(5)  rdw(clk, reset, ~div_stallE, rdM, rdW);
  mux3    #(32) resultmux(ALUResultW, ReadDataW, PCPlus4W, ResultSrcW, ResultW);

endmodule