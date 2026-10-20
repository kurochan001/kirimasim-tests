/*
:name: test_defparam_before_generate
:description: A defparam reaching into an instance is applied before the generate constructs of that instance are elaborated, so the generate condition uses the value set by the defparam (IEEE 1800-2023 Section 23.10.4.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.4.1 23.10.1 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_defparam_before_generate.expected
*/
// IEEE 1800-2023 §23.10.4.1: elaboration first expands the hierarchy without
// generate constructs and gives every parameter it meets its final value,
// applying defparam statements (23.10.1); only then are the generate schemes
// evaluated. The defparam in the top module sets MODE of u to 2, so the
// conditional generate in u (27.5) chooses the block for mode 2, and the
// generated instance takes its own parameter from MODE as well.

module test_defparam_before_generate_leaf #(int N = 0);
  initial $display("%m: N=%0d", N);
endmodule

module test_defparam_before_generate_sub;
  parameter MODE = 0;

  if (MODE == 2) begin : mode2
    test_defparam_before_generate_leaf #(MODE * 10) leaf();
  end else begin : other
    initial $display("%m: MODE=%0d", MODE);
  end
endmodule

module test_defparam_before_generate;
  test_defparam_before_generate_sub u();
  defparam u.MODE = 2;
endmodule
