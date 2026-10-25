/*
:name: test_illegal_extern_constraint_two_blocks
:description: Two external constraint blocks for the same constraint prototype are an error (IEEE 1800-2023 Section 18.5.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the prototype etb_obj::c_pos is completed by two external constraint blocks
:expected_stderr_regex: test_illegal_extern_constraint_two_blocks\.sv:(27|28):
*/
// IEEE 1800-2023 §18.5.1: for either form of constraint prototype, giving
// more than one external constraint block for it is an error. The implicit
// prototype c_pos of etb_obj is completed twice; a tool can report the error
// at either block. The prototype c_neg is completed once and is legal.
// Icarus Verilog 13.0 does not support external constraint blocks, so the
// syntax error it reports does not count.

class etb_obj;
  rand int v;
  constraint c_pos;
  constraint c_neg;
endclass

constraint etb_obj::c_pos { v > 0; }
constraint etb_obj::c_pos { v < 100; }   // illegal: second block for c_pos
constraint etb_obj::c_neg { v != 50; }

module test_illegal_extern_constraint_two_blocks;
  etb_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
