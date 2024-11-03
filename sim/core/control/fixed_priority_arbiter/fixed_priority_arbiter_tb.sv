`include "rtl/core/control/fixed_priority_arbiter.sv"

module fixed_priority_arbiter_tb;  

  parameter NUM_PORTS = 8;
  logic [NUM_PORTS-1:0] requests;
  logic [NUM_PORTS-1:0] grants;
  fixed_priority_arbiter #(NUM_PORTS) arbiter( .* );

  initial begin
    for (int i = 1; i < 2**NUM_PORTS; i++) begin
        requests = i;
        #1;

        assert ( $countones(grants) == 1) 
        else   $display("Arbiter granted 2 requests at same time: %b, %b", requests, grants);

        assert( (requests | grants ) >= grants )
        else $display("Arbiter granted a lower priority request: %b, %b", requests, grants);
    end
  end

endmodule
