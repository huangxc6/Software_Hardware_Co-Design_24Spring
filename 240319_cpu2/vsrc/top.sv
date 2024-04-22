module top(input  logic        clk_in1_p, 
           input  logic        clk_in1_n, 
           input  logic        reset, 
           output logic [7:0]  led);

  logic clk, MemWrite;
  logic [31:0] PC, Instr, ReadData,WriteData, DataAdr;
  logic [31:0] sim_t3, sim_t4, sim_t5, sim_t6;
  
  // instantiate processor and memories
  core_top  rvsingle( .clk      (clk      ),
                      .reset    (reset    ),
                      .PC       (PC       ),
                      .Instr    (Instr    ),
                      .MemWrite (MemWrite ),
                      .ALUResult(DataAdr  ), // Mem addr;
                      .WriteData(WriteData),  
                      .ReadData (ReadData ),
                      .sim_t3   (sim_t3   ),
                      .sim_t4   (sim_t4   ),
                      .sim_t5   (sim_t5   ),
                      .sim_t6   (sim_t6   ));

  imem      imem    ( .a        (PC       ),
                      .rd       (Instr    ));

  dmem      dmem    ( .clk      (clk      ),
                      .we       (MemWrite ),
                      .a        (DataAdr  ), 
                      .wd       (WriteData),
                      .rd       (ReadData ));
 
     clk_wiz_0 u_clk_wiz
      (
       // Clock out ports
       .clk_out1(clk),     // output clk_out1
      // Clock in ports
       .clk_in1_p(clk_in1_p),    // input clk_in1_p
       .clk_in1_n(clk_in1_n));    // input clk_in1_n

   assign led[7:0] = sim_t4[7:0];

endmodule