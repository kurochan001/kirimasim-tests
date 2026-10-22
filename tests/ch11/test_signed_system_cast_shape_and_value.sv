/*
:name: test_signed_system_cast_shape_and_value
:description: Check signedness casts retain packed operand dimensions, bit counts and values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7 6.24.1 20.6.2 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_system_cast_shape_and_value.expected
*/
// IEEE 11.7: both functions retain the evaluated operand bits and
// one packed dimension while selecting signedness. Queries and marker
// concatenations expose width changes hidden by ordinary assignments.
// The small sum is evaluated at its own width before the system cast.
// Icarus 13.0 crashes while compiling the array query on a cast result.
module test_signed_system_cast_shape_and_value;
  logic [7:0] u = 8'hf9;
  logic signed [7:0] s = -7;
  logic [64:0] big = {1'b1,64'h1};
  logic [15:0] signed_wide, unsigned_wide;
  initial begin
    $display("bits=%0d %0d wide_bits=%0d %0d",
             $bits($signed(u)), $bits($unsigned(s)),
             $bits($signed(big)), $bits($unsigned(big)));
    $display("dimensions=%0d %0d unpacked=%0d %0d",
             $dimensions($signed(u)), $dimensions($unsigned(s)),
             $unpacked_dimensions($signed(u)), $unpacked_dimensions($unsigned(s)));
    $display("bounds=%0d:%0d %0d:%0d",
             $left($signed(u)), $right($signed(u)),
             $left($unsigned(s)), $right($unsigned(s)));
    $display("packed_values=%h %h", {$signed(u),1'b0}, {$unsigned(s),1'b0});
    $display("wide_values=%h %h", $signed(big), $unsigned(big));
    $display("interpretation=%0d %0d", $signed(u) < 0, $unsigned(s) > 0);
    signed_wide = $signed(u);
    unsigned_wide = $unsigned(s);
    $display("extension=%h %h", signed_wide, unsigned_wide);
    $display("evaluated_input_bits=%0d value=%h",
             $bits($signed(4'hf + 4'h1)), $signed(4'hf + 4'h1));
    $finish;
  end
endmodule
