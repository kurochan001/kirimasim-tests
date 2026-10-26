/*
:name: test_illegal_mixed_positional_named_connections
:description: The port connections of one instance shall be all positional or all named, so an instance that gives one port by order and another by name is illegal (IEEE 1800-2023 Section 23.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance u_mixed gives its first port by order and its second and third ports by name
:expected_stderr_regex: test_illegal_mixed_positional_named_connections\.sv:32:
*/
// IEEE 1800-2023 §23.3.2: positional and named module port connections
// shall not be mixed in the same module instantiation, and the connections
// to the ports of a particular module instance shall be all by order or all
// by name; only the three forms of named connections can be mixed. The
// instance u_all gives all three ports by explicit name, u_imp gives them by
// implicit name and u_wild mixes the wildcard form with an explicit name, so
// all three named forms and their mixture are legal; u_mixed gives the first
// port by order and the other two by name, which the clause forbids.

module mn_child (input a, input b, output o);
  assign o = a & b;
endmodule

module test_illegal_mixed_positional_named_connections;
  logic a, b, o, x, y;
  mn_child u_all (.a(1'b1), .b(1'b0), .o(x));
  mn_child u_imp (.a(1'b1), .b, .o);
  mn_child u_wild (.*, .a(1'b1), .o(o));
  mn_child u_mixed (1'b1, .b(1'b0), .o(y));
endmodule
