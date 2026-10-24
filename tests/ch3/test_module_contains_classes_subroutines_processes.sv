/*
:name: test_module_contains_classes_subroutines_processes
:description: A module holds a class declaration, class objects constructed in a declaration and in a procedure, a function and a time-consuming task, a continuous assignment, initial, always, always_ff, always_comb and final procedures, and loop, if and case generate blocks, and each of them works (IEEE 1800-2023 Section 3.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.3 8.3 8.7 13.3 13.4 10.3 9.2 27.4 27.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_contains_classes_subroutines_processes.expected
*/
// IEEE 1800-2023 §3.3: besides ports and declarations, a module can contain
// class definitions, instantiations of class objects, subroutine definitions,
// continuous assignments, procedural blocks and generate blocks. Each kind
// appears in the one module below and its effect is printed:
// - class: acc_c is declared in the module (§8.3); one object is constructed
//   by the initializer of a module variable, which runs before any procedure
//   starts, and one by new in the initial procedure (§8.7); both are used
//   through their methods;
// - subroutines: a function that returns a value (§13.4) and a task that
//   waits 2 time units before it writes its output (§13.3), so the caller goes
//   on at time 2;
// - continuous assignment: sum_w follows a + b (§10.3);
// - procedural blocks (§9.2): initial, always (the clock), always_ff (counts
//   rising edges at 5 and 15, so 2 by time 22), always_comb (a ^ b) and final,
//   which runs when $finish ends the simulation;
// - generate blocks: a loop generate writes one bit of gen_w per iteration
//   (§27.4), and an if generate and a case generate each pick one named block
//   from the value of N (§27.5), whose localparam is read by its name.
// With a = 13 and b = 7: a + b = 20, a ^ b = 10, the low 3 bits of a & b are
// 101, and N = 3 picks the blocks with 30 and 300.

`timescale 1ns/1ns

module test_module_contains_classes_subroutines_processes;
  class acc_c;
    int total;

    function new(int start);
      total = start;
    endfunction

    function void add(int v);
      total += v;
    endfunction
  endclass

  acc_c acc_decl = new(100);
  acc_c acc_proc;

  function automatic int square(int x);
    return x * x;
  endfunction

  task automatic delayed_double(input int x, output int y);
    #2 y = 2 * x;
  endtask

  logic [7:0] a, b;
  wire [8:0] sum_w;
  assign sum_w = a + b;

  logic clk = 0;
  int edges = 0;
  logic [7:0] comb_y;

  always #5 clk = ~clk;
  always_ff @(posedge clk) edges <= edges + 1;
  always_comb comb_y = a ^ b;

  localparam int N = 3;
  wire [N-1:0] gen_w;

  for (genvar i = 0; i < N; i++) begin : g_bits
    assign gen_w[i] = a[i] & b[i];
  end

  if (N == 3) begin : g_if
    localparam int PICK = 30;
  end else begin : g_if
    localparam int PICK = 40;
  end

  case (N)
    2: begin : g_case
      localparam int PICK = 200;
    end
    3: begin : g_case
      localparam int PICK = 300;
    end
    default: begin : g_case
      localparam int PICK = 400;
    end
  endcase

  initial begin
    int r;
    a = 8'd13;
    b = 8'd7;
    acc_proc = new(1);
    acc_proc.add(4);
    acc_decl.add(square(3));
    delayed_double(21, r);
    $display("t=%0t class: acc_decl.total=%0d acc_proc.total=%0d",
             $time, acc_decl.total, acc_proc.total);
    $display("subroutines: square(7)=%0d delayed_double(21)=%0d", square(7), r);
    $display("assign: sum_w=%0d", sum_w);
    $display("always_comb: comb_y=%0d", comb_y);
    #20;
    $display("t=%0t always_ff: edges=%0d", $time, edges);
    $display("generate: gen_w=%b g_if.PICK=%0d g_case.PICK=%0d", gen_w, g_if.PICK, g_case.PICK);
    $finish;
  end

  final $display("final: edges=%0d", edges);
endmodule
