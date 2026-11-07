/*
:name: test_time_format_matrix
:description: %t of integers and reals called from modules of time units 10ns, 1us, 1ps and 1ns, under the default format and five $timeformat calls, with %0t and a written width, from a task and a function
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 20.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: top
:expected_stdout: @test_time_format_matrix.expected
*/
// From kirimasim tests/suite/proc/time_format_matrix.sv, 2026-10-25, with other reals.
// Its expectation is checked against the clauses below.
// The clauses do not say which way %t rounds a real that is exactly halfway, and
// simulators differ on it, so no row depends on that. The source uses 2.5 and 1.75, which
// are halfway in rows such as 2.5 ps under the default format, so this copy uses 2.6 and
// 1.76, and it is no longer generated from the source.
`timescale 10ns/1ns
module m10ns;
  int n = 7;
  logic [63:0] q = 64'd7;
  real r1 = 2.6, r2 = 1.76;
  task automatic show(input string tag);
    $display("%s [%t] [%t] [%t] [%t] [%t] [%0t] [%12t]", tag, 7, n, q, r1, r2, n, n);
  endtask
  function void fshow(input string tag);
    $display("%s [%t] [%t] [%t] [%t] [%t] [%0t] [%12t]", tag, 7, n, q, r1, r2, n, n);
  endfunction
endmodule

`timescale 1us/1ns
module m1us;
  int n = 7;
  logic [63:0] q = 64'd7;
  real r1 = 2.6, r2 = 1.76;
  task automatic show(input string tag);
    $display("%s [%t] [%t] [%t] [%t] [%t] [%0t] [%12t]", tag, 7, n, q, r1, r2, n, n);
  endtask
  function void fshow(input string tag);
    $display("%s [%t] [%t] [%t] [%t] [%t] [%0t] [%12t]", tag, 7, n, q, r1, r2, n, n);
  endfunction
endmodule

`timescale 1ps/1ps
module m1ps;
  int n = 7;
  logic [63:0] q = 64'd7;
  real r1 = 2.6, r2 = 1.76;
  task automatic show(input string tag);
    $display("%s [%t] [%t] [%t] [%t] [%t] [%0t] [%12t]", tag, 7, n, q, r1, r2, n, n);
  endtask
  function void fshow(input string tag);
    $display("%s [%t] [%t] [%t] [%t] [%t] [%0t] [%12t]", tag, 7, n, q, r1, r2, n, n);
  endfunction
endmodule

`timescale 1ns/1ps
module top;
  m10ns m10ns_i();
  m1us m1us_i();
  m1ps m1ps_i();
  int n = 7;
  logic [63:0] q = 64'd7;
  real r1 = 2.6, r2 = 1.76;
  task automatic show(input string tag);
    $display("%s [%t] [%t] [%t] [%t] [%t] [%0t] [%12t]", tag, 7, n, q, r1, r2, n, n);
  endtask
  function void fshow(input string tag);
    $display("%s [%t] [%t] [%t] [%t] [%t] [%0t] [%12t]", tag, 7, n, q, r1, r2, n, n);
  endfunction
  initial begin
    m10ns_i.show("default m10ns task");
    m10ns_i.fshow("default m10ns function");
    m1us_i.show("default m1us task");
    m1us_i.fshow("default m1us function");
    m1ps_i.show("default m1ps task");
    m1ps_i.fshow("default m1ps function");
    show("default top task");
    fshow("default top function");
    $timeformat(-9, 3, " ns", 12);
    m10ns_i.show("ns3 m10ns task");
    m10ns_i.fshow("ns3 m10ns function");
    m1us_i.show("ns3 m1us task");
    m1us_i.fshow("ns3 m1us function");
    m1ps_i.show("ns3 m1ps task");
    m1ps_i.fshow("ns3 m1ps function");
    show("ns3 top task");
    fshow("ns3 top function");
    $timeformat(-15, 0, " fs", 0);
    m10ns_i.show("fs0 m10ns task");
    m10ns_i.fshow("fs0 m10ns function");
    m1us_i.show("fs0 m1us task");
    m1us_i.fshow("fs0 m1us function");
    m1ps_i.show("fs0 m1ps task");
    m1ps_i.fshow("fs0 m1ps function");
    show("fs0 top task");
    fshow("fs0 top function");
    $timeformat(-6, 4, "us", 0);
    m10ns_i.show("us4 m10ns task");
    m10ns_i.fshow("us4 m10ns function");
    m1us_i.show("us4 m1us task");
    m1us_i.fshow("us4 m1us function");
    m1ps_i.show("us4 m1ps task");
    m1ps_i.fshow("us4 m1ps function");
    show("us4 top task");
    fshow("us4 top function");
    $timeformat(-12, 1, "", 6);
    m10ns_i.show("ps1 m10ns task");
    m10ns_i.fshow("ps1 m10ns function");
    m1us_i.show("ps1 m1us task");
    m1us_i.fshow("ps1 m1us function");
    m1ps_i.show("ps1 m1ps task");
    m1ps_i.fshow("ps1 m1ps function");
    show("ps1 top task");
    fshow("ps1 top function");
    $timeformat(-8, 2, " x10ns", 15);
    m10ns_i.show("x10ns2 m10ns task");
    m10ns_i.fshow("x10ns2 m10ns function");
    m1us_i.show("x10ns2 m1us task");
    m1us_i.fshow("x10ns2 m1us function");
    m1ps_i.show("x10ns2 m1ps task");
    m1ps_i.fshow("x10ns2 m1ps function");
    show("x10ns2 top task");
    fshow("x10ns2 top function");
  end
endmodule
