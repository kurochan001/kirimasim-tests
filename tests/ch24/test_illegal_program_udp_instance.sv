/*
:name: test_illegal_program_udp_instance
:description: A program cannot contain an instance of a user-defined primitive (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 29.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program instantiates the user-defined primitive pu_inv
:expected_stderr_regex: test_illegal_program_udp_instance\.sv:34:
*/
// IEEE 1800-2023 §24.3: a program shall not contain always procedures,
// primitives or UDPs, nor declarations or instances of modules, interfaces
// or other programs. pu_inv is a legal combinational UDP (29.3) and the
// module instantiates it, which is allowed; the program declares a variable
// and a net and has an initial procedure, and only the UDP instance on the
// marked line breaks the rule.
// Icarus Verilog 13.0 rejects the marked line because instantiations are not
// allowed in program blocks, and Verilator 5.052 rejects the instance there
// with a syntax error.

primitive pu_inv (output y, input a);
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

program pu_prog (input logic a);
  wire y_prog;
  logic seen = 1'b0;
  pu_inv u_prog (y_prog, a);   // illegal: a UDP instance in a program
  initial #1 $display("seen=%b", seen);
endprogram

module test_illegal_program_udp_instance;
  logic a = 1'b0;
  wire y_mod;
  pu_inv u_mod (y_mod, a);
  pu_prog p (.a(a));
endmodule
