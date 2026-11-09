/*
:name: test_illegal_interface_class_restricted_type_parameter_given_class
:description: a type parameter restricted with interface class can be given only an interface class; a class that implements one is an error (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3 8.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class parameter I of keeper, declared type interface class, is given square_c in the last call, a class that implements an interface class but is not one
:expected_stderr_regex: test_illegal_interface_class_restricted_type_parameter_given_class\.sv:(42|55):
*/
// IEEE 1800-2023 §6.20.3: a type parameter declared with the keywords
// interface class before its name accepts only interface class types, and it
// is an error to give it a type that does not conform. §8.26: a class that
// implements an interface class is still a class, not an interface class.
// The class keeper has I declared type interface class with the default
// shape_ic. keeper#(ext_ic) gives an interface class that extends shape_ic,
// which is legal, and the legal design prints sides() through its handle of
// type I and through that of the default specialization: 4 4. The last call
// specializes keeper with square_c, which implements ext_ic but is not an
// interface class; apart from the restriction that specialization would be
// legal, since a square_c handle can be assigned to a variable of type
// square_c. A tool can report the specialization or the declaration of I.
// The 5.052 release of Verilator accepts the design and prints 4 4; Icarus
// Verilog 13.0 does not parse interface classes.

interface class shape_ic;
  pure virtual function int sides();
endclass

interface class ext_ic extends shape_ic;
endclass

class square_c implements ext_ic;
  virtual function int sides();
    return 4;
  endfunction
endclass

class keeper #(type interface class I = shape_ic);   // (or reported here)
  static function int count(square_c obj);
    I h;
    h = obj;
    return h.sides();
  endfunction
endclass

module test_illegal_interface_class_restricted_type_parameter_given_class;
  square_c s;
  initial begin
    s = new;
    $display("%0d %0d", keeper#(ext_ic)::count(s), keeper#()::count(s));
    void'(keeper#(square_c)::count(s));   // illegal: square_c is not an interface class
  end
endmodule
