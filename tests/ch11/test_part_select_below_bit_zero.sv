/*
:name: test_part_select_below_bit_zero
:description: Part-selects that reach below bit 0, with a negative or a small base, read x there and write only the bits in range (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_part_select_below_bit_zero.expected
*/
// IEEE 1800-2023 §11.5.1: a part-select that is partly out of range reads x
// for the bits out of range and, when written, changes only the bits in
// range. With a signed base of -1, data[sidx +: 4] covers bits 2 to -1, so
// it reads 111x from an all-ones vector. A write to u[b -: 8] with b = 3
// covers bits 3 to -4: bits 3 to 0 get the four most significant bits of
// the value and the rest is dropped, and y[k +: 8] with k = -2 covers bits
// -2 to 5, of which bits 5 to 0 get the six most significant bits.

module test_part_select_below_bit_zero;
  logic [31:0] data = 32'hffff_ffff;
  logic signed [3:0] sidx = -1;
  logic [15:0] u, w, y, r;
  logic [7:0] rd;
  int b = 3, k = -2;

  initial begin
    $display("data[sidx +: 4] = %b", data[sidx +: 4]);
    u = '0;
    u[b -: 8] = '1;
    $display("u = %h", u);
    w = '0;
    w[b -: 8] = 8'ha5;
    $display("w = %h", w);
    y = '0;
    y[k +: 8] = 8'hff;
    $display("y = %h", y);
    r = 16'h000f;
    rd = r[b -: 8];
    $display("r[b -: 8] = %b", rd);
  end
endmodule
