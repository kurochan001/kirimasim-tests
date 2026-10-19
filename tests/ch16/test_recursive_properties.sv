/*
:name: test_recursive_properties
:description: a recursive property instantiates itself after a positive advance in time; it can express a weak until, and with a local variable formal argument whose actual is computed from the formal it can count ticks (IEEE 1800-2023 Sections 16.12.17, 16.12.19)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.17 16.12.19 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recursive_properties.expected
*/
// IEEE 1800-2023 §16.12.17: a property may instantiate itself, after a
// positive advance in time such as 1'b1 |=>. hold_until(p, q) is q or (p and
// (1'b1 |=> hold_until(p, q))): p must hold at every tick until, not
// including, the first tick where q holds. hold_for(n, p) is (n == 0) or (p
// and (1'b1 |=> hold_for(n - 1, p))): p must hold for n ticks; the actual
// n - 1 uses the formal n, which is allowed because n is a local variable
// formal argument (restriction 4, §16.12.19); p, which follows it, is
// declared untyped so that it is not one too. Each assertion starts at the
// tick with go (§16.12.7), and the fail actions count the failures of each
// phase (§16.14.1). A phase has the ticks T to T+5; each line shows busy and
// done at them. In the last phase done never comes and busy holds to the
// end, so the weak until has not failed.

`timescale 1ns/1ns

module test_recursive_properties;
  logic clk = 0, go = 0, busy = 0, done = 0;
  int f_until = 0, f_for = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  property hold_until(p, q);
    q or (p and (1'b1 |=> hold_until(p, q)));
  endproperty

  property hold_for(local input int n, untyped p);
    (n == 0) or (p and (1'b1 |=> hold_for(n - 1, p)));
  endproperty

  a_until: assert property (@(posedge clk) go |-> hold_until(busy, done)) else f_until++;
  a_for: assert property (@(posedge clk) go |-> hold_for(3, busy)) else f_for++;

  // Runs one phase of 6 ticks; go is high at the first.
  task automatic phase(logic [5:0] bs, logic [5:0] ds);
    for (int i = 0; i < 6; i++) begin
      go = (i == 0);
      busy = bs[5 - i];
      done = ds[5 - i];
      #10;
    end
    $display("busy %b, done %b: hold_until %0d, hold_for(3) %0d", bs, ds, f_until, f_for);
    f_until = 0;
    f_for = 0;
  endtask

  initial begin
    phase(6'b111000, 6'b000100);
    phase(6'b110000, 6'b000100);
    phase(6'b000000, 6'b100000);
    phase(6'b111111, 6'b000000);
    $finish;
  end
endmodule
