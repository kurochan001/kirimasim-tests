/*
:name: test_always_comb_vs_always_star
:description: always_comb runs at time zero and is sensitive to variables read in called functions, unlike always @* (IEEE 1800-2023 Section 9.2.2.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.2 9.2.2.2.1 9.4.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_always_comb_vs_always_star.expected
*/
// IEEE 1800-2023 §9.2.2.2.2: always_comb runs once at time zero, while
// always @* waits for a change of something in its inferred sensitivity list.
// always_comb is also sensitive to variables read inside a function it calls
// (9.2.2.2.1), while always @* is sensitive only to the arguments of the call.
// g and k get their initial values before any procedure starts, so always @*
// does not run at time zero and its output stays x until k changes. Verilator
// 5.052 runs always @* at time zero and wakes it when g changes.

module test_always_comb_vs_always_star;
  logic [7:0] g = 8'd5;      // read only inside the function
  logic [7:0] k = 8'd1;      // passed as the argument
  logic [7:0] y_comb, y_star;

  function automatic logic [7:0] f(logic [7:0] arg);
    return arg + g;
  endfunction

  always_comb y_comb = f(k);
  always @* y_star = f(k);

  initial begin
    #1 $display("t1 y_comb=%0d y_star=%0d", y_comb, y_star);
    k = 8'd2;
    #1 $display("t2 y_comb=%0d y_star=%0d", y_comb, y_star);
    g = 8'd10;
    #1 $display("t3 y_comb=%0d y_star=%0d", y_comb, y_star);
    k = 8'd3;
    #1 $display("t4 y_comb=%0d y_star=%0d", y_comb, y_star);
  end
endmodule
