`include "rtl/core/arithmetic/adders/brent_kung_adder.sv"

module brent_kung_adder_tb;
  logic [31:0] A, B;
  logic [32:0] S;
  brent_kung_adder adder( .A(A), .B(B), .S(S) );

  initial begin
    for(int a = -10; a < 2**8; a++) begin
      for(int b = -10; b < 2**8; b++) begin 
        A = a;
        B = b;
        #1;
        assert (S == a + b) 
        else   $error("Expected S = %d, got %d", $signed(a + b), $signed(S));
      end
    end

    A = 2147483647;
    B = 2147483647;
    #1;
    assert (S == 4294967294);
    else   $error("Expected S = %d, got %d", $signed(A + B), $signed(S));
  end
endmodule
