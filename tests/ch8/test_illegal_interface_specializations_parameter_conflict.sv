/*
:name: test_illegal_interface_specializations_parameter_conflict
:description: Two different specializations of one parameterized interface class are distinct interface classes, so an interface class that inherits both through two others has an unresolved parameter name conflict (IEEE 1800-2023 Section 8.26.6.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: port_if inherits the parameter W from sized_if#(8) through reader_if and from sized_if#(16) through writer_if and does not declare W itself
:expected_stderr_regex: test_illegal_interface_specializations_parameter_conflict\.sv:47:
*/
// IEEE 1800-2023 §8.26.6.3: an interface class that reaches one interface
// class in several ways is a diamond, and only one copy of its symbols is
// merged. Each specialization of a parameterized interface class is a unique
// interface class, so reaching two different specializations is no diamond,
// and their parameters of the same name conflict as described in 8.26.6.2,
// which requires the inheriting interface class to declare the name.
// reader_if and peek_if both extend sized_if#(8), so shared_if, which extends
// both, has a single W and is legal. writer_if extends sized_if#(16);
// port_if extends reader_if and writer_if and so inherits W from two
// different specializations without declaring W. Without port_if the design
// has no error and prints 16, the W of sized_if#(16).
// Icarus Verilog 13.0 does not support interface classes, so its syntax
// error does not count, and the 5.054 release of Verilator accepts the
// design.

interface class sized_if #(int W = 8);
endclass

interface class reader_if extends sized_if #(8);
  pure virtual function int read();
endclass

interface class peek_if extends sized_if #(8);
  pure virtual function int peek();
endclass

interface class writer_if extends sized_if #(16);
  pure virtual function void write(int d);
endclass

interface class shared_if extends reader_if, peek_if;
endclass

interface class port_if extends reader_if, writer_if;   // illegal: W conflicts
endclass

module test_illegal_interface_specializations_parameter_conflict;
  initial $display("%0d", sized_if#(16)::W);
endmodule
