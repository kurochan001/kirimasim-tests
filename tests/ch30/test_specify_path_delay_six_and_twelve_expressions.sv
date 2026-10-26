/*
:name: test_specify_path_delay_six_and_twelve_expressions
:description: A six-expression path delay list gives the delays of the transitions 01, 10, 0z, z1, 1z and z0 in that order, and a twelve-expression list adds 0x, x1, 1x, x0, xz and zx in that order; each expression is a constant min:typ:max expression (IEEE 1800-2023 Sections 30.5.1, 30.5.2 and A.7.4)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.1 30.5.2 A.7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_path_delay_six_and_twelve_expressions.expected
*/
// IEEE 1800-2023 §30.5.1, Table 30-2 and A.7.4: a six-expression path delay
// list gives t01, t10, t0z, tz1, t1z and tz0 in that order; the delays of the
// x transitions are then derived by §30.5.2, which takes the shortest delay
// for a change to x and the longest for a change from x. A twelve-expression
// list gives t01, t10, t0z, tz1, t1z, tz0, t0x, tx1, t1x, tx0, txz and tzx,
// so every transition has its own delay.
//
// The cell d_six has the list (4, 2, 7, 3, 9, 6): a rise takes 4, a fall 2, a
// change from 0 to z 7, from z to 1 3, from 1 to z 9 and from z to 0 6. The
// cell d_twelve has the list of the specparams t01 = 9, t10 = 8, t0z = 7,
// tz1 = 6, t1z = 5, tz0 = 4, t0x = 3, tx1 = 2, t1x = 1, tx0 = 10, txz = 11
// and tzx = 12, so its
// transitions take 9, 8, 7, 6, 5, 4, 3, 2, 1, 10, 11 and 12 in the order of
// Table 30-2. Each cell drives its output through a bufif1 and logs every
// change of the output; the stimulus makes each transition of Table 30-2.
//
// The 5.052 release of Verilator ignores module path delays, so it does not
// produce this output.

`timescale 1ns/1ns

module pd_six (input wire d, input wire en, output wire y);
  bufif1 g (y, d, en);
  specify
    (d, en *> y) = (4, 2, 7, 3, 9, 6);
  endspecify
endmodule

module pd_twelve (input wire d, input wire en, output wire y);
  bufif1 g (y, d, en);
  specparam t01 = 9, t10 = 8, t0z = 7, tz1 = 6, t1z = 5, tz0 = 4;
  specparam t0x = 3, tx1 = 2, t1x = 1, tx0 = 10, txz = 11, tzx = 12;
  specify
    (d, en *> y) = (t01, t10, t0z, tz1, t1z, tz0, t0x, tx1, t1x, tx0, txz, tzx);
  endspecify
endmodule

module test_specify_path_delay_six_and_twelve_expressions;
  reg d = 1'b0, en = 1'b1;
  wire y_six, y_twelve;
  string log_six = "", log_twelve = "";

  pd_six u_six (d, en, y_six);
  pd_twelve u_twelve (d, en, y_twelve);

  always @(y_six) if ($time > 10) log_six = {log_six, $sformatf(" %0t:%b", $time, y_six)};
  always @(y_twelve) if ($time > 10)
    log_twelve = {log_twelve, $sformatf(" %0t:%b", $time, y_twelve)};

  initial begin
    #10 d = 1'b1;             // 0 -> 1
    #20 d = 1'b0;             // 30: 1 -> 0
    #20 en = 1'b0;            // 50: 0 -> z
    #10 d = 1'b1;             // 60: stays z
    #10 en = 1'b1;            // 70: z -> 1
    #20 en = 1'b0;            // 90: 1 -> z
    #10 d = 1'b0;             // 100: stays z
    #10 en = 1'b1;            // 110: z -> 0
    #20 d = 1'bx;             // 130: 0 -> x
    #20 d = 1'b1;             // 150: x -> 1
    #20 d = 1'bx;             // 170: 1 -> x
    #20 d = 1'b0;             // 190: x -> 0
    #20 d = 1'bx;             // 210: 0 -> x
    #20 en = 1'b0;            // 230: x -> z
    #10 d = 1'bx;             // 240: stays z
    #10 en = 1'b1;            // 250: z -> x
    #20 d = 1'b0;             // 270: x -> 0
    #40;
    $display("six:%s", log_six);
    $display("twelve:%s", log_twelve);
    $finish;
  end
endmodule
