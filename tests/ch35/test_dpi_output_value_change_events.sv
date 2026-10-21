/*
:name: test_dpi_output_value_change_events
:description: An output or inout argument of an imported function is assigned to its actual when the function returns, so a part-select or array element actual changes and wakes the processes waiting on it, while an inout written back with its old value causes no value change and wakes nothing (IEEE 1800-2023 Section 35.6.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.6.2 35.6.1 H.6.4 9.4.2 10.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_output_value_change_events.c
:expected_stdout: @test_dpi_output_value_change_events.expected
*/
// IEEE 1800-2023 §35.6.2, H.6.4: the simulator handles the value changes of
// output and inout arguments after the imported function returns, as if the
// formal were assigned to the actual right then. The actual can be any
// variable lvalue: c_byte writes the upper byte of word through a
// part-select, and c_set an element of an array; each change wakes the event
// control on that variable (9.4.2) and updates the continuous assignment
// that reads word (10.3). c_keep writes its inout back unchanged: assigning a
// variable its own value is no value change, so the process waiting on k does
// not wake, but c_negate changes k and wakes it. Each line is printed one
// time unit after the call it reports; wakes at time 0 are not counted.

`timescale 1ns/1ns

module test_dpi_output_value_change_events;
  import "DPI-C" function void c_byte(output bit [7:0] b);
  import "DPI-C" function void c_set(output int v, input int value);
  import "DPI-C" function void c_keep(inout int v);
  import "DPI-C" function void c_negate(inout int v);

  bit [15:0] word = 16'h0011;
  int arr[3];
  int k = 7;
  int word_wakes, arr_wakes, k_wakes;
  wire [15:0] copy = word;

  always @(word) if ($time > 0) word_wakes++;
  always @(arr[1]) if ($time > 0) arr_wakes++;
  always @(k) if ($time > 0) k_wakes++;

  initial begin
    #1 c_byte(word[15:8]);
    #1 $display("part-select: word %h, its copy %h, woke %0d time(s)", word, copy, word_wakes);
    c_set(arr[1], 12);
    #1 $display("array element: arr[1] %0d, woke %0d time(s)", arr[1], arr_wakes);
    c_keep(k);
    #1 $display("same value: k %0d, woke %0d time(s)", k, k_wakes);
    c_negate(k);
    #1 $display("new value: k %0d, woke %0d time(s)", k, k_wakes);
  end
endmodule
