module testbench();
    logic clk ;
    logic reset ;

    logic [31:0] WriteData ;
    logic [31:0] DataAdr ;
    logic MemWrite ;

    top dut (clk, reset, WriteData, DataAdr, MemWrite) ;

    initial begin
        reset <= 1'b1 ;
        #22 ;
        reset <= 1'b0 ;
    end

    always begin
        clk <= 1'b1 ;
        #5 ;
        clk <= 1'b0 ;
        #5 ;
    end

    always @(negedge clk) begin
        if (MemWrite) begin
            if (DataAdr == 100 & WriteData == 25) begin
                $display("Test Passed") ;
                $finish ;
            end else if (DataAdr != 96) begin
                $display("Test Failed") ;
                $finish ;
            end
        end
    end

    initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_sigle.fsdb");
			$fsdbDumpvars(0, "testbench");
		end
	end

endmodule

module top (
    input logic clk,
    input logic reset,
    output logic [31:0] WriteData,
    output logic [31:0] DataAdr,
    output logic MemWrite
);
    logic [31:0] PC, Instr, ReadData ;

    riscvsingle riscv (clk, reset, PC, Instr, MemWrite, 
                        DataAdr, WriteData, ReadData) ;

    imem imem (PC, Instr) ;
    dmem dmem (clk, MemWrite, DataAdr, WriteData, ReadData) ;
    
endmodule

module riscvsingle (
    input logic clk,
    input logic reset,
    output logic [31:0] PC,
    input logic [31:0] Instr,
    output logic MemWrite,
    output logic [31:0] ALUResult, WriteData,
    input logic [31:0] ReadData
    ); 

    logic ALUSrc, RegWrite, Jump, Zero ;
    logic [1:0] ResultSrc, ImmSrc ;
    logic [2:0] ALUControl ;

    controller c(Instr[6:0], Instr[14:12], Instr[30], Zero,
                ResultSrc, MemWrite, PCSrc, ALUSrc,
                 RegWrite, Jump, ImmSrc, ALUControl);

    datapath dp(clk, reset, ResultSrc, PCSrc,  
                ALUSrc, RegWrite, 
                ImmSrc, ALUControl,
                Zero, PC, Instr, 
                ALUResult, WriteData, ReadData) ;

endmodule

module controller (
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic       funct7b5,
    input logic       Zero,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       PCSrc,
    output logic       ALUSrc,
    output logic       RegWrite,
    output logic       Jump,
    output logic [1:0] ImmSrc,
    output logic [2:0] ALUControl
    );

    logic [1:0] ALUOp ;
    logic Branch ;

    maindec md(op, ResultSrc, MemWrite, Branch,
                ALUSrc, RegWrite, Jump, ImmSrc, ALUOp) ;

    aludec ad(op[5], funct3, funct7b5, ALUOp, ALUControl) ;

    // PCSrc = 1 means Jump
    assign PCSrc = Branch & Zero | Jump ;    
endmodule

module maindec (
    input logic [6:0] op,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       Branch,
    output logic       ALUSrc,
    output logic       RegWrite,
    output logic       Jump,
    output logic [1:0] ImmSrc,
    output logic [1:0] ALUOp
    );
    logic [10:0] controls ;
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
            ResultSrc, Branch, ALUOp, Jump} = controls ;

    always_comb begin : op_case
        case (op)
            // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
            7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
            7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
            7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type 
            7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
            7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
            7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
            default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // non-implemented instruction 
        endcase
    end
    
endmodule

module aludec (
    input logic opb5,
    input logic [2:0] funct3,
    input logic funct7b5,
    input logic [1:0] ALUOp,
    output logic [2:0] ALUControl
    );

    logic RtypeSub ;
    assign RtypeSub = funct7b5 & opb5 ;

    always_comb begin : ALUOp_case
        case (ALUOp)
            2'b00 : ALUControl = 3'b000 ; // add
            2'b01 : ALUControl = 3'b001 ; // sub 
            default: case (funct3) // R-type or I-type ALU
                3'b000: if (RtypeSub) begin
                    ALUControl = 3'b001 ; // sub
                end  else begin
                    ALUControl = 3'b000 ; // add, addi 
                end
                3'b010: ALUControl = 3'b101 ; // slt, slti
                3'b110: ALUControl = 3'b011 ; // or, ori
                3'b111: ALUControl = 3'b010 ; // and, andi
                default: ALUControl = 3'bxxx ; // non-implemented instruction
            endcase
        endcase
    end
    
endmodule

