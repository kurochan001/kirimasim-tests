/*
:name: test_always_comb_longest_static_prefix_and_locals
:description: always_comb is sensitive to the longest static prefix of what it and its functions read (a whole array for a variable index, one bit or element for a constant one) and not to variables declared in the block or in the function (IEEE 1800-2023 Section 9.2.2.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.1 9.2.2.2 11.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_longest_static_prefix_and_locals.expected
*/
// IEEE 1800-2023 §9.2.2.2.1: the implicit sensitivity of always_comb holds
// the longest static prefix (11.5.3) of every net, variable or select read
// in the block or in a function it calls, except variables declared in the
// block or in the function. The longest static prefix of mem[idx] with a
// variable idx is mem, so any element of mem counts (and idx); that of
// vec[2] is vec[2] itself, so other bits of vec do not count; the same for
// arr2[1] read in the function.
//
// The block counts its runs by calling the task bump, whose contents add
// nothing to the list. After the run at time 0, one thing changes per time
// unit, and runs and the outputs are printed one unit later:
//   mem[3]      runs (whole mem)      vec[0]   does not run
//   vec[2]      runs                  arr2[0]  does not run (function)
//   arr2[1]     runs (function)       cb.k     does not run (block local)
//   fread.fk    does not run (function local)
//   idx         runs, and now reads mem[2], the new k and the new fk
//
// Icarus Verilog 13.0 warns that it makes the block sensitive to all bits of
// vec, and it also runs the block for the changes of the block's own k and
// the function's own fk. The 5.052 release of Verilator stops with a
// settle region that does not converge.

module test_always_comb_longest_static_prefix_and_locals;
  logic [7:0] mem [0:3] = '{8'd10, 8'd20, 8'd30, 8'd40};
  logic [7:0] arr2 [0:1] = '{8'd1, 8'd2};
  logic [7:0] vec = 8'h00;
  int idx = 1;
  int runs = 0;
  logic [7:0] y_mem, y_vec, y_f, y_k;

  task bump();
    runs++;
  endtask

  function logic [7:0] fread();
    bit [7:0] fk;
    return arr2[1] + fk;
  endfunction

  always_comb begin : cb
    bit [7:0] k;
    bump();
    y_mem = mem[idx];
    y_vec = {7'd0, vec[2]};
    y_f = fread();
    y_k = k;
  end

  task automatic show(string what);
    #1 $display("%-9s runs=%0d y_mem=%0d y_vec=%0d y_f=%0d y_k=%0d", what, runs, y_mem, y_vec,
                y_f, y_k);
  endtask

  initial begin
    show("start");
    mem[3] = 8'd41;
    show("mem[3]");
    vec[0] = 1'b1;
    show("vec[0]");
    vec[2] = 1'b1;
    show("vec[2]");
    arr2[0] = 8'd9;
    show("arr2[0]");
    arr2[1] = 8'd4;
    show("arr2[1]");
    cb.k = 8'd9;
    show("cb.k");
    fread.fk = 8'd6;
    show("fread.fk");
    idx = 2;
    show("idx");
  end
endmodule
