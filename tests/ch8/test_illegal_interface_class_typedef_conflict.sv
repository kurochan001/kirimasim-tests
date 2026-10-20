/*
:name: test_illegal_interface_class_typedef_conflict
:description: An interface class that inherits the same typedef name from two interface classes without declaring the name itself is an error (IEEE 1800-2023 Section 8.26.6.2)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: word_t is inherited from both reader_if and writer_if and port_if does not declare it
:expected_stderr_regex: test_illegal_interface_class_typedef_conflict\.sv:32:
*/
// IEEE 1800-2023 §8.26.6.2: a name inherited from two interface classes
// collides, even when both declarations are alike and the name is never used,
// and the extending interface class has to declare the name to resolve the
// collision. port_if does not. Icarus Verilog 13.0 does not support interface
// classes, so the syntax errors it reports there, as on most other lines, do
// not count.

module test_illegal_interface_class_typedef_conflict;
  interface class reader_if;
    typedef int word_t;
    pure virtual function word_t read();
  endclass

  interface class writer_if;
    typedef int word_t;
    pure virtual function void write(word_t w);
  endclass

  interface class port_if extends reader_if, writer_if;   // illegal: word_t collides
  endclass
endmodule
