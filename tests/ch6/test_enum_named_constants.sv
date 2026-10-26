/*
:name: test_enum_named_constants
:description: an enum defines integral named constants that have their declared encodings and are usable in constant expressions and case items
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_named_constants.expected
*/
// IEEE 1800-2023 6.19: an enum declaration defines strongly typed integral
// named constants, one for each name, with the encodings the declaration
// gives. The names here are used as an enum-typed localparam, as an int
// localparam, in a constant expression, and as case items, and the enum type
// is printed through $bits. A tool that does not make the names integral
// constants cannot elaborate the localparams, and one that assigns different
// encodings prints other numbers.

typedef enum logic [2:0] {RED = 3'd1, GREEN = 3'd2, BLUE = 3'd4} color_t;

module test_enum_named_constants;
  localparam color_t FAV = GREEN;
  localparam int NUM = BLUE;
  const int CI = RED + 1;

  initial begin
    $display("enc=%0d %0d %0d", RED, GREEN, BLUE);
    $display("fav=%0d num=%0d ci=%0d", FAV, NUM, CI);
    case (GREEN)
      RED: $display("case=red");
      GREEN: $display("case=green");
      default: $display("case=other");
    endcase
    $display("bits=%0d", $bits(color_t));
  end
endmodule
