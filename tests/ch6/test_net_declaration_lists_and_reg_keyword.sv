/*
:name: test_net_declaration_lists_and_reg_keyword
:description: One net declaration can list several nets, each with its own unpacked dimensions and optional assignment, all resolved by the leading net type, and reg can follow a net type keyword when another token such as scalared or a drive strength comes between them (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.1 6.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_declaration_lists_and_reg_keyword.expected
*/
// IEEE 1800-2023 §6.7, 6.7.1: a net declaration starts with a net type, which
// decides how all its nets are resolved, and can declare several nets with the
// same characteristics, each with its own unpacked dimensions and, where
// allowed, its own declaration assignment. Without a data type, or with only a
// range and signing, the data type is logic. reg cannot follow a net type
// keyword directly, but can when another token, such as scalared or a drive
// strength, comes between them.
// la, lb and lc share [3:0]: la has a declaration assignment, lb a separate
// continuous assignment, and lc is an array of two nets. pa and pb are both
// wand, and each has two drivers, which are combined bit by bit with AND. ws
// has only signed and a range, so it is a signed 4-bit logic net. wr and wpr
// are nets of type reg, with scalared and with a drive strength between the
// net type and reg.
// Oracle checks: Icarus Verilog 13.0 gives a syntax error for a list that mixes
// nets with and without declaration assignments and for reg as the data type
// of a net.

module test_net_declaration_lists_and_reg_keyword;
  logic [3:0] src = 4'b1010;

  wire [3:0] la = src, lb, lc [0:1];
  wand [1:0] pa, pb;
  wire signed [3:0] ws;
  wire scalared reg [3:0] wr = src;
  tri (pull0, pull1) reg wpr = src[1];

  assign lb = ~src;
  assign lc[0] = src + 4'd1;
  assign lc[1] = src - 4'd1;
  assign pa = 2'b10;
  assign pa = 2'b11;
  assign pb = 2'b01;
  assign pb = 2'b11;
  assign ws = 4'b1000;

  initial begin
    #1 $display("list: la=%b lb=%b lc[0]=%b lc[1]=%b bits %0d %0d %0d", la, lb, lc[0], lc[1],
                $bits(la), $bits(lb), $bits(lc[1]));
    $display("wand list: pa=%b pb=%b", pa, pb);
    $display("range and signing only: ws=%0d bits %0d", ws, $bits(ws));
    $display("reg after other tokens: wr=%b bits %0d wpr=%b", wr, $bits(wr), wpr);
  end
endmodule
