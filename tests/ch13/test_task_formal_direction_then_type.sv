/*
:name: test_task_formal_direction_then_type
:description: Task formals declared first by direction and then by data type receive and return their arguments (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_formal_direction_then_type.expected
*/
// IEEE 1800-2023 §13.3: a task declared without a list in parentheses can
// declare each formal twice, first with its direction and then with its
// data type, as in "input y; logic y;". Both declarations are of the same
// formal; the second does not add a local variable, so an input receives
// the actual argument and an output is copied back to it. A formal given
// the type int by its second declaration is a signed 32-bit int.

module test_task_formal_direction_then_type;
  task scalar_in;
    input y;
    logic y;
    $display("scalar_in: y=%b", y);
  endtask

  task vector_in;
    input [7:0] n;
    reg [7:0] n;
    $display("vector_in: n=%h", n);
  endtask

  task int_out;
    output x;
    int x;
    x = -7;
  endtask

  task twice;
    output o;
    input [3:0] i;
    int o;
    logic [3:0] i;
    o = i * 2;
  endtask

  int r, r2;

  initial begin
    scalar_in(1'b1);
    vector_in(8'h42);
    int_out(r);
    twice(r2, 4'd9);
    $display("int_out gives %0d, twice(9) gives %0d", r, r2);
  end
endmodule
