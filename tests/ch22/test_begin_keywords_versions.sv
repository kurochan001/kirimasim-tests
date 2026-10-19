/*
:name: test_begin_keywords_versions
:description: between `begin_keywords and `end_keywords only the keywords of the named version are reserved, so words that later versions reserve can be identifiers, and nested pairs restore the outer version (IEEE 1800-2023 Sections 22.14, 22.14.2 to 22.14.9)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14 22.14.2 22.14.3 22.14.4 22.14.5 22.14.6 22.14.7 22.14.8 22.14.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_keywords_versions.expected
*/
// IEEE 1800-2023 §22.14: `begin_keywords "version" reserves only the keywords
// of that version until the matching `end_keywords; the pairs nest, and
// `end_keywords returns to the version in effect before. §22.14.2 to
// §22.14.9 list the keywords of each version: generate and localparam came
// with IEEE Std 1364-2001, whose noconfig variant leaves out config, cell and
// design; uwire came with 1364-2005; logic, bit and int with 1800-2005;
// global, let and until with 1800-2009; nettype and soft with 1800-2012; and
// 1800-2017 and 1800-2023 added none. Each module below uses as variable
// names words that its version does not reserve, and prints them at its own
// time; kw_2001_after follows a nested 1364-1995 pair and uses logic, which
// 1364-2001 does not reserve either.

`begin_keywords "1364-2001"
`begin_keywords "1364-1995"
module kw_1995;
  reg [3:0] generate, localparam;
  initial begin
    generate = 1;
    localparam = 2;
    #1 $display("1364-1995: generate=%0d localparam=%0d", generate, localparam);
  end
endmodule
`end_keywords
module kw_2001_after;
  reg [3:0] logic, uwire;
  initial begin
    logic = 3;
    uwire = 4;
    #2 $display("1364-2001: logic=%0d uwire=%0d", logic, uwire);
  end
endmodule
`end_keywords

`begin_keywords "1364-2001-noconfig"
module kw_noconfig;
  reg [3:0] config, cell, design;
  initial begin
    config = 5;
    cell = 6;
    design = 7;
    #3 $display("1364-2001-noconfig: config=%0d cell=%0d design=%0d", config, cell, design);
  end
endmodule
`end_keywords

`begin_keywords "1364-2005"
module kw_1364_2005;
  reg [3:0] bit, int;
  initial begin
    bit = 8;
    int = 9;
    #4 $display("1364-2005: bit=%0d int=%0d", bit, int);
  end
endmodule
`end_keywords

`begin_keywords "1800-2005"
module kw_1800_2005;
  logic [3:0] global, let, until;
  initial begin
    global = 10;
    let = 11;
    until = 12;
    #5 $display("1800-2005: global=%0d let=%0d until=%0d", global, let, until);
  end
endmodule
`end_keywords

`begin_keywords "1800-2009"
module kw_1800_2009;
  logic [3:0] nettype, soft;
  initial begin
    nettype = 13;
    soft = 14;
    #6 $display("1800-2009: nettype=%0d soft=%0d", nettype, soft);
  end
endmodule
`end_keywords

`begin_keywords "1800-2023"
module test_begin_keywords_versions;
  kw_1995 u1();
  kw_2001_after u2();
  kw_noconfig u3();
  kw_1364_2005 u4();
  kw_1800_2005 u5();
  kw_1800_2009 u6();
  initial #7 $display("1800-2023: done");
endmodule
`end_keywords
