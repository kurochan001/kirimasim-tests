/*
:name: test_vpi_put_value_caller_storage_time_strength
:description: vpi_put_value takes a delayed value in the time and strength formats of Table 38-3 from an s_vpi_value, the time or strength structure it points to and an s_vpi_time that the application allocates and overwrites right after the call (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.15
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_put_value_caller_storage_time_strength.c
:expected_stdout: @test_vpi_put_value_caller_storage_time_strength.expected
*/
// IEEE 1800-2023 §38.34: the application allocates the s_vpi_value that
// holds the value to set, any storage the value union points to, and the
// s_vpi_time that holds the delay, and the value has one of the formats of
// Table 38-3 (38.15), which include vpiTimeVal, a time as two 32-bit words,
// and vpiStrengthVal, the value and the strengths of a scalar. The storage
// belongs to the application, so the value and the delay are those the
// structures hold during the call, even when the event comes later.
//
// At time 1, in a cbAfterDelay callback registered at the start of the
// simulation, the application puts into the time variable tv the time with
// high word 3 and low word 9, and into the scalar net sn, which has no
// driver, the value 1 with weak strength for both components, both with
// vpiInertialDelay and a delay of 4. Right after the calls it overwrites the
// time with high 0 and low 1, the strength value with a strong 0 and the
// delay with 8. Callbacks at 4, before the events at 5, and at 6, after
// them, read tv as vpiTimeVal and sn as vpiStrengthVal and print the two
// time words, the logic value of sn and, once it is 1, the strength of its 1
// component. No driver of sn changes, so the value put stays on it (38.34).
// The release 13.0 of Icarus Verilog gives no handle for the net sn and does
// not implement vpiTimeVal for a time variable, and the 5.054 release of
// the Verilator simulator stops at the vpiTimeVal format, so the expected
// output follows the clauses alone.

`timescale 1ns/1ns

module test_vpi_put_value_caller_storage_time_strength;
  time tv = 0;
  wire sn;

  initial #7 $finish;
endmodule
