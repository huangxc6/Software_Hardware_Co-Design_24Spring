//hazard detection added 
module hazard(input  [4:0] rs1D, rs2D, rs1E, rs2E, 
input  [4:0] rdE, rdM, rdW,
input        regwriteM, regwriteW, ResultSrcE0,PCSrcE,RtypedivE,DIV_validE,
output logic     div_stallE,
output reg [1:0] forwardaE, forwardbE,
output       stallF, stallD,flushD,flushE);

wire lwstall;

//TO ADD DIV STALL

// forwarding sources to D stage (branch equality)
// assign forwardaD = (rsD !=0 & rsD == writeregM & regwriteM);
// assign forwardbD = (rtD !=0 & rtD == writeregM & regwriteM);

// forwarding sources to E stage (ALU)
always_comb 
begin
forwardaE = 2'b00; forwardbE = 2'b00;
if (rs1E != 0)
if (rs1E == rdM & regwriteM ) forwardaE = 2'b10;
else if (rs1E == rdW & regwriteW) forwardaE = 2'b01;
if (rs2E != 0)
if (rs2E == rdM & regwriteM ) forwardbE = 2'b10;
else if (rs2E == rdW & regwriteW ) forwardbE = 2'b01;
end

// stalls  Load word stall logic:
assign #1 lwstall = ResultSrcE0 & (rdE == rs1D | rdE == rs2D);
//assign #1 flushE = lwstall  //combed in next hazard
assign #1 stallD = lwstall ;
assign #1 stallF = stallD; // stalling D stalls all previous stages

//Control hazard flush
assign #1 flushD = PCSrcE;
assign #1 flushE = lwstall|PCSrcE; // stalling D flushes next stage

// *** not necessary to stall D stage on store if source comes from load;
// *** instead, another bypass network could be added from W to M

endmodule