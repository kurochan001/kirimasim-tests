/*
:name: test_bind_order_freedom
:description: Two bind statements in one scope have the same effect whatever their source order, so both bound instances take part in either order (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bind_order_freedom.expected
*/
// IEEE 1800-2023 §23.11: if multiple bind statements are present in a given
// scope, the order of those statements is not important and an implementation
// is free to elaborate them in any order. The modules bo_first and bo_second
// contain the same two bind statements in opposite source order. Each places
// the instance u_a into its target as the first statement or as the second,
// and u_b the other way round, and each bound instance sets one of the target
// variables ga and gb. Both targets print a=1 b=1, so both binds took effect
// in both orders; an implementation that kept only the first or only the last
// bind of a scope, or that let the source order decide which instance exists,
// would print a=0 b=1 or a=1 b=0 in one of the two targets. The display
// times 10 and 11 fix the order of the lines. Icarus Verilog 13.0 has no
// bind directive, so the expected output is recorded with Verilator 5.052.

module bset #(parameter int WHICH = 0) (output bit got);
  initial got = 1'b1;
endmodule

module bo_first;
  bit ga, gb;
  bind bo_first bset #(.WHICH(0)) u_a (.got(ga));
  bind bo_first bset #(.WHICH(1)) u_b (.got(gb));
  initial begin
    #10 $display("order-first a=%b b=%b", ga, gb);
  end
endmodule

module bo_second;
  bit ga, gb;
  bind bo_second bset #(.WHICH(1)) u_b (.got(gb));
  bind bo_second bset #(.WHICH(0)) u_a (.got(ga));
  initial begin
    #11 $display("order-second a=%b b=%b", ga, gb);
  end
endmodule
