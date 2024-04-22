module top(input  logic       clk, 
           
           input  logic        reset,                         
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite,
           output logic [7:0] led);

  logic [31:0] PC, Instr, ReadData;
  //logic [31:0] WriteData, DataAdr;
 
  // instantiate processor and memories
  riscvpipe riscvpipe(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData,led);
  imem imem(PC, Instr);
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);

endmodule