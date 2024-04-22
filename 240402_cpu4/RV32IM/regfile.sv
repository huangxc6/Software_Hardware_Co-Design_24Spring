module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [ 4:0] a1, a2, a3, 
               input  logic [31:0] wd3, 
               output logic [31:0] rd1, rd2,
               output logic [7:0] led);

logic [31:0] rf[31:0];
logic [31:0] sim_t3;
logic [31:0] sim_t4;
logic [31:0] sim_t5;
logic [31:0] sim_t6;
// three ported register file
// read two ports combinationally (A1/RD1, A2/RD2)
// write third port on rising edge of clock (A3/WD3/WE3)
// register 0 hardwired to 0

always_ff @(negedge clk) begin
  if (we3) rf[a3] <= wd3;	
end

assign rd1 = (a1 != 0) ? rf[a1] : 0;
assign rd2 = (a2 != 0) ? rf[a2] : 0;

assign sim_t3 = rf[28];
assign sim_t4 = rf[29];
assign sim_t5 = rf[30];
assign sim_t6 = rf[31];
assign led = sim_t4[7:0];

endmodule