/*
:name: test_cycle_delay_forms_and_zero_drive_delay
:description: A cycle delay can be written with an integral number, an identifier or a parenthesized expression, before a statement or a null statement, and waits that many clocking block events; ##0 on the right-hand side of a synchronous drive has no effect (IEEE 1800-2023 Section 14.11)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.11 14.12 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cycle_delay_forms_and_zero_drive_delay.expected
*/
// IEEE 1800-2023 §14.11: a cycle delay is ## followed by an integral number,
// an identifier or a parenthesized expression, and it is a timing control
// in front of a statement or a null statement; it waits for that many
// clocking block events of the default clocking (14.12). A ##0 on the
// right-hand side of a synchronous drive has no effect, as if it were not
// there.
//
// The posedges are at 5, 15, 25, ... From the clocking event at 5, ##2;
// ends at 25, ##N with the parameter N = 1 runs its statement at 35, and
// ##(N + 1); ends at 55. At 55, the clocking event, cb.a <= ##0 1 and
// cb.b <= 1 both drive at 55 (zero output skew). At 58, between events,
// cb.a <= ##0 0 and cb.b <= 0 both wait for the next event and drive at
// 65: a and b change together each time, as for two drives without ##0.

`timescale 1ns/1ns

module test_cycle_delay_forms_and_zero_drive_delay;
  logic clk = 0;
  logic a = 0, b = 0;
  localparam int N = 1;
  int t_stmt = -1;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    output a, b;
  endclocking

  initial begin
    @(cb);
    $display("t=%0t start", $time);
    ##2;
    $display("t=%0t after ##2;", $time);
    ##N t_stmt = $time;
    $display("t=%0t after ##N with N=%0d, statement ran at %0d", $time, N, t_stmt);
    ##(N + 1);
    $display("t=%0t after ##(N + 1);", $time);
    cb.a <= ##0 1'b1;
    cb.b <= 1'b1;
    #1 $display("t=%0t a=%b b=%b", $time, a, b);
    #2;
    cb.a <= ##0 1'b0;
    cb.b <= 1'b0;
    #1 $display("t=%0t a=%b b=%b", $time, a, b);
    #7 $display("t=%0t a=%b b=%b", $time, a, b);
    $finish;
  end
endmodule
