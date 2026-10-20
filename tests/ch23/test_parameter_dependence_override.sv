/*
:name: test_parameter_dependence_override
:description: A parameter whose default uses another parameter follows that parameter when it is overridden, unless it is overridden itself, and a value parameter typed by a type parameter is recomputed with the type of the override (IEEE 1800-2023 Section 23.10.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.3 23.10.2.2 6.20.2 6.20.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_dependence_override.expected
*/
// IEEE 1800-2023 §23.10.3: overriding a parameter replaces its definition, so
// a parameter defined from it is recomputed: DEPTH follows WIDTH unless DEPTH
// is overridden too, in which case it keeps the given value. A parameter may
// also depend on the range or type of others: P2 has the range [P:0], and P3
// the type T, so the value 300 is cut to the range or type each instance
// gives (6.20.2, 6.20.3). The instances override by name (23.10.2.2).

module test_parameter_dependence_override_sub
  #(int WIDTH = 8, int DEPTH = WIDTH * 2, int P = 1, parameter [P:0] P2 = 13,
    type T = byte, T P3 = 300);
  initial #(WIDTH) $display("%m: WIDTH=%0d DEPTH=%0d P2=%0d P3=%0d", WIDTH, DEPTH, P2, P3);
endmodule

module test_parameter_dependence_override;
  test_parameter_dependence_override_sub u1();
  test_parameter_dependence_override_sub #(.WIDTH(10)) u2();
  test_parameter_dependence_override_sub #(.WIDTH(12), .DEPTH(100)) u3();
  test_parameter_dependence_override_sub #(.WIDTH(14), .P(3), .T(int)) u4();
endmodule
