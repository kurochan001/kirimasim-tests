/*
:name: test_22_extra_noconfig_excluded
:description: Under `begin_keywords "1364-2001-noconfig" the ten configuration words, among them endconfig, incdir, include, instance, liblist and use, are not reserved and can be identifiers (IEEE 1800-2023 Section 22.14.4)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14.4 22.14
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_22_extra_noconfig_excluded.expected
*/
// IEEE 1800-2023 §22.14.4: the version specifier "1364-2001-noconfig" behaves
// like "1364-2001" except that cell, config, design, endconfig, incdir,
// include, instance, liblist, library and use are excluded from the reserved
// list of Table 22-2. This module declares six of them as variables and uses
// them, which is legal only because they are not reserved in this region.
// Outside the region they are reserved again in the 1364-2001 and 1800-2005
// sets, so the declarations are inside a `begin_keywords region.

`begin_keywords "1364-2001-noconfig"
module test_22_extra_noconfig_excluded;
  reg [3:0] endconfig, incdir, include, instance, liblist, use;

  initial begin
    endconfig = 1;
    incdir = 2;
    include = 3;
    instance = 4;
    liblist = 5;
    use = 6;
    $display("endconfig=%0d incdir=%0d include=%0d instance=%0d liblist=%0d use=%0d",
             endconfig, incdir, include, instance, liblist, use);
  end
endmodule
`end_keywords
