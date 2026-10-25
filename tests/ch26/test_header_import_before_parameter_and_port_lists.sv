/*
:name: test_header_import_before_parameter_and_port_lists
:description: Package imports in an ANSI header followed by a parameter port list and a port list (module), by a port list only (interface) and by a parameter port list only (program) make the package items usable in those lists (IEEE 1800-2023 Section 26.4)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.4 23.2.2.2 A.1.2 A.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_header_import_before_parameter_and_port_lists.expected
*/
// IEEE 1800-2023 §26.4 with footnote 1 of A.10 (on the ANSI headers of
// A.1.2): package imports in the header of a module, interface or program
// are followed by a parameter port list, a list of port declarations, or
// both, and the imported items are visible in those lists and in the body.
//
// hdr_both (module) imports all of hdr_pkg and SCALE from aux_pkg (two
// imports), then has both lists: the type of its parameter INIT and of its
// port q is hdr_pkg::word_t (12 bits), and the default of INIT is
// hdr_pkg::DEF = 12'h5A5. b1 keeps the default, b2 overrides it with
// 12'h0F0, and s = SCALE * 2 = 6.
// hdr_ports (interface) imports word_t and has a port list only: its input
// d is 12 bits wide and follows q1.
// hdr_params (program) imports hdr_pkg and has a parameter port list only:
// N defaults to double(WIDTH) = 2 * 12 = 24, a call of an imported function.
// The module prints at time 1 and the program at time 2.
//
// The 5.052 release of Verilator reports a syntax error at the import in
// the header of the program.

package hdr_pkg;
  typedef logic [11:0] word_t;
  parameter word_t DEF = 12'h5A5;
  localparam int WIDTH = 12;

  function automatic int double(int x);
    return 2 * x;
  endfunction
endpackage

package aux_pkg;
  parameter int SCALE = 3;
endpackage

module hdr_both import hdr_pkg::*; import aux_pkg::SCALE; #(parameter word_t INIT = DEF)
  (output word_t q, output int s);
  assign q = INIT;
  assign s = SCALE * 2;
endmodule

interface hdr_ports import hdr_pkg::word_t; (input word_t d);
  word_t seen;
  assign seen = d;
endinterface

program hdr_params import hdr_pkg::*; #(parameter int N = double(WIDTH));
  initial #2 $display("program: N=%0d", N);
endprogram

module test_header_import_before_parameter_and_port_lists;
  hdr_pkg::word_t q1, q2;
  int s1;

  hdr_both b1 (.q(q1), .s(s1));
  hdr_both #(.INIT(12'h0F0)) b2 (.q(q2), .s());
  hdr_ports ip (.d(q1));
  hdr_params pp ();

  initial begin
    #1 $display("module: q1=%h q2=%h bits=%0d s1=%0d", q1, q2, $bits(q1), s1);
    $display("interface: seen=%h bits=%0d", ip.seen, $bits(ip.d));
  end
endmodule
