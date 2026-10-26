/*
:name: test_illegal_udp_output_z
:description: a UDP truth table gives its output the value z (IEEE 1800-2023 Section 29.2)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the truth table entry 0 : z gives the UDP output the value z
:expected_stderr_regex: test_illegal_udp_output_z\.sv:20:
*/
// A UDP has exactly one output, whose value is 0, 1 or x; the value z is
// not supported. The truth table of this combinational UDP has an entry
// that gives the output z.

primitive p(output y, input a);
  table
    0 : z;   // illegal: a UDP output cannot be z
    1 : 1;
  endtable
endprimitive
module t;
  wire y;
  reg a;
  p u(y, a);
endmodule
