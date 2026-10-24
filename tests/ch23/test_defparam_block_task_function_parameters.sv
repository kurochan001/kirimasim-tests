/*
:name: test_defparam_block_task_function_parameters
:description: Parameters declared in a named block, a task and a function are set directly by defparam, and follow a module parameter they depend on when only that one is overridden (IEEE 1800-2023 Section 23.10.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.2 23.10.1 23.10.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_defparam_block_task_function_parameters.expected
*/
// IEEE 1800-2023 §23.10.2: a parameter declared in a named block, a task or a
// function can be redefined directly only by a defparam statement; when its
// value depends on another parameter, redefining that one updates it too
// (23.10.3). In dbp_leaf the block parameter BP, the task parameter TP and the
// function parameter FP depend on the module parameter W (default 2):
// BP = W + 1, TP = W + 10, FP = W * 3.
//   u_def keeps everything: 3 12 6.
//   u_w overrides only W = 5 in its instantiation: 6 15 15.
//   u_dp has defparams for BP, TP and FP themselves: 40 50 60.
//   u_both overrides W = 7 and BP by defparam: BP keeps 41, whatever W is,
//   while TP and FP follow W: 41 17 21.
// Oracle checks: the 5.052 release of Verilator stops with an internal error on
// the parameter of the named block.

module dbp_leaf #(parameter int W = 2) (output int bp, tp, fp);
  function int fget();
    parameter int FP = W * 3;
    return FP;
  endfunction
  task tget(output int r);
    parameter int TP = W + 10;
    r = TP;
  endtask
  initial begin : blk
    parameter int BP = W + 1;
    bp = BP;
    tget(tp);
    fp = fget();
  end
endmodule

module test_defparam_block_task_function_parameters;
  int b[4], t[4], f[4];
  dbp_leaf u_def (b[0], t[0], f[0]);
  dbp_leaf #(.W(5)) u_w (b[1], t[1], f[1]);
  dbp_leaf u_dp (b[2], t[2], f[2]);
  dbp_leaf #(.W(7)) u_both (b[3], t[3], f[3]);
  defparam u_dp.blk.BP = 40, u_dp.tget.TP = 50, u_dp.fget.FP = 60;
  defparam u_both.blk.BP = 41;
  initial begin
    #1;
    $display("u_def BP=%0d TP=%0d FP=%0d", b[0], t[0], f[0]);
    $display("u_w BP=%0d TP=%0d FP=%0d", b[1], t[1], f[1]);
    $display("u_dp BP=%0d TP=%0d FP=%0d", b[2], t[2], f[2]);
    $display("u_both BP=%0d TP=%0d FP=%0d", b[3], t[3], f[3]);
  end
endmodule
