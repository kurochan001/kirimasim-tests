/*
:name: test_class_extends_inherits_implements_does_not
:description: a class that extends a class and implements an interface class inherits the properties and methods of the class it extends but nothing of the interface class, whose methods it has to implement and whose typedef and parameter it reaches only with the class scope operator (IEEE 1800-2023 Section 8.26.2)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.2 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_extends_inherits_implements_does_not.expected
*/
// IEEE 1800-2023 §8.26.2: extending a class makes all its members members of
// the subclass, while implementing an interface class inherits nothing; it
// only requires implementations of the interface class's pure virtual
// methods. A class may extend a class and implement interface classes at the
// same time.
//
// fifo_c extends store_c and implements put_if. Its put method uses the
// property items and the method grow that it inherits from store_c, and the
// object answers size() and items through those inherited members. put_if
// declares tag_t (12 bits) and LIMIT (8); inside fifo_c the plain names tag_t
// and LIMIT are not inherited and so find the module's tag_t (4 bits) and
// LIMIT (3), while put_if::tag_t and put_if::LIMIT reach the interface
// class's own. put is called through a put_if handle.
// Icarus Verilog 13.0 does not support interface classes.

module test_class_extends_inherits_implements_does_not;
  typedef bit [3:0] tag_t;
  localparam int LIMIT = 3;

  interface class put_if;
    typedef bit [11:0] tag_t;
    parameter int LIMIT = 8;
    pure virtual function void put(int v);
  endclass

  class store_c;
    int items[$];
    int grows;
    function void grow(int v);
      items.push_back(v);
      grows++;
    endfunction
    function int size();
      return items.size();
    endfunction
  endclass

  class fifo_c extends store_c implements put_if;
    virtual function void put(int v);
      grow(v * 10);
    endfunction
    function int plain_tag_bits();
      return $bits(tag_t);
    endfunction
    function int plain_limit();
      return LIMIT;
    endfunction
    function int scoped_tag_bits();
      return $bits(put_if::tag_t);
    endfunction
    function int scoped_limit();
      return put_if::LIMIT;
    endfunction
  endclass

  fifo_c f;
  put_if p;

  initial begin
    f = new;
    p = f;
    p.put(4);
    p.put(7);
    $display("inherited from store_c: size=%0d items=%0d,%0d grows=%0d", f.size(), f.items[0],
             f.items[1], f.grows);
    $display("plain names in fifo_c: tag_t %0d bits, LIMIT=%0d", f.plain_tag_bits(),
             f.plain_limit());
    $display("put_if:: names in fifo_c: tag_t %0d bits, LIMIT=%0d", f.scoped_tag_bits(),
             f.scoped_limit());
  end
endmodule
