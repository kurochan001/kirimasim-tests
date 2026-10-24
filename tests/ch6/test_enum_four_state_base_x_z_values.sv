/*
:name: test_enum_four_state_base_x_z_values
:description: an enum with an explicit 4-state base type may give names values with x and z bits, and the names keep those exact bits (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.19.5.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_enum_four_state_base_x_z_values.expected
*/
// IEEE 1800-2023 §6.19: an enum whose base is a 4-state type may have names
// whose values contain x or z bits. The names XV and ZV of the logic [2:0]
// enum hold 3'b1x0 and 3'bz01 exactly: the case equality with those
// literals is 1, while a value with the x or z bits turned into 0 or 1 is
// not equal. IX of the integer enum holds 32 x bits. A variable set to XV has
// the name XV (§6.19.5.6).

module test_enum_four_state_base_x_z_values;
  typedef enum logic [2:0] {A = 3'b000, XV = 3'b1x0, ZV = 3'bz01, B = 3'b011} l_t;
  typedef enum integer {I0, IX = 32'bx, I1 = 1} i_t;
  l_t v;

  initial begin
    $display("XV=%b ZV=%b IX=%b", XV, ZV, IX);
    $display("exact: %0d %0d %0d", XV === 3'b1x0, ZV === 3'bz01, IX === 32'bx);
    $display("not 2-state: %0d %0d %0d %0d", XV === 3'b100, XV === 3'b110,
             ZV === 3'b001, ZV === 3'b101);
    v = XV;
    $display("v=%b name=%s num=%0d", v, v.name(), v.num());
    v = ZV;
    $display("v=%b name=%s", v, v.name());
  end
endmodule
