/*
:name: test_interface_class_multiple_extends_hiding_conflicts
:description: an interface class that extends two parameterized interface classes inherits their types, parameters and pure virtual methods, hides an inherited typedef with its own, overrides a parameter inherited from both, redeclares a method inherited from both, and keeps one copy of a parameter both reach from a common base (IEEE 1800-2023 Sections 8.26 and 8.26.1)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26 8.26.1 8.26.6.1 8.26.6.2 8.26.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_multiple_extends_hiding_conflicts.expected
*/
// IEEE 1800-2023 §8.26: an interface class can extend several interface
// classes; it inherits their member types, pure virtual methods and
// parameters, except the ones it hides with its own declarations, and the
// name conflicts of multiple inheritance are resolved as 8.26.6 says.
// §8.26.1: an interface class has an optional parameter port list, an
// optional extends list of interface class types separated by commas, and
// items that are type declarations, pure virtual method prototypes (which
// can have attributes), parameter and localparam declarations, and empty
// items.
//
// chan_if extends src_if#(byte, 3) and sink_if#(12), which both extend
// root_if. In chan_if:
// - elem_t is its own shortint typedef, which hides the byte elem_t of src_if
//   (16 bits, not 8; peek returns 35 * 300 = 10500, which a byte would
//   truncate to 4);
// - word_t (12 bits) and W (12) come from sink_if, DEPTH (3 * 2 = 6) and N (3)
//   from src_if;
// - KIND, which both src_if (1) and sink_if (2) declare, is overridden with 3
//   (8.26.6.2);
// - count, declared by both, is redeclared once (8.26.6.1), and one method of
//   the implementing class serves the handles of all three types;
// - VERSION from root_if is reached through both bases; it is one copy and
//   not a conflict (8.26.6.3).
// read and write are inherited pure virtual methods, called through a
// chan_if handle. The values written are 12'h123 and 12'hfe7; their low
// bytes 8'h23 (35) and 8'he7 (-25 as a byte) are stored.
//
// The 5.052 release of Verilator finds neither the typedefs and parameters
// that chan_if inherits (chan_if::word_t, DEPTH, N, W, VERSION) nor the
// method write that it inherits from sink_if, the second class of its
// extends list; Icarus Verilog 13.0 does not support interface classes.

module test_interface_class_multiple_extends_hiding_conflicts;
  interface class root_if;
    parameter int VERSION = 4;
  endclass

  interface class src_if #(type T = int, int N = 2) extends root_if;
    typedef T elem_t;
    parameter int DEPTH = N * 2;
    localparam int KIND = 1;
    pure virtual function elem_t read(int i);
    pure virtual function int count();
  endclass : src_if

  interface class sink_if #(int W = 8) extends root_if;
    typedef logic [W-1:0] word_t;
    localparam int KIND = 2;
    pure virtual function void write(word_t w);
    pure virtual function int count();
  endclass : sink_if

  interface class chan_if extends src_if #(byte, 3), sink_if #(12);
    typedef shortint elem_t;
    localparam int KIND = 3;
    ;
    (* note = "one count for both bases" *) pure virtual function int count();
    pure virtual function elem_t peek();
  endclass : chan_if

  class chan_c implements chan_if;
    byte data[$];
    virtual function src_if#(byte, 3)::elem_t read(int i);
      return data[i];
    endfunction
    virtual function void write(sink_if#(12)::word_t w);
      data.push_back(w[7:0]);
    endfunction
    virtual function int count();
      return data.size();
    endfunction
    virtual function chan_if::elem_t peek();
      return chan_if::elem_t'(data[0]) * 300;
    endfunction
  endclass

  chan_c obj;
  chan_if c;
  src_if #(byte, 3) s;
  sink_if #(12) k;
  root_if r;

  initial begin
    $display("chan_if: elem_t %0d bits, word_t %0d bits, src elem_t %0d bits",
             $bits(chan_if::elem_t), $bits(chan_if::word_t), $bits(src_if#(byte, 3)::elem_t));
    $display("chan_if: DEPTH=%0d N=%0d W=%0d KIND=%0d VERSION=%0d", chan_if::DEPTH,
             chan_if::N, chan_if::W, chan_if::KIND, chan_if::VERSION);
    obj = new;
    c = obj;
    c.write(12'h123);
    c.write(12'hfe7);
    $display("through chan_if: count=%0d read(0)=%0d read(1)=%0d peek=%0d", c.count(),
             c.read(0), c.read(1), c.peek());
    s = c;
    k = c;
    r = c;
    k.write(12'h005);
    $display("through src_if: count=%0d read(2)=%0d; root_if handle set: %0d", s.count(),
             s.read(2), r != null);
  end
endmodule
