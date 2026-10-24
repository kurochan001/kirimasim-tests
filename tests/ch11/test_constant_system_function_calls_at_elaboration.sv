/*
:name: test_constant_system_function_calls_at_elaboration
:description: conversion, mathematical and bit vector system functions and $sformatf with constant arguments, and data and array query functions of fixed-size variables, are constant expressions evaluated at elaboration, usable in parameters, packed and unpacked dimensions and generate conditions (IEEE 1800-2023 Section 11.2.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.1 20.5 20.6.2 20.7 20.8 20.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_system_function_calls_at_elaboration.expected
*/
// IEEE 1800-2023 §11.2.1: calls of the conversion (§20.5), mathematical
// (§20.8) and bit vector (§20.9) system functions and of $sformatf with
// constant arguments are constant system function calls, and the data and
// array query functions (§20.6, §20.7) can be constant even for arguments
// that are variables, when the argument has a fixed size. In constant
// expressions such calls are evaluated at elaboration.
// Every call is in a localparam, a packed or unpacked dimension or a
// generate condition, which need constant expressions, and the values are
// printed at time 0. $rtoi truncates (3, not 4); $unsigned and $signed
// change how the same bits extend into an int (255 and -1). $clog2 is 4 for
// 16 and 5 for 17, so w has 5 bits. The generate branch g_four exists
// because $countones(8'b1011_0001) is 4. v, dv and arr are variables, but
// their sizes, bounds and dimension counts are fixed, so the queries are
// constant, and arr2 gets $bits(v) / 4 = 3 elements.
// Icarus Verilog 13.0 cannot evaluate $realtobits or $bitstoreal in a
// parameter and does not accept a query of a variable in a constant
// expression.

module test_constant_system_function_calls_at_elaboration;
  localparam int P_RTOI = $rtoi(3.7);
  localparam real P_ITOR = $itor(5) / 2;
  localparam int P_UNS = $unsigned(-8'sd1);
  localparam int P_SIG = $signed(4'b1111);
  localparam logic [63:0] P_BITS = $realtobits(1.0);
  localparam real P_REAL = $bitstoreal(64'h4004_0000_0000_0000);
  localparam int W16 = $clog2(16);
  localparam int W = $clog2(17);
  localparam real P_SQRT = $sqrt(16.0);
  localparam real P_POW = $pow(2.0, 10);
  localparam real P_FLOOR = $floor(2.7);
  localparam real P_CEIL = $ceil(2.2);
  localparam int P_ONES = $countones(8'b1011_0001);
  localparam int P_HOT = $onehot(8'b0001_0000);
  localparam int P_NOTHOT = $onehot(8'b0001_0001);
  localparam int P_HOT0 = $onehot0(8'b0000_0000);
  localparam int P_UNK = $isunknown(4'b1001);
  localparam int P_CNT = $countbits(8'b1010_1100, '0);
  localparam string P_FMT = $sformatf("w%0d_%s", 12, "x");
  logic [11:0] v;
  int arr [0:6];
  logic [5:0] dv [0:2];
  localparam int P_VBITS = $bits(v);
  localparam int P_SIZE = $size(arr);
  localparam int P_LEFT = $left(dv);
  localparam int P_HIGH2 = $high(dv, 2);
  localparam int P_INC = $increment(dv);
  localparam int P_DIMS = $dimensions(dv);
  localparam int P_UDIMS = $unpacked_dimensions(dv);
  logic [W-1:0] w;
  logic [3:0] arr2 [$bits(v) / 4];

  if ($countones(8'b1011_0001) == 4) begin : g_four
    localparam int K = 44;
  end else begin : g_other
    localparam int K = 0;
  end

  initial begin
    $display("conversion: %0d %0.1f %0d %0d %h %0.2f", P_RTOI, P_ITOR, P_UNS, P_SIG, P_BITS,
             P_REAL);
    $display("math: %0d %0d %0.1f %0.1f %0.1f %0.1f, $bits(w) = %0d", W16, W, P_SQRT, P_POW,
             P_FLOOR, P_CEIL, $bits(w));
    $display("bit vector: %0d %0d %0d %0d %0d %0d, generate: %0d", P_ONES, P_HOT, P_NOTHOT,
             P_HOT0, P_UNK, P_CNT, g_four.K);
    $display("sformatf: %s", P_FMT);
    $display("queries: %0d %0d %0d %0d %0d %0d %0d, $size(arr2) = %0d", P_VBITS, P_SIZE, P_LEFT,
             P_HIGH2, P_INC, P_DIMS, P_UDIMS, $size(arr2));
  end
endmodule
