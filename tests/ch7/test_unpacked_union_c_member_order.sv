/*
:name: test_unpacked_union_c_member_order
:description: Unpacked union members preserve C compatible structure order
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: union_c_layout/layout.c union_c_layout/compare.cpp
:expected_stdout: @test_unpacked_union_c_member_order.expected
*/
module test_unpacked_union_c_member_order;
  typedef struct {
    byte marker;
    longint codepoint;
    real ratio;
  } left_t;

  typedef struct {
    byte marker;
    longint codepoint;
    shortint mode;
    real score;
  } right_t;

  typedef union { left_t left; right_t right; } overlay_t;
  overlay_t specimen;

  initial begin
    specimen.left = '{8'd23, 64'sd4815162342, 3.75};
    $display("left ratio=%0.2f common=%0d,%0d", specimen.left.ratio,
             specimen.right.marker, specimen.right.codepoint);
    specimen.right = '{8'd62, -64'sd391827465, -16'sd51, -0.75};
    $display("right mode=%0d score=%0.2f common=%0d,%0d", specimen.right.mode,
             specimen.right.score, specimen.left.marker, specimen.left.codepoint);
    $finish(0);
  end
endmodule
