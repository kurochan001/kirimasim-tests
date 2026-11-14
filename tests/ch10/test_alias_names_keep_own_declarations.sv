/*
:name: test_alias_names_keep_own_declarations
:description: nets joined by an alias statement share their bits from the start of simulation to its end, while each name keeps the range and signedness of its own declaration in the other statements (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_alias_names_keep_own_declarations.expected
*/
// IEEE 1800-2023 §10.11: aliasing is done at elaboration time and cannot be
// undone, and using a net in an alias statement does not change how the net
// behaves in the other statements. The members of an alias overlay their
// bits as the members of a packed union of the same types do: the leftmost
// bit of each is the same physical bit.
//
// a is declared [3:0], b [0:3] and s signed [3:0], and the alias statement,
// written at the end of the module, joins all three; only a is driven. So
// a[0], the rightmost bit of a, is the same bit as b[3], the rightmost bit
// of b, and b[0] is the leftmost bit. With 4'b0001 driven, a[0] and b[3] are
// 1 and b[0] is 0. With 4'b1110, a and b read 14 as unsigned values and s
// reads -2, so s < 0 is true and a < 0 is false. A force on s, which names
// the same net, shows on a and b, and after release the three names show the
// driver again, as at every later change.
// The expected output follows the standard alone. Icarus Verilog 13.0 does
// not parse the alias statement, and the 5.054 release of Verilator rejects
// an alias between a signed and an unsigned net as nets of incompatible data
// types, although §10.11 requires the aliased nets only to have the same net
// type (here wire) and the same size.

module test_alias_names_keep_own_declarations;
  wire [3:0] a;
  wire [0:3] b;
  wire signed [3:0] s;
  logic [3:0] drv;

  assign a = drv;

  initial begin
    drv = 4'b0001;
    #1 $display("bits: a[0]=%b b[3]=%b b[0]=%b", a[0], b[3], b[0]);
    drv = 4'b1110;
    #1 $display("values: a=%0d b=%0d s=%0d", a, b, s);
    $display("signedness: s<0=%b a<0=%b", s < 0, a < 0);
    force s = 4'b0101;
    #1 $display("force on s: a=%0d b=%0d s=%0d", a, b, s);
    release s;
    #1 $display("release: a=%0d b=%0d s=%0d", a, b, s);
    drv = 4'b1000;
    #1 $display("later: a=%0d b=%0d s=%0d b[0]=%b", a, b, s, b[0]);
  end

  alias a = b = s;
endmodule
