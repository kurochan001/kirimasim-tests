/*
:name: test_parameter_override_ordered_and_named
:description: An instance parameter value assignment by ordered list gives the values in the order the parameters are declared and cannot skip one, while assignment by name gives each value to the parameter with that name in any order (IEEE 1800-2023 Sections 23.10.2.1 and 23.10.2.2, C.4.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.2.1 23.10.2.2 C.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_override_ordered_and_named.expected
*/
// IEEE 1800-2023 §23.10.2.1: in an instance parameter value assignment by
// ordered list the values follow the order in which the parameters are
// declared, and a parameter cannot be skipped, so the values given reach the
// leading parameters and the rest keep their defaults. §23.10.2.2: an
// assignment by name gives a value to the parameter named, in any order, so
// the parameters between the named ones keep their defaults. C.4.1: the
// explicit inline form is the one that C.4.1 recommends in place of defparam.
//
// leaf declares A, B and C with the defaults 1, 2 and 3. u1 is given one
// value by order, which reaches A only; u2 two values, which reach A and B;
// u3 writes all three in order and gives B the value of its declaration,
// which is how a parameter that does not change is kept at its default. u4
// names C and A, out of order, and leaves B at its default. The top module
// prints the parameters at a fixed time.

module leaf #(parameter int A = 1, parameter int B = 2, parameter int C = 3);
endmodule

module test_parameter_override_ordered_and_named;
  leaf #(4) u1();
  leaf #(5, 6) u2();
  leaf #(7, 2, 9) u3();
  leaf #(.C(13), .A(12)) u4();

  initial begin
    #1;
    $display("u1 %0d %0d %0d", u1.A, u1.B, u1.C);
    $display("u2 %0d %0d %0d", u2.A, u2.B, u2.C);
    $display("u3 %0d %0d %0d", u3.A, u3.B, u3.C);
    $display("u4 %0d %0d %0d", u4.A, u4.B, u4.C);
    $finish;
  end
endmodule
