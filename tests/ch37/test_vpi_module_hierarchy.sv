/*
:name: test_vpi_module_hierarchy
:description: VPI walks the instance hierarchy: a module handle gives its nets, variables and child instances with their full and definition names, and vpi_handle_by_name finds an object and its module (IEEE 1800-2023 Section 37.10)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 37.16 37.17 38.23 38.11 38.21 38.18
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_hierarchy.c
:expected_stdout: @test_vpi_module_hierarchy.expected
*/
// IEEE 1800-2023 §37.10, §37.16, §37.17: a module instance has iterations to
// its nets (vpiNet), its reg variables (vpiReg) and the instances in it
// (vpiModule), and each object has vpiName, vpiFullName and vpiSize; an
// instance also has vpiDefName, the name of its module (38.11). The order of
// vpi_scan is not relied on: the application sorts each list by name. Ports
// declared as input wire and output wire are nets. vpi_handle_by_name (38.21)
// finds an object by its full name, and vpi_handle(vpiModule) gives the
// instance that contains it (38.18).

module vpi_leaf(input wire a, output wire y);
  wire n;
  reg [3:0] r;
  initial r = 4'h9;
  assign n = ~a;
  assign y = n;
endmodule

module vpi_mid(input wire a, output wire y);
  vpi_leaf l1(a, y);
endmodule

module test_vpi_module_hierarchy;
  reg a;
  wire y1, y2;

  vpi_leaf u1(a, y1);
  vpi_mid m(a, y2);

  initial begin
    $vt_walk(test_vpi_module_hierarchy);
    $vt_lookup("test_vpi_module_hierarchy.m.l1.r");
  end
endmodule
