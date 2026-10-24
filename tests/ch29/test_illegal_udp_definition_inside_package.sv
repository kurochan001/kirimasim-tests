/*
:name: test_illegal_udp_definition_inside_package
:description: A UDP definition cannot appear between package and endpackage, while one at the outer level of the source text can come after the module that instantiates it (IEEE 1800-2023 Section 29.3)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the UDP udk_inner is defined inside the package udk_host
:expected_stderr_regex: test_illegal_udp_definition_inside_package\.sv:24:
*/
// IEEE 1800-2023 §29.3: UDP definitions are at the same level as module
// definitions; they can appear anywhere in the source text, before or after
// they are instantiated in a module, but they shall not appear between the
// keywords module and endmodule, program and endprogram, interface and
// endinterface, or package and endpackage. udk_outer is defined after the
// module that instantiates it, which is legal; udk_inner is defined inside
// the package udk_host.

package udk_host;
  localparam int k = 1;
  primitive udk_inner(y, a);   // illegal: a UDP inside the package
    output y;
    input a;
    table
      0 : 1;
      1 : 0;
    endtable
  endprimitive
endpackage

module test_illegal_udp_definition_inside_package;
  logic a = 1'b0;
  wire y;
  udk_outer u (y, a);
  initial $display("%0d", udk_host::k);
  initial #1 $display("%b", y);
endmodule

primitive udk_outer(y, a);
  output y;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive
