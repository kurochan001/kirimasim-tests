/*
:name: test_illegal_udp_definition_inside_program
:description: A UDP definition cannot appear between program and endprogram, while one at the outer level of the source text can come after the module that instantiates it (IEEE 1800-2023 Section 29.3)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the UDP udg_inner is defined inside the program udg_host
:expected_stderr_regex: test_illegal_udp_definition_inside_program\.sv:23:
*/
// IEEE 1800-2023 §29.3: UDP definitions are at the same level as module
// definitions; they can appear anywhere in the source text, before or after
// they are instantiated in a module, but they shall not appear between the
// keywords module and endmodule, program and endprogram, interface and
// endinterface, or package and endpackage. udg_outer is defined after the
// module that instantiates it, which is legal; udg_inner is defined inside
// the program udg_host.

program udg_host;
  primitive udg_inner(y, a);   // illegal: a UDP inside the program
    output y;
    input a;
    table
      0 : 1;
      1 : 0;
    endtable
  endprimitive
endprogram

module test_illegal_udp_definition_inside_program;
  logic a = 1'b0;
  wire y;
  udg_outer u (y, a);
  udg_host h ();
  initial #1 $display("%b", y);
endmodule

primitive udg_outer(y, a);
  output y;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive
