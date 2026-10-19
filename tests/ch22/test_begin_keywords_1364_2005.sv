/*
:name: test_begin_keywords_1364_2005
:description: Inside `begin_keywords "1364-2005", SystemVerilog keywords such as logic and bit can be used as identifiers (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14 22.14.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_keywords_1364_2005.expected
*/
// IEEE 1800-2023 §22.14: between `begin_keywords "version" and `end_keywords,
// only the keywords of that version are reserved. logic, bit and int are not
// keywords of IEEE Std 1364-2005 (22.14.5), so a module in such a region can
// name its variables logic, bit and int. The module that follows `end_keywords
// is back to the keywords of the current version.

`begin_keywords "1364-2005"
module begin_keywords_old_names(output reg [7:0] total);
  reg [3:0] logic;
  reg [3:0] bit;
  integer int;
  initial begin
    logic = 4'd3;
    bit = 4'd4;
    int = 5;
    total = logic + bit + int;
  end
endmodule
`end_keywords

module test_begin_keywords_1364_2005;
  logic [7:0] total;
  begin_keywords_old_names u(.total(total));

  initial #1 $display("total=%0d", total);
endmodule
