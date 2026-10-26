/*
:name: test_typedef_package_type_shared
:description: An unpacked structure, a packed structure and an enum declared in a package match across instances, so values can be assigned between members of two instances of a module (IEEE 1800-2023 Section 6.22)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_package_type_shared.expected
*/
// IEEE 1800-2023 §6.22: the scope of a user-defined type includes the
// hierarchical instance scope, but a type imported from a package always
// matches itself (6.22.1 rule h). The package declares an unpacked structure,
// a packed structure and an enum. Module holder imports them and each of h1
// and h2 declares members of those types. Values assigned from h1 to h2
// therefore need no cast, and h2 shows the values of h1.

package shared_types;
  typedef struct {
    int a;
    byte b;
  } unpacked_pair;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } packed_pair;
  typedef enum logic [1:0] {RED, GREEN, BLUE} color;
endpackage

module holder;
  import shared_types::*;
  unpacked_pair up;
  packed_pair pp;
  color c;
endmodule

module test_typedef_package_type_shared;
  import shared_types::*;
  holder h1();
  holder h2();

  initial begin
    h1.up = '{a: 7, b: 8};
    h2.up = h1.up;
    h1.pp = '{hi: 4'ha, lo: 4'h5};
    h2.pp = h1.pp;
    h1.c = GREEN;
    h2.c = h1.c;
    $display("up=%0d,%0d pp=%h color=%0d", h2.up.a, h2.up.b, h2.pp, h2.c);
  end
endmodule
