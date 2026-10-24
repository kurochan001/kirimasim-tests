/*
:name: test_begin_keywords_1995_keeps_language_features
:description: Under `begin_keywords "1364-1995" only the set of reserved words changes: later keywords such as logic, bit and int are ordinary names, while the operators, literals, casts and system tasks and functions of SystemVerilog keep working (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14 22.14.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_keywords_1995_keeps_language_features.expected
*/
// IEEE 1800-2023 §22.14: `begin_keywords and `end_keywords only specify the
// set of identifiers that are reserved as keywords; they do not affect the
// semantics, the tokens or other aspects of the language. Under the keywords
// of IEEE Std 1364-1995 (22.14.2), which do not include logic, bit or int,
// the module kw1995_features names three variables logic, bit and int. The
// same module then uses tokens and features that IEEE Std 1364-1995 does not
// have and that are not keywords: the increment operator ++, the assignment
// operator -=, the unbased unsized literal '1, the size cast 8'(...),
// variable initializers in declarations, the event control @*, the system
// functions $bits and $clog2, and the system task $sformat. Their results
// are those of the current standard: logic = 3 then 4 after ++,
// bit = 8'hff - 15 = 240, int = 8'(4 * 70) = 280 truncated to 8 bits = 24,
// mirror follows int through @*, $bits(int) + $clog2(256) = 8 + 8 = 16, and
// $sformat formats logic into the three characters <4>. The assignments are
// made at time 1, when the always block already waits at its @*, and the
// module prints them at time 2, where logic, bit and int are still names.
// Under these keywords Verilator 5.052 does not take the tokens ++ and -=
// and stops with a syntax error.

`begin_keywords "1364-1995"
module kw1995_features;
  reg [7:0] logic = 8'd3;
  reg [7:0] bit;
  reg [7:0] int;
  reg [7:0] mirror;
  integer sum;
  reg [3*8:1] text;

  always @* mirror = int;

  initial begin
    #1;
    logic++;
    bit = '1;
    bit -= 8'd15;
    int = 8'(logic * 70);
    sum = $bits(int) + $clog2(256);
    $sformat(text, "<%0d>", logic);
    #1;
    $display("logic=%0d bit=%0d int=%0d mirror=%0d", logic, bit, int, mirror);
    $display("sum=%0d text=%0s", sum, text);
  end
endmodule
`end_keywords

module test_begin_keywords_1995_keeps_language_features;
  kw1995_features u();
endmodule
