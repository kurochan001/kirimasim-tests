/*
:name: test_vpi_object_access_basics
:description: A net found by its hierarchical name from the top gives its module through vpiModule, a module iterates its nets and child instances, vpi_iterate(vpiModule, NULL) gives both top modules, Boolean properties are 1 or 0, the time unit and precision of a NULL handle are the global precision, and scopes and calls give their source lines (IEEE 1800-2023 Sections 37.3.1 and 37.5)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.1 37.5 37.3.3 37.10 38.6 38.11 3.14.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_object_access_basics.c
:expected_stdout: @test_vpi_object_access_basics.expected
*/
// IEEE 1800-2023 §37.3.1: vpi_handle_by_name with a NULL scope finds
// test_vpi_object_access_basics.ua.s1 from the top of the design, vpi_handle
// follows the one-to-one relation vpiModule from it to the instance ua, whose
// vpiFullName names it, and vpi_iterate with vpi_scan walks the nets of ua.
// vpi_get returns Boolean properties as 1 for TRUE and 0 for FALSE (38.6).
// §37.5: the design has two top modules, which vpi_iterate(vpiModule, NULL)
// returns (detail 1), and vpiTopModule is true only for them; a module
// iterates its child instances. §37.10 detail 7, §38.6: vpiTimeUnit and
// vpiTimePrecision of a NULL handle give the global time precision (§3.14.3),
// here 10 ps from the second top module; each module has its own. §37.3.3: the
// instance ub, the task, the function, the named block and the call of
// $vt_access give the line of their declaration or statement; each is written
// on a single line. vpi_get_str reuses its buffer (38.11), so each string is
// printed before the next call. Lists are sorted.

`timescale 1ns/1ns

module test_vpi_object_access_basics_leaf(input wire a, output wire y);
  assign y = ~a;
endmodule

module test_vpi_object_access_basics_mid(input wire a, output wire y);
  wire s1, s2;
  assign s1 = a;
  assign s2 = ~s1;
  test_vpi_object_access_basics_leaf lf(s2, y);
endmodule

module test_vpi_object_access_basics;
  logic a = 1'b0;
  int count = -1;
  logic [3:0] vec = 4'h9;
  wire y1, y2;

  test_vpi_object_access_basics_mid ua(a, y1);
  test_vpi_object_access_basics_mid ub(vec[0], y2);

  task tk; count = count + 2; endtask
  function int fn(input int x); return x + 1; endfunction

  initial begin : blk count = fn(count); tk; #1 $vt_access; end
endmodule

`timescale 1us/10ps

module test_vpi_object_access_basics_other;
  int z = 1;

  initial #1 z = 2;
endmodule
