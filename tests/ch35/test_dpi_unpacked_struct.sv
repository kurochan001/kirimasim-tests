/*
:name: test_dpi_unpacked_struct
:description: An unpacked struct of C-compatible members is passed to C as the corresponding C struct, by reference as an input and as an output that is copied back (IEEE 1800-2023 Section 35.5.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.8 H.8.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_unpacked_struct.c
:expected_stdout: @test_dpi_unpacked_struct.expected
*/
// IEEE 1800-2023 §35.5.6, H.7.8: a struct built of permitted types may be a
// formal argument; an unpacked struct of C-compatible members such as int,
// byte and real corresponds to the C struct with the same members in the same
// order. It is not a small type, so an input struct is passed by reference
// (H.8.7). dpi_total reads the members, and dpi_make fills an output struct.

module test_dpi_unpacked_struct;
  typedef struct {
    int count;
    byte code;
    real scale;
  } item_t;

  import "DPI-C" function real dpi_total(input item_t it);
  import "DPI-C" function void dpi_make(input int n, output item_t it);

  item_t a, b;

  initial begin
    a.count = 3;
    a.code = 8'sd7;
    a.scale = 0.5;
    $display("total of {3, 7, 0.5}: %0.2f", dpi_total(a));
    dpi_make(4, b);
    $display("made: count=%0d code=%0d scale=%0.2f", b.count, b.code, b.scale);
  end
endmodule
