module core_top(    input  logic        clk,
                    input  logic        reset,
                    output logic [31:0] PC,
                    input  logic [31:0] Instr,
                    output logic        MemWrite,
                    output logic [31:0] ALUResult, // Mem addr;
                    output logic [31:0] WriteData,  
                    input  logic [31:0] ReadData,
                    output logic [31:0] sim_t3,
                    output logic [31:0] sim_t4,
                    output logic [31:0] sim_t5,
                    output logic [31:0] sim_t6);

  logic       PCSrc, ALUSrc, RegWrite, Jump, Zero;
  logic [1:0] ResultSrc, ImmSrc;
  logic [2:0] ALUControl;

  controller c( .op        (Instr[6:0]  ),
                .funct3    (Instr[14:12]),
                .funct7b5  (Instr[30]   ),
                .Zero      (Zero        ),
                .ResultSrc (ResultSrc   ),
                .MemWrite  (MemWrite    ),
                .PCSrc     (PCSrc       ), 
                .ALUSrc    (ALUSrc      ),
                .RegWrite  (RegWrite    ), 
                .Jump      (Jump        ),
                .ImmSrc    (ImmSrc      ),
                .ALUControl(ALUControl  ));

  datapath dp(  .clk       (clk         ), 
                .reset     (reset       ),
                .ResultSrc (ResultSrc   ), 
                .PCSrc     (PCSrc       ), 
                .ALUSrc    (ALUSrc      ),
                .RegWrite  (RegWrite    ),
                .ImmSrc    (ImmSrc      ),
                .ALUControl(ALUControl  ),
                .Zero      (Zero        ),  // output alu zero to control unit.
                .PC        (PC          ),
                .Instr     (Instr       ),
                .ALUResult (ALUResult   ),  // Mem addr;
                .WriteData (WriteData   ),
                .ReadData  (ReadData    ),
                .sim_t3    (sim_t3      ),
                .sim_t4    (sim_t4      ),
                .sim_t5    (sim_t5      ),
                .sim_t6    (sim_t6      ));

endmodule