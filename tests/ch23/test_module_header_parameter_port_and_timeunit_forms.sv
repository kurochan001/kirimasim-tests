/*
:name: test_module_header_parameter_port_and_timeunit_forms
:description: A module header accepts every form of the parameter port list, including an explicitly empty one, and every form of the timeunits declaration, which sets the delay unit of the module (IEEE 1800-2023 Section 23.2.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_header_parameter_port_and_timeunit_forms.expected
*/
// IEEE 1800-2023 §23.2.1: the parameter port list has the forms #( list
// of parameter assignments, then parameter port declarations ), #(
// parameter port declarations ) and the explicitly empty #(). A parameter
// port declaration is a parameter or localparam declaration, a typed list
// of parameter assignments, or a type parameter declaration. The timeunits
// declaration has the forms timeunit with an optional slash and precision,
// or timeunit and timeprecision as separate declarations in either order.
// The module hdr_pt_params uses the first parameter port form with one bare
// assignment W = 4, then a parameter declaration D, a localparam L, a typed
// assignment list M, a ranged parameter C and a type parameter T; T is the
// type of the input port i, so a tool that does not make it a type cannot
// declare that port, and the task reads $bits(T). The module hdr_pt_decls
// uses the second parameter port form, whose list starts with a parameter
// declaration rather than with a bare assignment. The module hdr_pt_empty
// is instantiated with the explicit empty #(). Each time module declares
// its time unit in a different form and delays by one time unit; the top
// module prints the absolute simulation time in picoseconds at which each
// module reaches its delay, so the unit each declaration sets is visible.
// `timescale 1ps/1ps gives the module that omits the precision,
// hdr_pt_tu_noprec, the precision 1ps (3.14.2.3). The delays are 1 unit of
// 100ps, 1ns, 2ns and 3ns: they end at 100, 1000, 2000 and 3000 ps.

`timescale 1ps/1ps

module hdr_pt_params
  #(W = 4,
    parameter int D = 2,
    localparam int L = 3,
    logic [3:0] M = 4'h9,
    parameter [7:0] C = 8'h5a,
    type T = logic [7:0])
   (input T i, output [W-1:0] o);
  assign o = i[W-1:0];
  task show;
    $display("params W=%0d D=%0d L=%0d M=%0d C=%0h bitsT=%0d", W, D, L, M, C, $bits(T));
  endtask
endmodule

module hdr_pt_decls
  #(parameter int D = 2,
    localparam int L = 3,
    type T = logic [7:0]) ();
  task show;
    $display("decls D=%0d L=%0d bitsT=%0d", D, L, $bits(T));
  endtask
endmodule

module hdr_pt_empty;
  task show;
    $display("empty instantiated");
  endtask
endmodule

module hdr_pt_tu_slash;
  timeunit 1ns / 1ps;
  bit done;
  initial begin
    #1 done = 1;
  end
endmodule

module hdr_pt_tu_separate;
  timeunit 1ns;
  timeprecision 1ps;
  bit done;
  initial begin
    #2 done = 1;
  end
endmodule

module hdr_pt_tu_reversed;
  timeprecision 1ps;
  timeunit 1ns;
  bit done;
  initial begin
    #3 done = 1;
  end
endmodule

module hdr_pt_tu_noprec;
  timeunit 100ps;
  bit done;
  initial begin
    #1 done = 1;
  end
endmodule

module test_module_header_parameter_port_and_timeunit_forms;
  timeunit 1ps;
  timeprecision 1ps;

  logic [7:0] i = 8'ha7;
  logic [3:0] o;
  hdr_pt_params u_params(i, o);
  hdr_pt_decls u_decls();
  hdr_pt_empty #() u_empty();
  hdr_pt_tu_slash u_slash();
  hdr_pt_tu_separate u_separate();
  hdr_pt_tu_reversed u_reversed();
  hdr_pt_tu_noprec u_noprec();

  initial begin
    u_empty.show();
    u_decls.show();
    u_params.show();
    #1 $display("port bits=%0d value=%0h", $bits(u_params.i), o);
    wait (u_noprec.done);
    $display("time 100ps unit at %0d", $time);
    wait (u_slash.done);
    $display("time slash form at %0d", $time);
    wait (u_separate.done);
    $display("time separate form at %0d", $time);
    wait (u_reversed.done);
    $display("time reversed form at %0d", $time);
  end
endmodule
