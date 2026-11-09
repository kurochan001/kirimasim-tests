/*
:name: test_illegal_generic_interface_port_non_ansi
:description: A generic interface port can be declared only in an ANSI port list; a non-ANSI port declaration with the keyword interface as its type is illegal (IEEE 1800-2023 Section 25.3.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3.3 23.2.2.1 23.2.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the non-ANSI module gna_generic declares its port a with the generic interface type interface.mp
:expected_stderr_regex: test_illegal_generic_interface_port_non_ansi\.sv:48:
*/
// IEEE 1800-2023 §25.3.3: a generic interface reference, written with the
// keyword interface instead of an interface name, can be declared only in an
// ANSI list of port declarations (23.2.2.2); declaring it with the non-ANSI
// list of ports (23.2.2.1) is illegal. A non-ANSI interface port declaration
// names its interface, optionally with a modport.
// - gna_ansi declares the generic port interface.mp a in its ANSI header,
//   which is legal;
// - gna_named declares the port a in a non-ANSI header and then in its body
//   as gna_if.mp a, naming the interface, which is legal;
// - gna_generic declares a in a non-ANSI header and then in its body as
//   interface.mp a, the generic form, which is illegal.
// The illegal line uses a modport so that it cannot be read as the header of
// a nested interface declaration, which a module may contain (25.3): written
// as interface a; it would open an interface named a.
// The 5.052 release of Verilator rejects the marked line with a syntax
// error, which is the form the violation takes, as no non-ANSI port
// declaration starts with the keyword interface. Icarus Verilog 13.0 also
// rejects the legal ports, so its error on the marked line is not counted.

interface gna_if;
  logic [3:0] d;
  modport mp (output d);
endinterface

module gna_ansi (interface.mp a);
  initial #1 a.d = 4'h5;
endmodule

module gna_named (a);
  gna_if.mp a;
  initial #1 a.d = 4'h6;
endmodule

module gna_generic (a);
  interface.mp a;   // illegal: a generic interface port in a non-ANSI declaration
  initial #1 a.d = 4'h7;
endmodule

module test_illegal_generic_interface_port_non_ansi;
  gna_if i1 (), i2 (), i3 ();
  gna_ansi u1 (.a(i1));
  gna_named u2 (.a(i2));
  gna_generic u3 (.a(i3));
  initial #2 $display("%h %h %h", i1.d, i2.d, i3.d);
endmodule
