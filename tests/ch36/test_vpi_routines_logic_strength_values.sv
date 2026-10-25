/*
:name: test_vpi_routines_logic_strength_values
:description: the routines of Table 36-7 do what it lists: vpi_get_value reads the logic value of a variable and the value with strength of a net, and vpi_put_value writes a logic value to a variable and a value with strength to a scalar net (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.15 38.34 28.11 21.2.1.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_routines_logic_strength_values.c
:expected_stdout: @test_vpi_routines_logic_strength_values.expected
*/
// IEEE 1800-2023 §36.11, Table 36-7: vpi_get_value retrieves the logic value
// or the strength value of an object, and vpi_put_value writes one. §38.15:
// the format field chooses the form, here vpiBinStrVal and vpiIntVal for the
// logic value, and vpiStrengthVal, which gives the logic value with the
// strengths of its 0 and 1 parts (s0, s1). §38.34: with vpiNoDelay the object
// gets the value at once; on a net the value overrides the resolved value
// until a driver of the net changes, and vpiStrengthVal is allowed for a
// scalar object.
// The net wk is driven with weak strength (28.11) to 0; fl has no driver, so
// it is z. At time 1 the application reads r, wk and fl, writes 90 to r and
// a pull 1 to fl, and reads fl back; at time 2 the design prints r and the
// value of fl with its strength (%v, 21.2.1.5), Pu1.
// Icarus Verilog 13.0 stops the run when a value with strength is put on fl,
// and Verilator 5.052 does not support the format vpiStrengthVal.

`timescale 1ns/1ns

module test_vpi_routines_logic_strength_values;
  logic [7:0] r;
  wire wk;
  wire fl;

  assign (weak0, weak1) wk = 1'b0;

  initial begin
    r = 8'h0f;
    #2 $display("design at 2: r=%h fl=%v", r, fl);
  end
endmodule
