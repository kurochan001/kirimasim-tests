/*
:name: test_delay_negative_value_is_unsigned_time
:description: a delay control whose expression is a negative int waits for that value read as a 64-bit unsigned time, so #(-10) resumes at 2**64-10 (IEEE 1800-2023 Section 9.4.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delay_negative_value_is_unsigned_time.expected
*/
// IEEE 1800-2023 §9.4.1: a delay expression that evaluates to a negative
// value is interpreted as a two's-complement unsigned integer as wide as a
// time variable, which is 64 bits (6.11). So a delay of the int -10 is the
// delay 2**64 - 10 = 18446744073709551606, not 0, not 10, and not the 32-bit
// reading 4294967286.
//
// The first process waits #(d) with d = -10 from time 0 and prints the time
// at which it resumes; nothing else is scheduled after time 4294967300. A
// second process prints at time 4294967300, after the time at which a 32-bit
// reading would already have resumed the first one, and shows that the first
// one is still waiting.
//
// Release 5.052 of Verilator reads the int -10 as the 32-bit unsigned value
// 4294967286 and resumes the first process at that time, which the standard
// does not allow; Icarus Verilog 13.0 waits the 64-bit delay.

`timescale 1ns/1ns
module test_delay_negative_value_is_unsigned_time;
  int d = -10;
  bit resumed = 0;

  initial begin
    #(d);
    resumed = 1;
    $display("resumed at t=%0d", $time);
  end

  initial begin
    #(64'd4294967300);
    $display("at t=%0d resumed=%0d", $time, resumed);
  end
endmodule
