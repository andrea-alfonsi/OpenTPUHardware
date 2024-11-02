module miter (
        input ref_a,
        input ref_b,
        input uut_a,
        input uut_b
);
        wire ref_o;
        wire uut_o;

        dut ref (
          .a  (ref_a),
          .b  (ref_b),
          .o  (ref_o)
        );

        dut uut (
          .a  (uut_a),
          .b  (uut_b),
          .o  (uut_o)
        );

        always @(*) begin
          assume(uut_a == ref_a);
          assume(uut_b == ref_b);
          assert(uut_o == ref_o);
        end

endmodule
