/*
:name: test_monitor_new_call_replaces_list
:description: only one $monitor list is active at a time and each new $monitor, $monitorb, $monitoro or $monitorh call replaces it; the variants show arguments without a format in their own radix, $monitoroff stops monitoring and $monitoron resumes it with a print even when nothing changed (IEEE 1800-2023 Section 21.2.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.3 21.2.1.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_monitor_new_call_replaces_list.expected
*/
// IEEE 1800-2023 §21.2.3: only one $monitor display list can be active at a
// time, and a new $monitor call with a new list may be made any number of
// times. $monitor, $monitorb, $monitoro and $monitorh take arguments like
// $display, so an argument without a format is shown in decimal, binary,
// octal or hexadecimal (§21.2.1.1). $monitoroff turns monitoring off and
// $monitoron turns it on again for the latest list, printing it right away
// whether or not a value changed.
// Each new call is made in a time step that also changes one of its
// arguments, so its first line does not depend on whether a call prints at
// once. After the second call, changes of a, which only the first list
// holds, print nothing; after the third and fourth calls only changes of
// the arguments of the latest list print. While monitoring is off (times 9
// and 10) changes of b print nothing. $monitoron at time 11 prints the list;
// the second $monitoroff at time 13 is followed by no change at all, so the
// print of $monitoron at time 14 can only come from the call itself.
// Release 5.052 of Verilator prints nothing when $monitoron is called.

module test_monitor_new_call_replaces_list;
  logic [7:0] a = 8'd0;
  logic [7:0] b = 8'd0;

  initial begin
    $monitor("A\ta=%0d", a);
    a = 8'd1;
    #1 a = 8'd2;
    #1 $monitorb("B b=", b);
    b = 8'd5;
    #1 a = 8'd3;
    #1 b = 8'd6;
    #1 $monitoro("O b=", b, " a=%0d", a);
    b = 8'd9;
    #1 a = 8'd4;
    #1 $monitorh("H b=", b);
    b = 8'd200;
    #1 a = 8'd5;
    #1 $monitoroff;
    b = 8'd201;
    #1 b = 8'd202;
    #1 $monitoron;
    #1 b = 8'd171;
    #1 $monitoroff;
    #1 $monitoron;
    #1 a = 8'd6;
    #1 b = 8'd255;
  end
endmodule
