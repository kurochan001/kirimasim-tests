/*
:name: test_function_return_type_value_categories
:description: functions return integer vector and atom types with signing, real types, a packed structure, a packed union and an enum written in the return type, an enum and a structure named through a package or class scope, a string, and a type reference, each with its own width, sign, members or enum names (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_return_type_value_categories.expected
*/
// IEEE 1800-2023 13.4 (Syntax 13-2): the return type of a function is a
// data_type, which may be an integer vector type with signing and packed
// dimensions, an integer atom type with signing, a non-integer type, a
// structure or union written in place, an enum written in place, string, a
// type name with a package or class scope, or a type reference, among
// others. A call returns a value of that type.
//
// f_vec returns logic signed [7:0], so 8'h80 reads as -128 with 8 bits.
// f_byte returns byte unsigned, so 8'hF0 reads as 240 (a signed byte would
// give -16). f_short returns shortint: -2 with 16 bits. f_real and f_sreal
// return 2.75 and 0.5 unrounded. f_sp returns a packed structure declared
// in the return type: the members of the call result are hi=10 and lo=5,
// 8 bits in all. f_up returns a packed union whose members u and s share the
// bits 8'hFE: 254 unsigned and -2 signed. f_enum returns an enum type named
// through a package scope; the call result has the method name(), GREEN,
// and the value 2. f_inline_enum returns an enum written in its return
// type, enum logic [1:0] with IN_LOW = 1 and IN_HIGH = 3, and returns
// IN_HIGH: the result has the name IN_HIGH and the value 3, prev() gives
// IN_LOW, num() gives 2, and it has the 2 bits of its base type (an int
// result would have 32 bits and no enum methods). The standard does not say
// in which scope the names of an enum in a return type are declared, so the
// names are used only inside the function, where they are visible in either
// case, and the result is read outside through its enum methods (6.19.5).
// f_str returns a string with len() 4. f_cs returns a
// structure type named through the class scope holder::, with members -3
// and 300. f_tr returns type(proto), the type of a shortint: -5 with 16
// bits. Footnote 18 of the syntax asks for var or a net type keyword before
// a type reference only in variable and net declarations; a function return
// type is neither, and the syntax has no place for var there.
//
// Icarus Verilog 13.0 does not compile the class scope type, the type
// reference and the member selects and method calls on call results.

package test_function_return_type_value_categories_pkg;
  typedef enum logic [1:0] {RED = 2'd1, GREEN = 2'd2, BLUE = 2'd3} color_e;
endpackage

module test_function_return_type_value_categories;
  class holder;
    typedef struct packed { byte a; shortint b; } pair_t;
  endclass

  shortint proto;

  function logic signed [7:0] f_vec();
    return 8'sh80;
  endfunction

  function byte unsigned f_byte();
    return 8'hF0;
  endfunction

  function shortint f_short();
    return -2;
  endfunction

  function real f_real();
    return 2.75;
  endfunction

  function shortreal f_sreal();
    return 0.5;
  endfunction

  function struct packed { logic [3:0] hi; logic [3:0] lo; } f_sp();
    f_sp.hi = 4'hA;
    f_sp.lo = 4'h5;
  endfunction

  function union packed { logic [7:0] u; logic signed [7:0] s; } f_up();
    f_up.u = 8'hFE;
  endfunction

  function test_function_return_type_value_categories_pkg::color_e f_enum();
    return test_function_return_type_value_categories_pkg::GREEN;
  endfunction

  function enum logic [1:0] {IN_LOW = 2'd1, IN_HIGH = 2'd3} f_inline_enum();
    return IN_HIGH;
  endfunction

  function string f_str();
    return "abcd";
  endfunction

  function holder::pair_t f_cs();
    f_cs.a = -3;
    f_cs.b = 300;
  endfunction

  function type(proto) f_tr();
    return -5;
  endfunction

  initial begin
    $display("logic signed [7:0]: %0d bits=%0d", f_vec(), $bits(f_vec()));
    $display("byte unsigned: %0d bits=%0d", f_byte(), $bits(f_byte()));
    $display("shortint: %0d bits=%0d", f_short(), $bits(f_short()));
    $display("real: %0.2f shortreal: %0.2f", f_real(), f_sreal());
    $display("struct packed: hi=%0d lo=%0d bits=%0d", f_sp().hi, f_sp().lo, $bits(f_sp()));
    $display("union packed: u=%0d s=%0d", f_up().u, f_up().s);
    $display("package enum: %s %0d", f_enum().name(), f_enum());
    $display("inline enum: %s %0d prev=%s num=%0d bits=%0d", f_inline_enum().name(),
             f_inline_enum(), f_inline_enum().prev().name(), f_inline_enum().num(),
             $bits(f_inline_enum()));
    $display("string: %s len=%0d", f_str(), f_str().len());
    $display("class scope type: a=%0d b=%0d", f_cs().a, f_cs().b);
    $display("type reference: %0d bits=%0d", f_tr(), $bits(f_tr()));
  end
endmodule
