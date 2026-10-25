/*
:name: test_function_implicit_return_types
:description: A function whose return type gives only signing and packed ranges returns logic with them, a function with no return type returns a logic scalar, and a void function returns nothing and is called as a statement (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_function_implicit_return_types.expected
*/
// IEEE 1800-2023 §13.4: with the implicit syntax, which gives only the
// packed dimensions and optionally the signing, the return type is as if
// the keyword logic came first; when that syntax is empty the return type
// is a logic scalar. A void function has no return value (13.4.1).
//
// s4 is declared "function signed [3:0]": its result has 4 bits, is signed
// (8'hFF gives -1, which is below 0) and keeps x and z, so it is logic
// signed [3:0]. u8 is "function [7:0]": 8 bits, unsigned (16'hFFFF gives
// 255). one has no return type: 1 bit, keeps x and z, and keeps only the
// low bit of a 2-bit value. note is void and is called as a statement.

module test_function_implicit_return_types;
  int total;

  function signed [3:0] s4(input logic [7:0] v);
    s4 = v;
  endfunction

  function [7:0] u8(input logic [15:0] v);
    u8 = v;
  endfunction

  function one(input logic [1:0] v);
    one = v;
  endfunction

  function void note(input int v);
    total += v;
  endfunction

  initial begin
    $display("s4: bits=%0d s4(8'hFF)=%0d below zero=%0d s4(8'b0000x01z)=%b",
             $bits(s4(8'd0)), s4(8'hFF), s4(8'hFF) < 0, s4(8'b0000x01z));
    $display("u8: bits=%0d u8(16'hFFFF)=%0d below zero=%0d",
             $bits(u8(16'd0)), u8(16'hFFFF), u8(16'hFFFF) < 0);
    $display("one: bits=%0d one(2'b10)=%b one(2'b11)=%b one(2'b0x)=%b one(2'b1z)=%b",
             $bits(one(2'b00)), one(2'b10), one(2'b11), one(2'b0x), one(2'b1z));
    total = 0;
    note(3);
    note(4);
    $display("void note called twice: total=%0d", total);
  end
endmodule
