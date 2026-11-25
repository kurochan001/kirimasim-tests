/*
:name: test_angle_include_search_uses_only_standard_files
:description: Quoted and angle includes of the same relative path select different search locations
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: include_search_top
:expected_stdout: quoted=11 standard=37
:files: angle_include_search/working/markers/search_value.svh angle_include_search/user/markers/search_value.svh angle_include_search/standard/markers/search_value.svh
*/

`include "markers/search_value.svh"
module include_search_top;
  localparam int QUOTED_VALUE = `INCLUDE_SEARCH_VALUE;
  `undef INCLUDE_SEARCH_VALUE

  `include <markers/search_value.svh>
  localparam int STANDARD_VALUE = `INCLUDE_SEARCH_VALUE;
  `undef INCLUDE_SEARCH_VALUE

  initial $display("quoted=%0d standard=%0d", QUOTED_VALUE, STANDARD_VALUE);
endmodule
