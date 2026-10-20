/*
:name: test_interface_class_typedef_conflict_resolved
:description: An interface class that inherits the same typedef name from two interface classes resolves the collision by declaring the name itself (IEEE 1800-2023 Section 8.26.6.2)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.6.2 8.26.3 8.26.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_typedef_conflict_resolved.expected
*/
// IEEE 1800-2023 §8.26.6.2: an interface class can inherit parameters and
// typedefs from several interface classes; a name inherited from two of them
// collides, also when both declarations are alike, and the extending
// interface class has to declare the name itself. port_if extends reader_if
// and writer_if, which both declare word_t, and declares its own word_t,
// which the class port uses through port_if::word_t.

module test_interface_class_typedef_conflict_resolved;
  interface class reader_if;
    typedef int word_t;
    pure virtual function word_t read();
  endclass

  interface class writer_if;
    typedef int word_t;
    pure virtual function void write(word_t w);
  endclass

  interface class port_if extends reader_if, writer_if;
    typedef shortint word_t;
    pure virtual function word_t width();
  endclass

  class port implements port_if;
    int last;
    virtual function reader_if::word_t read();
      return last;
    endfunction
    virtual function void write(writer_if::word_t w);
      last = w;
    endfunction
    virtual function port_if::word_t width();
      return $bits(port_if::word_t);
    endfunction
  endclass

  port p;
  port_if pi;

  initial begin
    p = new();
    pi = p;
    pi.write(77);
    $display("read %0d, width of port_if::word_t %0d", pi.read(), pi.width());
  end
endmodule
