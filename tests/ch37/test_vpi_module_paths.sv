/*
:name: test_vpi_module_paths
:description: a module gives its module paths, each with its input and output path terms, full or parallel connection, polarity, condition, ifnone flag and delays (IEEE 1800-2023 Section 37.39)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.39 38.10 30.4.2 30.4.4.1 30.4.4.4 30.4.7 30.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_paths.c
:expected_stdout: @test_vpi_module_paths.expected
*/
// IEEE 1800-2023 §37.39: vpi_iterate(vpiModPath, module) gives the module
// paths of the module's specify block; vpiModPathIn and vpiModPathOut give
// their path terms, each with the terminal as its expression; vpiPathType
// tells a full (*>) from a parallel (=>) connection (§30.4.2); vpiPolarity
// is the + or - polarity, or unknown without one (§30.4.7); vpiCondition is
// the condition of a state-dependent path (§30.4.4.1); vpiModPathHasIfNone is
// true for an ifnone path (§30.4.4.4); vpi_get_delays returns its rise and
// fall delays (§38.10, §30.5.1). The application prints one line per path,
// sorted.

module paths(input a, b, en, output y, z, w);
  assign y = a;
  assign z = ~b;
  assign w = a;
  specify
    (a *> y) = (3, 5);
    (b -=> z) = (2, 4);
    if (en) (a +=> w) = (1, 6);
    ifnone (a => w) = (7, 8);
  endspecify
endmodule

module test_vpi_module_paths;
  logic a = 0, b = 0, en = 1;
  wire y, z, w;

  paths u(a, b, en, y, z, w);

  initial #1 $vt_paths;
endmodule
