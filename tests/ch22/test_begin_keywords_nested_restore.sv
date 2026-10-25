/*
:name: test_begin_keywords_nested_restore
:description: Nested `begin_keywords pairs are stacked, and each `end_keywords returns to the keyword set of the version in effect before its matching `begin_keywords, two levels deep (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14 22.14.2 22.14.3 22.14.5 22.14.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_keywords_nested_restore.expected
*/
// IEEE 1800-2023 §22.14: `begin_keywords pairs can be nested; each pair is
// stacked, and `end_keywords returns to the version that was in effect before
// the matching `begin_keywords. Three pairs are nested: "1800-2005", then
// "1364-2005", then "1364-1995". In the innermost one, generate and uwire are
// ordinary names (22.14.2). After its `end_keywords the set is "1364-2005"
// again: uwire is a keyword there (22.14.5), and logic is still a name, which
// it would not be if the default set of this tool applied. After the next
// `end_keywords the set is "1800-2005" again: logic is a keyword and checker,
// which 1800-2009 added, is still a name. Each module uses the words of its
// set and prints at its own time.

`begin_keywords "1800-2005"
`begin_keywords "1364-2005"
`begin_keywords "1364-1995"
module kw_inner_1995;
  reg [3:0] generate, uwire;
  initial begin
    generate = 1;
    uwire = 2;
    #1 $display("1364-1995: generate=%0d uwire=%0d", generate, uwire);
  end
endmodule
`end_keywords
module kw_back_to_1364_2005;
  uwire w;
  reg [3:0] logic;
  assign w = 1'b1;
  initial begin
    logic = 3;
    #2 $display("1364-2005: uwire w=%0d logic=%0d", w, logic);
  end
endmodule
`end_keywords
module kw_back_to_1800_2005;
  logic [3:0] checker;
  initial begin
    checker = 4;
    #3 $display("1800-2005: checker=%0d", checker);
  end
endmodule
`end_keywords

module test_begin_keywords_nested_restore;
  kw_inner_1995 u1();
  kw_back_to_1364_2005 u2();
  kw_back_to_1800_2005 u3();
endmodule
