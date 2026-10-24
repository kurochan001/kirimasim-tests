// Included by test_illegal_include_line_trailing_code. The guard makes the
// second inclusion add nothing, so it cannot redeclare the localparam.
`ifndef INCLUDE_LINE_TRAILING_CODE_SVH
`define INCLUDE_LINE_TRAILING_CODE_SVH
localparam int INCLUDE_LINE_TRAILING_A = 3;
`endif
