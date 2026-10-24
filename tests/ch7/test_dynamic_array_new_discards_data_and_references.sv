/*
:name: test_dynamic_array_new_discards_data_and_references
:description: resizing or reinitializing a dynamic array with new[] discards its data unless the old array is given as the initializer, and in every case outdates references to its elements (IEEE 1800-2023 Section 7.5.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_new_discards_data_and_references.expected
*/
// IEEE 1800-2023 §7.5.1: new[] on a dynamic array that already has elements is
// destructive: no old data is kept unless the array is also given as the
// initializer, and all existing references to its elements become outdated.
// §13.5.2: an outdated element still exists for the task that holds a
// reference to it, but the task's writes to it no longer reach the array.
// new[3] on an array that already has three elements still gives three
// default elements. new[4](d) keeps the old values and pads with the default.
// The task hold gets a reference to d[1] and writes 99 through it at time 3,
// after d = new[3](d) at time 1 has outdated the reference while keeping the
// same values, so d still reads 5 6 7 and only the task sees 99.
// Icarus Verilog 13.0 does not support ref arguments. In Verilator 5.052 the
// write through the outdated reference reaches the new array (5 99 7).

`timescale 1ns/1ns

module test_dynamic_array_new_discards_data_and_references;
  int d[];

  task automatic hold(ref int r);
    #3 r = 99;
    $display("holder at %0t: r=%0d", $time, r);
  endtask

  initial begin
    d = '{1, 2, 3};
    d = new[3];
    $display("new[3] on 3 elements: %0d %0d %0d", d[0], d[1], d[2]);
    d = '{1, 2, 3};
    d = new[4](d);
    $display("new[4](d): %0d %0d %0d %0d", d[0], d[1], d[2], d[3]);
    d = '{5, 6, 7};
    fork
      hold(d[1]);
    join_none
    #1 d = new[3](d);
    $display("t=%0t after new[3](d): %0d %0d %0d", $time, d[0], d[1], d[2]);
    #3 $display("t=%0t: %0d %0d %0d", $time, d[0], d[1], d[2]);
  end
endmodule
