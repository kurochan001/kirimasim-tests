/*
:name: test_dpi_unsigned_atoms_and_packed_by_reference
:description: byte unsigned and shortint unsigned inputs pass by value as unsigned char and unsigned short while bit [7:0], bit [15:0], logic [7:0], an unpacked int array, a packed struct and a packed union pass by reference, packed ones as canonical chunks; outputs of both kinds come through pointers of these different types (IEEE 1800-2023 Section 35.5.6, H.7.4, H.8.7, H.8.8)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.4 H.8.7 H.8.8 6.22.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_unsigned_atoms_and_packed_by_reference.c
:expected_stdout: @test_dpi_unsigned_atoms_and_packed_by_reference.expected
*/
// IEEE 1800-2023 §35.5.6: these types may be formal arguments of imported
// functions. H.7.4: byte unsigned and shortint unsigned are the C types
// unsigned char and unsigned short, so an input of them is passed by value,
// while bit [7:0] and bit [15:0] are packed arrays, passed by reference as
// svBitVecVal; for output, byte unsigned is an unsigned char* and bit [7:0]
// an svBitVecVal*. A packed struct or union is handled as the packed array of
// the same width (6.22.2), its first member in the most significant bits.
// H.8.7: inputs that are not small, such as packed arrays, unpacked arrays
// and packed structures, are passed by reference; H.8.8: outputs are always
// passed by reference.
//
// c_in gets the value 200 both as a byte unsigned and as a bit [7:0], 60000
// as a shortint unsigned and as a bit [15:0], a logic [7:0], an int [3], a
// packed struct {4'ha, 8'h5c} and a packed union holding 12'h3f1, and prints
// what it reads. c_out writes each kind of output; the design prints them.

module test_dpi_unsigned_atoms_and_packed_by_reference;
  typedef struct packed {
    bit [3:0] hi;
    bit [7:0] lo;
  } pair_t;
  typedef union packed {
    bit [11:0] whole;
    pair_t parts;
  } either_t;

  import "DPI-C" function void c_in(input byte unsigned bu, input bit [7:0] bv,
                                    input shortint unsigned su, input bit [15:0] sv,
                                    input logic [7:0] lv, input int arr [3], input pair_t ps,
                                    input either_t pu);
  import "DPI-C" function void c_out(output byte unsigned bu, output bit [7:0] bv,
                                     output shortint unsigned su, output bit [15:0] sv,
                                     output pair_t ps);

  byte unsigned bu;
  bit [7:0] bv;
  shortint unsigned su;
  bit [15:0] sv;
  int arr [3] = '{7, 8, 9};
  pair_t ps;
  either_t pu;

  initial begin
    ps.hi = 4'ha;
    ps.lo = 8'h5c;
    pu.whole = 12'h3f1;
    c_in(200, 8'd200, 60000, 16'd60000, 8'h5a, arr, ps, pu);
    c_out(bu, bv, su, sv, ps);
    $display("c_out: bu %0d bv %h su %h sv %h ps.hi %h ps.lo %h", bu, bv, su, sv, ps.hi, ps.lo);
  end
endmodule
