/*
:name: test_constant_primary_selectors_on_expressions_and_calls
:description: Constant selectors apply to a package parameter and to concatenation, replication and function results
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.11 A.8.4 11.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_primary_selectors_on_expressions_and_calls.expected
*/
package selector_constants;
  parameter bit [15:0] PATTERN = 16'h5ca7;
  typedef enum bit [1:0] {SMALL=1, LARGE=3} size_t;

  function automatic bit [23:0] stable_packet(input bit [7:0] data);
    return {8'he1, (data ^ 8'h42), 8'h0b};
  endfunction

  let field_value(bit [7:0] value) = value[5:2];
endpackage

module test_constant_primary_selectors_on_expressions_and_calls;
  import selector_constants::*;
  localparam bit [3:0] PARAM_NIBBLE = selector_constants::PATTERN[11:8];
  localparam bit [7:0] CONCAT_PIECE = {8'h9e, 8'h73}[11:4];
  localparam bit [7:0] REPEAT_PIECE = {3{8'ha6}}[18:11];
  localparam bit [7:0] CALL_PIECE = selector_constants::stable_packet(8'hd3)[15:8];
  localparam bit [3:0] LET_PIECE = field_value(8'h6c);
  localparam size_t ENUM_VALUE = selector_constants::LARGE;

  initial begin
    $display("param=%h concat=%h repeat=%h call=%h let=%h enum=%0d",
             PARAM_NIBBLE, CONCAT_PIECE, REPEAT_PIECE, CALL_PIECE, LET_PIECE, ENUM_VALUE);
    $finish(0);
  end
endmodule
