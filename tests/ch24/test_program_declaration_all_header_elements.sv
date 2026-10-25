/*
:name: test_program_declaration_all_header_elements
:description: ANSI and non-ANSI program declarations with attributes, a lifetime, several package imports, a parameter port list, the port list, a time unit, items (port declarations among them) and an end label, where each element has its effect (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 23.2.1 3.14.2.2 6.21 26.4 A.1.2 A.1.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_declaration_all_header_elements.expected
*/
// IEEE 1800-2023 §24.3 and A.1.2: a program has an ANSI header that declares
// its ports or a non-ANSI header that only lists them; both have attribute
// instances, program, an optional lifetime, the name, package imports and an
// optional parameter port list. A time unit can follow the header, then the
// items and endprogram with an optional end label. A.1.7: an item of a
// non-ANSI program can be a port declaration ending with a semicolon.
//   - The imports of the header make BASE, STEP and byte_t visible in the
//     parameter port list and the port declarations (26.4).
//   - The lifetime is the default of the subroutines of the program (6.21):
//     three calls of bump give 1,1,1 when automatic and 1,2,3 when static.
//   - The time units are 100ps and 10ps, so the #5 and #50 that set the
//     output done end at 0.5ns, and the top module sees done=11 at 1ns.
// Each program prints its own line later, at 2.5ns and 3.5ns; the end of the
// last initial procedure of the programs ends the simulation (24.3).
// The 5.052 release of Verilator stops with a syntax error at the package
// import of a program header.

timeunit 1ns / 1ps;

package ph_pkg_a;
  typedef logic [7:0] byte_t;
  localparam int BASE = 10;
endpackage

package ph_pkg_b;
  localparam int STEP = 3;
endpackage

(* ph_style = "ansi" *) (* ph_note *)
program automatic ph_ansi
  import ph_pkg_a::*;
  import ph_pkg_b::STEP;
  #(parameter int N = BASE, parameter int M = STEP)
  (input byte_t a, output int sum, output bit done);
  timeunit 100ps;
  int r1, r2, r3;

  function int bump();
    int c;
    c = c + 1;
    return c;
  endfunction

  assign sum = a + N + M;
  initial begin
    done = 1'b0;
    r1 = bump();
    r2 = bump();
    r3 = bump();
    #5 done = 1'b1;
    #20 $display("ansi sum=%0d width=%0d bumps=%0d,%0d,%0d", sum, $bits(a), r1, r2, r3);
  end
endprogram : ph_ansi

(* ph_style = "nonansi" *)
program static ph_nonansi
  import ph_pkg_a::byte_t;
  import ph_pkg_b::*;
  #(parameter int K = STEP)
  (a, y, done);
  timeunit 10ps;
  input byte_t a;
  output byte_t y;
  output bit done;
  int r1, r2, r3;

  function int bump();
    int c;
    c = c + 1;
    return c;
  endfunction

  assign y = a * K;
  initial begin
    done = 1'b0;
    r1 = bump();
    r2 = bump();
    r3 = bump();
    #50 done = 1'b1;
    #300 $display("nonansi y=%0d width=%0d bumps=%0d,%0d,%0d", y, $bits(a), r1, r2, r3);
  end
endprogram : ph_nonansi

module test_program_declaration_all_header_elements;
  logic [7:0] a1 = 8'd5, a2 = 8'd7;
  int sum;
  logic [7:0] y;
  bit done_ansi, done_nonansi;

  ph_ansi #(.M(4)) u_ansi (.a(a1), .sum(sum), .done(done_ansi));
  ph_nonansi u_nonansi (a2, y, done_nonansi);

  initial #1 $display("top sum=%0d y=%0d done=%b%b", sum, y, done_ansi, done_nonansi);
endmodule
