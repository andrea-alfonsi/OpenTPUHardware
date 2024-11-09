`ifndef CORE_CONTROL_FIXED_PRIORITY_ARBITER
`define CORE_CONTROL_FIXED_PRIORITY_ARBITER

module fixed_priority_arbiter #(
  parameter NUM_PORTS = 2
) (
  input  logic [NUM_PORTS-1:0] requests,
  output logic [NUM_PORTS-1:0] grants
);

  logic [NUM_PORTS-1:0] higher_priority_requests;
  assign higher_priority_requests[0] = 1'b0; // LSB has the highest priority


  for (genvar i=0; i<NUM_PORTS-1; i++) begin
     assign higher_priority_requests[i+1] = higher_priority_requests[i] | requests[i];
  end
  
  assign grants[NUM_PORTS-1:0] = requests[NUM_PORTS-1:0] & ~higher_priority_requests[NUM_PORTS-1:0];
endmodule


`endif