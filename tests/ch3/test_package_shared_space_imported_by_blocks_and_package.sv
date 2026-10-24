/*
:name: test_package_shared_space_imported_by_blocks_and_package
:description: Two modules import one package and share its variable, another package imports the first one and builds a type and a function on its declarations, and the declarations are used under the same names everywhere (IEEE 1800-2023 Section 3.9)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.9 26.2 26.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_shared_space_imported_by_blocks_and_package.expected
*/
// IEEE 1800-2023 §3.9: a package, written between package and endpackage,
// is a declaration space that other building blocks share; its
// declarations can be imported into other building blocks, also into other
// packages (§26.3).
// sp_base_pkg declares the 6-bit type word_t, the parameter SCALE = 3, the
// variable shared_count and the function scaled, which returns v * SCALE as
// a word_t. sp_pair_pkg imports sp_base_pkg::* and declares, from those
// names, the packed structure pair_t of two word_t (12 bits), the function
// make_pair (scaled(x), scaled(x + 1)) and DOUBLE = SCALE * 2.
// - sp_writer imports sp_base_pkg::* and sets shared_count to 5 at time 0
//   and adds 1 at time 2; sp_reader imports only that variable by name and
//   prints it at times 1 and 3, so it reads the writes of sp_writer: both
//   name the one variable of the package.
// - The top module imports both packages and prints make_pair(4)
//   (12 and 15), $bits(pair_t), DOUBLE and scaled(30) (90 wraps to 26 in
//   six bits) at time 4.

`timescale 1ns/1ns

package sp_base_pkg;
  typedef logic [5:0] word_t;
  parameter int SCALE = 3;
  int shared_count = 0;

  function automatic word_t scaled(int v);
    return word_t'(v * SCALE);
  endfunction
endpackage : sp_base_pkg

package sp_pair_pkg;
  import sp_base_pkg::*;

  typedef struct packed {
    word_t first;
    word_t second;
  } pair_t;

  localparam int DOUBLE = SCALE * 2;

  function automatic pair_t make_pair(int x);
    pair_t r;
    r.first = scaled(x);
    r.second = scaled(x + 1);
    return r;
  endfunction
endpackage : sp_pair_pkg

module sp_writer;
  import sp_base_pkg::*;

  initial begin
    shared_count = 5;
    #2 shared_count++;
  end
endmodule

module sp_reader;
  import sp_base_pkg::shared_count;

  initial begin
    #1 $display("t=%0t reader: shared_count=%0d", $time, shared_count);
    #2 $display("t=%0t reader: shared_count=%0d", $time, shared_count);
  end
endmodule

module test_package_shared_space_imported_by_blocks_and_package;
  import sp_base_pkg::*;
  import sp_pair_pkg::*;

  sp_writer u_writer();
  sp_reader u_reader();

  pair_t p;
  word_t w;

  initial begin
    #4;
    p = make_pair(4);
    w = scaled(30);
    $display("t=%0t top: pair=(%0d,%0d) bits(pair_t)=%0d DOUBLE=%0d scaled(30)=%0d", $time,
             p.first, p.second, $bits(pair_t), DOUBLE, w);
    $display("t=%0t top: shared_count=%0d", $time, sp_base_pkg::shared_count);
  end
endmodule
