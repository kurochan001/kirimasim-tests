/*
:name: test_interface_class_types_inherited_by_extends_only
:description: an interface class that extends another inherits its typedefs and parameters, while a class that implements it does not, so in that class the same names find the declarations of the enclosing module (IEEE 1800-2023 Sections 8.26 and 8.26.3)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26 8.26.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_types_inherited_by_extends_only.expected
*/
// IEEE 1800-2023 §8.26 and §8.26.3: parameters and typedefs of an interface
// class are inherited by the interface classes that extend it, but nothing
// is inherited by a class that implements it; there they are reached with
// the class scope operator, as base_if#(16)::word_t.
//
// The module declares its own word_t (4 bits) and W (5). base_if#(W) has
// word_t of W bits. ext_if extends base_if#(16): its own word_t and W are
// the inherited ones, so its get2 returns 16 bits and its wide_t has
// 16 bits. impl_c implements ext_if; inside it, word_t and W are not the
// inherited ones but the module's: 4 bits and 5.
//
// The 5.052 release of Verilator resolves word_t and W in ext_if to the
// module's declarations (4 bits, 5) instead of the inherited ones; Icarus
// Verilog 13.0 does not support interface classes.

module test_interface_class_types_inherited_by_extends_only;
  typedef bit [3:0] word_t;
  localparam int W = 5;

  interface class base_if #(int W = 8);
    typedef logic [W-1:0] word_t;
    pure virtual function word_t get();
  endclass

  interface class ext_if extends base_if #(16);
    typedef logic [W-1:0] wide_t;
    pure virtual function word_t get2();
  endclass

  class impl_c implements ext_if;
    virtual function base_if#(16)::word_t get();
      return 16'habcd;
    endfunction
    virtual function ext_if::word_t get2();
      return 16'h1234;
    endfunction
    function int word_bits();
      return $bits(word_t);
    endfunction
    function int w_value();
      return W;
    endfunction
  endclass

  impl_c o;
  ext_if e;

  initial begin
    o = new;
    e = o;
    $display("through ext_if: get=%h get2=%h, bits of get2: %0d", e.get(), e.get2(),
             $bits(e.get2()));
    $display("ext_if::wide_t: %0d bits", $bits(ext_if::wide_t));
    $display("in impl_c: word_t %0d bits, W = %0d", o.word_bits(), o.w_value());
  end
endmodule
