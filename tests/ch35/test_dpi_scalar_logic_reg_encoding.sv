/*
:name: test_dpi_scalar_logic_reg_encoding
:description: Scalar logic, reg and bit arguments and a scalar logic result are passed as unsigned char values with the svdpi.h encodings 0, 1, 2 for z and 3 for x, input ones by value and output and inout ones through a pointer (IEEE 1800-2023 Section 35.5.6, H.7.4, H.8.7, H.8.9, H.10.1.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.4 H.8.7 H.8.9 H.10.1.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_scalar_logic_reg_encoding.c
:expected_stdout: @test_dpi_scalar_logic_reg_encoding.expected
*/
// IEEE 1800-2023 §35.5.6: scalar bit and logic values may be arguments and
// results of imported functions. H.7.4 (Table H.1): a scalar logic or reg
// and a scalar bit are a C unsigned char, with the encodings of svdpi.h, and
// reg uses the same encodings as logic. H.10.1.1: these are sv_0 = 0,
// sv_1 = 1, sv_z = 2 and sv_x = 3, in the type svLogic or svBit. H.8.7: a
// scalar input is small, so it is passed by value; output and inout are
// passed through a pointer (H.8.8). H.8.9: a scalar logic may be a function
// result.
//
// c_codes gets a logic and a reg input, each with the same one of the four
// values, writes their codes into two int outputs and returns the logic
// value whose code is the input's code with its low bit flipped, so 0 gives
// 1, 1 gives 0, z gives x and x gives z. c_make writes the logic output with
// the code it is given and the inout reg with 3 minus that code, after
// printing the code the inout reg had. c_bit gives the code of a bit input.
// The design prints the values with %b.
//
// Icarus Verilog 13.0 has no DPI, and Verilator 5.052 is a two-state
// simulator, so :oracle: names no simulator.

module test_dpi_scalar_logic_reg_encoding;
  import "DPI-C" function logic c_codes(input logic l, input reg r, output int lc,
                                        output int rc);
  import "DPI-C" function void c_make(input int code, output logic l, inout reg r);
  import "DPI-C" function int c_bit(input bit b);

  logic values [4] = '{1'b0, 1'b1, 1'bz, 1'bx};
  logic l, back;
  reg r;
  int lc, rc;

  initial begin
    foreach (values[k]) begin
      back = c_codes(values[k], values[k], lc, rc);
      $display("logic %b reg %b: codes %0d %0d, returned %b", values[k], values[k], lc, rc,
               back);
    end
    r = 1'bz;
    for (int code = 0; code < 4; code++) begin
      c_make(code, l, r);
      $display("made from %0d: l %b r %b", code, l, r);
    end
    $display("bit 0 and 1: codes %0d %0d", c_bit(1'b0), c_bit(1'b1));
  end
endmodule
