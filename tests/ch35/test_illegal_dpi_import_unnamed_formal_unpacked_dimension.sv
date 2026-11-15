/*
:name: test_illegal_dpi_import_unnamed_formal_unpacked_dimension
:description: In an import declaration only a formal name separates the packed from the unpacked dimensions, so an unnamed formal bit [7:0] [3], whose [3] cannot be a packed dimension, is an error (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unnamed formal of c_first has the dimension [3] after the packed type bit [7:0], and without a name there is nothing to make [3] an unpacked dimension
:expected_stderr_regex: test_illegal_dpi_import_unnamed_formal_unpacked_dimension\.sv:33:
*/
// IEEE 1800-2023 §35.5.4: a formal argument name is required to separate the
// packed and the unpacked dimensions of an array formal. The dimensions after
// the data type of an unnamed formal are therefore part of its packed type,
// and a packed dimension is a range or [] (A.2.5); only an unpacked one can be
// a size such as [3] (7.4.2).
//
// c_sum has the formal bit [7:0] v [3], an unpacked array of three bytes,
// which is legal. c_first has the same type without the name, written
// bit [7:0] [3]. A tool that let [3] be an unpacked dimension of an unnamed
// formal would accept it as the type of c_sum. The packed type bit [7:0] is
// legal for a formal on its own, so the only fault is the missing name. With
// the name the declaration is legal.
// The 5.054 release of Verilator reports a syntax error at [3], where it
// expects the colon of a packed range, and accepts the design with the
// name. Icarus Verilog 13.0 has no DPI and reports both import declarations
// as syntax errors, so its error does not count.

module test_illegal_dpi_import_unnamed_formal_unpacked_dimension;
  import "DPI-C" function int c_sum(input bit [7:0] v [3]);
  import "DPI-C" function int c_first(input bit [7:0] [3]);   // illegal: no name before [3]

  bit [7:0] bytes [3];

  initial begin
    bytes = '{8'd1, 8'd2, 8'd3};
    $display("%0d %0d", c_sum(bytes), c_first(bytes));
  end
endmodule
