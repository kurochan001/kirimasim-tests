/*
:name: test_A_extra_concat_replication
:description: A concatenation is braces around a nonempty comma-separated expression list, and a multiple concatenation is braces around a multiplier expression and a concatenation, so the constant and the variable forms give the widths and values the rules define (IEEE 1800-2023 Sections 11.4.12 and 11.4.13, A.8.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.13 A.8.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_concat_replication.expected
*/
// IEEE 1800-2023 A.8.1, concatenation and multiple_concatenation: a
// concatenation is "{" expression { , expression } "}", so its expression
// list is not empty; a multiple concatenation is "{" expression concatenation
// "}". Clause 39 of A.10 requires its multiplier to be a constant expression
// unless the type of the concatenation is string, so every multiplier here is
// a constant.
//
// {a, b} joins the four-bit A and 5 into A5. The constant concatenation
// {1, 2} gives 12, the multiple concatenation {2{3}} gives 33, and
// {2{4, 5}} repeats the two-element concatenation and gives 45.

module test_A_extra_concat_replication;
  logic [3:0] a = 4'hA;
  logic [3:0] b = 4'h5;

  localparam logic [7:0] K = {4'h1, 4'h2};
  localparam logic [7:0] R = {2{4'h3}};
  localparam logic [7:0] S = {2{4'h4, 4'h5}};

  initial $display("%h %h %h %h", {a, b}, K, R, S);
endmodule