module datapath (
    input logic clk,
    input logic reset,
    input logic [1:0] ResultSrc,
    input logic PCSrc,
    input logic ALUSrc,
    input logic RegWrite,
    input logic [1:0] ImmSrc,
    input logic [2:0] ALUControl,
    output logic Zero,
    output logic [31:0] PC,
    input logic [31:0] Instr,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input logic [31:0] ReadData
    );

    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] ImmExt;
    logic [31:0] SrcA, SrcB;
    logic [31:0] Result;

    // next PC calculation
    flopr #(32) pcreg(clk, reset, PCNext, PC) ;
    adder       pcadd4(PC, 32'd4, PCPlus4) ;
    adder       pcaddbranch(PC, ImmExt, PCTarget) ;
    mux2 #(32)  pcmux(PCPlus4, PCTarget, PCSrc, PCNext) ;

    // register file logic
    regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20], 
                Instr[11:7], Result, SrcA, WriteData);
    extend ext(Instr[31:7], ImmSrc, ImmExt) ;

    // ALU logic
    mux2 #(32)  srcbmux(WriteData, ImmExt, ALUSrc, SrcB) ;
    alu alu(SrcA, SrcB, ALUControl, ALUResult, Zero) ;
    mux3 #(32)  resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);
    
endmodule

module regfile (
    input logic clk,
    input logic we3,
    input logic [4:0] a1, a2, a3,
    input logic [31:0] wd3,
    output logic [31:0] rd1, rd2
    );

    logic [31:0] rf [31:0] ;

    always_ff @(posedge clk) begin
        if (we3) begin
            rf[a3] <= wd3 ;
        end
    end
    assign rd1 = (a1 != 0) ? rf[a1] : 32'd0 ;
    assign rd2 = (a2 != 0) ? rf[a2] : 32'd0 ;

endmodule

module adder (
    input logic [31:0] a, b,
    output logic [31:0] sum
    );

    assign sum = a + b ;
    
endmodule

module extend (
    input logic [31:7] instr,
    input logic [1:0] immsrc,
    output logic [31:0] immext
    );

    always_comb begin : immext_case
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

module flopr #(
    parameter WIDTH = 8
) (
    input logic clk,
    input logic reset,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    always_ff @( posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0 ;
        end else begin
            q <= d ;
        end
    end
    
endmodule

module mux2 #(
    parameter WIDTH = 8
) (
    input logic [WIDTH-1:0] a, b,
    input logic sel,
    output logic [WIDTH-1:0] y
);
    assign y = sel ? b : a ;
endmodule

module mux3 #(
    parameter WIDTH = 8
) (
    input logic [WIDTH-1:0] a, b, c,
    input logic [1:0] sel,
    output logic [WIDTH-1:0] y
);
    assign y = (sel == 2'b00) ? a : (sel == 2'b01) ? b : c ;
endmodule

module imem (
    input logic [31:0] a, 
    output logic [31:0] rd
    );
    logic [31:0] RAM [63:0] ;

    initial 
        $readmemh("riscvtest.txt", RAM) ;

    assign rd = RAM[a[31:2]] ;    
endmodule

module dmem (
    input logic clk,
    input logic we,
    input logic [31:0] a, wd,
    output logic [31:0] rd
    );

    logic [31:0] RAM [63:0] ;

    assign rd = RAM[a[31:2]] ;  

    always_ff @( posedge clk ) begin
        if (we) begin
            RAM[a[31:2]] <= wd ;
        end
    end

endmodule

module alu (
    input logic [31:0] a, b,
    input logic [2:0] alucontrol,
    output logic [31:0] result,
    output logic zero
    );

    logic [31:0] condinvb, sum ;
    logic v; // overflow
    logic isAddSub ; 

    assign condinvb = alucontrol[0] ? ~b : b ;
    assign sum = a + condinvb + alucontrol[0] ;
    assign isAddSub = ~alucontrol[2] & ~alucontrol[1] 
                     | alucontrol[1] & alucontrol[0] ;
    
    always_comb begin
        case (alucontrol)
            3'b000:  result = sum;         // add
            3'b001:  result = sum;         // subtract
            3'b010:  result = a & b;       // and
            3'b011:  result = a | b;       // or
            3'b100:  result = a ^ b;       // xor
            3'b101:  result = sum[31] ^ v; // slt
            3'b110:  result = a << b[4:0]; // sll
            3'b111:  result = a >> b[4:0]; // srl
            default: result = 32'bx;
        endcase
    end

    assign zero = (result == 0) ? 1 : 0 ;
  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;

endmodule