/*
:name: test_always_comb_time_zero
:description: always_comb runs once at time zero after all initial and always procedures have started, while always @* waits for a change (IEEE 1800-2023 9.2.2.2, 9.2.2.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 9.2.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_time_zero.expected
*/
// IEEE 1800-2023 §9.2.2.2: an always_comb procedure is triggered once at time
// zero, after all initial and always procedures have been started, so its
// output matches its inputs without waiting for a change. §9.2.2.2.2: an
// always @* waits until a change on a signal in its inferred sensitivity list.
// The test gives a the initial value 1 and computes y in always_comb and z in
// always @* from a. At 1 ns y is 1 although a never changed after time zero,
// while z is still its 2-state default 0; after a becomes 0 both follow. If
// always_comb did not run at time zero, y would print 0 at 1 ns. Verilator
// 5.052 also runs another always @* at time zero, so its expected output
// follows the clauses and lists Icarus Verilog 13.0 only.

module test_always_comb_time_zero;
  bit a = 1'b1;
  bit y;
  bit z;

  always_comb y = a;
  always @* z = a;

  initial begin
    #1 $display("t1 y=%0d z=%0d", y, z);
    a = 1'b0;
    #1 $display("t2 y=%0d z=%0d", y, z);
    $finish;
  end
endmodule
