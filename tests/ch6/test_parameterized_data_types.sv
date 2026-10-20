/*
:name: test_parameterized_data_types
:description: Type definitions in a parameterized virtual class give parameterized data types, specialized by the class parameters where they are used through the class scope operator (IEEE 1800-2023 Section 6.25)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.25 8.25 8.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameterized_data_types.expected
*/
// IEEE 1800-2023 §6.25: data types defined with typedef in a parameterized
// class (8.25), here a virtual one, which only serves to hold them, are used
// with the class scope operator :: (8.23) and the parameter values that
// specialize them. word_t is a packed array of WIDTH elements of T, and
// lanes_t an unpacked array of WIDTH of them.

module test_parameterized_data_types;
  virtual class bus_types #(type T = logic, int WIDTH = 4);
    typedef T [WIDTH-1:0] word_t;
    typedef T lanes_t [WIDTH];
  endclass

  bus_types#(bit, 8)::word_t w;
  bus_types#(logic [3:0], 2)::lanes_t l;
  bus_types#()::word_t d;

  initial begin
    w = 8'hff;
    $display("w: %0d bits, %0d", $bits(w), w);
    $display("l: %0d elements of %0d bits", $size(l), $bits(l[0]));
    $display("d: %0d bits", $bits(d));
  end
endmodule
