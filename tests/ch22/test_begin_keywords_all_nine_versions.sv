/*
:name: test_begin_keywords_all_nine_versions
:description: `begin_keywords accepts each of the nine standard version specifiers, 1364-1995, 1364-2001, 1364-2001-noconfig, 1364-2005, 1800-2005, 1800-2009, 1800-2012, 1800-2017 and 1800-2023, and each one reserves the keywords of its version, so words added by later versions are ordinary names under the earlier ones (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14 22.14.2 22.14.3 22.14.4 22.14.5 22.14.6 22.14.7 22.14.8 22.14.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_keywords_all_nine_versions.expected
*/
// IEEE 1800-2023 §22.14: the version specifier of `begin_keywords is one of
// 1800-2023, 1800-2017, 1800-2012, 1800-2009, 1800-2005, 1364-2005, 1364-2001,
// 1364-2001-noconfig and 1364-1995, and an unknown one is an error. Each
// version reserves its own keywords (22.14.2 to 22.14.9): one module per
// version uses a keyword that the version added, and as names words that only
// later versions reserve: localparam came with 1364-2001, whose noconfig form
// does not reserve config, cell, design or library; uwire with 1364-2005;
// logic with 1800-2005; unique0 with 1800-2009; nettype, soft, implements and
// interconnect with 1800-2012; 1800-2017 and 1800-2023 add none, so their
// modules use the keywords of the earlier versions. Each module prints at its
// own time. Icarus Verilog 13.0 warns that it does not know the specifiers
// 1800-2017 and 1800-2023 and ignores them instead of reporting an error; its
// default keywords give the same output here.

`begin_keywords "1364-1995"
module kw_v1995;
  reg [3:0] generate, localparam, uwire, logic;
  initial begin
    generate = 1; localparam = 2; uwire = 3; logic = 4;
    #1 $display("1364-1995: %0d %0d %0d %0d", generate, localparam, uwire, logic);
  end
endmodule
`end_keywords

`begin_keywords "1364-2001"
module kw_v2001;
  localparam [3:0] LP = 5;
  reg [3:0] uwire, logic;
  initial begin
    uwire = 6; logic = 7;
    #2 $display("1364-2001: LP=%0d %0d %0d", LP, uwire, logic);
  end
endmodule
`end_keywords

`begin_keywords "1364-2001-noconfig"
module kw_v2001_noconfig;
  localparam [3:0] LP = 8;
  reg [3:0] config, cell, design, library;
  initial begin
    config = 9; cell = 10; design = 11; library = 12;
    #3 $display("1364-2001-noconfig: LP=%0d %0d %0d %0d %0d", LP, config, cell, design, library);
  end
endmodule
`end_keywords

`begin_keywords "1364-2005"
module kw_v1364_2005;
  uwire u;
  reg [3:0] logic, bit;
  assign u = 1'b1;
  initial begin
    logic = 13; bit = 14;
    #4 $display("1364-2005: u=%0d %0d %0d", u, logic, bit);
  end
endmodule
`end_keywords

`begin_keywords "1800-2005"
module kw_v1800_2005;
  logic [3:0] checker, until, global;
  initial begin
    checker = 1; until = 2; global = 3;
    #5 $display("1800-2005: %0d %0d %0d", checker, until, global);
  end
endmodule
`end_keywords

`begin_keywords "1800-2009"
module kw_v1800_2009;
  logic [3:0] nettype, soft, implements, interconnect;
  int r;
  initial begin
    nettype = 4; soft = 5; implements = 6; interconnect = 7;
    unique0 case (nettype)
      4'd4: r = 40;
      4'd5: r = 50;
    endcase
    #6 $display("1800-2009: r=%0d %0d %0d %0d %0d", r, nettype, soft, implements, interconnect);
  end
endmodule
`end_keywords

`begin_keywords "1800-2012"
module kw_v1800_2012;
  logic [3:0] v = 4'd1;
  int r;
  initial begin
    unique0 case (v)
      4'd1: r = 12;
      4'd2: r = 0;
    endcase
    #7 $display("1800-2012: r=%0d", r);
  end
endmodule
`end_keywords

`begin_keywords "1800-2017"
module kw_v1800_2017;
  logic [3:0] v = 4'd2;
  int r;
  initial begin
    unique0 case (v)
      4'd1: r = 0;
      4'd2: r = 17;
    endcase
    #8 $display("1800-2017: r=%0d", r);
  end
endmodule
`end_keywords

`begin_keywords "1800-2023"
module test_begin_keywords_all_nine_versions;
  logic [3:0] v = 4'd3;
  int r;
  kw_v1995 u1();
  kw_v2001 u2();
  kw_v2001_noconfig u3();
  kw_v1364_2005 u4();
  kw_v1800_2005 u5();
  kw_v1800_2009 u6();
  kw_v1800_2012 u7();
  kw_v1800_2017 u8();
  initial begin
    unique0 case (v)
      4'd3: r = 23;
      4'd4: r = 0;
    endcase
    #9 $display("1800-2023: r=%0d", r);
  end
endmodule
`end_keywords
