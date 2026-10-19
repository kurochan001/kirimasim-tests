/*
:name: test_interface_class_implements
:description: A class implementing two parameterized interface classes, used through handles of each interface class type (IEEE 1800-2023 Section 8.26)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26 8.26.1 8.26.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_implements.expected
*/
// IEEE 1800-2023 §8.26, §8.26.2: a class can implement several interface
// classes by giving every pure virtual method they declare, and an object of it
// can be assigned to a handle of each of those interface class types and used
// through it. A parameterized class passes its parameter on to the interface
// classes it implements (8.26.1).

interface class ic_putter #(type T = int);
  pure virtual function void put(T v);
endclass

interface class ic_getter #(type T = int);
  pure virtual function T get();
endclass

class ic_box #(type T = int) implements ic_putter #(T), ic_getter #(T);
  T store;
  virtual function void put(T v);
    store = v;
  endfunction
  virtual function T get();
    return store;
  endfunction
endclass

module test_interface_class_implements;
  ic_box #(int) box;
  ic_putter #(int) p;
  ic_getter #(int) g;
  ic_box #(byte) small_box;
  ic_getter #(byte) small_g;

  initial begin
    box = new;
    p = box;
    g = box;
    p.put(42);
    $display("through getter: %0d", g.get());
    p.put(7);
    $display("through the class: %0d", box.get());
    small_box = new;
    small_g = small_box;
    small_box.put(8'sd127 + 8'sd1);
    $display("byte box: %0d", small_g.get());
  end
endmodule
