/*
:name: test_illegal_program_generate_region_gate
:description: A gate primitive instance is as illegal in a case generate block within a generate region of a program as it is directly in the program (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 27.3 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the selected block of a case generate construct inside a generate region of the program pgr_p contains an and gate instance
:expected_stderr_regex: test_illegal_program_generate_region_gate\.sv:27:
*/
// IEEE 1800-2023 §24.3: a program shall not contain primitives, and, by
// footnote 5 of Syntax 24-1, a program_generate_item shall not contain any
// item that would be illegal in the program outside the generate item. pgr_p
// has a generate region (27.3) with a case generate construct (27.5) whose
// selected block g_and declares the net y, which is legal, and instantiates
// an and gate, which is not.
// Oracle checks: the 5.052 release of Verilator accepts the design.

program pgr_p #(parameter int MODE = 1) (input wire a, input wire b);
  generate
    case (MODE)
      1: begin : g_and
        wire y;
        and g1 (y, a, b);   // illegal: gate primitive in a program generate block
      end
      default: begin : g_none
      end
    endcase
  endgenerate
  initial #1 $display("program");
endprogram

module test_illegal_program_generate_region_gate;
  logic a = 1'b1, b = 1'b0;
  pgr_p u_p (a, b);
endmodule
