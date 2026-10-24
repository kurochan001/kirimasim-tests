/*
:name: test_class_constructor_default_argument_expansion
:description: default in a subclass constructor argument list stands for the whole argument list of the superclass constructor, with its order, directions, types, names and default values, an argument right after it is an input of type logic, and a constructor without super.new gets super.new(default) (IEEE 1800-2023 Section 8.17)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_constructor_default_argument_expansion.expected
*/
// IEEE 1800-2023 §8.17: the keyword default in the argument list of a
// subclass constructor expands to the argument list of the superclass
// constructor, in the same order and with the same directions, types, names
// and default values. An argument that directly follows default has the
// default direction input and the default type logic. When the constructor
// does not call super.new, the compiler inserts super.new(default), which
// passes all the expanded arguments.
// root_c::new has tag (string, default "r"), w (int, default 7) and the
// output echo. pre_c adds size before default and has no super.new call;
// post_c adds flag after default and calls super.new(default). The calls use
// positional arguments, omitted arguments that take the defaults of root_c,
// and named arguments with the names of root_c; echo comes back through the
// expanded output argument. flag is a 1-bit logic, so 2 arrives as 0.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports default in a
// constructor argument list.

class root_c;
  string tag;
  int seen;
  function new(string tag = "r", input int w = 7, output int echo);
    this.tag = tag;
    seen = w;
    echo = w * 2;
  endfunction
endclass

class pre_c extends root_c;
  int size;
  function new(int size, default);
    this.size = size;
  endfunction
endclass

class post_c extends pre_c;
  logic flag_seen;
  int flag_bits;
  function new(default, flag);
    super.new(default);
    flag_seen = flag;
    flag_bits = $bits(flag);
  endfunction
endclass

module test_class_constructor_default_argument_expansion;
  pre_c p1, p2, p3;
  post_c q;
  int e1, e2, e3, e4;

  initial begin
    p1 = new(3, "pp", 5, e1);
    $display("positional: size=%0d tag=%s seen=%0d echo=%0d", p1.size, p1.tag, p1.seen, e1);
    p2 = new(4, , , e2);
    $display("defaults: size=%0d tag=%s seen=%0d echo=%0d", p2.size, p2.tag, p2.seen, e2);
    p3 = new(.echo(e3), .w(2), .size(1), .tag("nm"));
    $display("named: size=%0d tag=%s seen=%0d echo=%0d", p3.size, p3.tag, p3.seen, e3);
    q = new(9, "qq", 1, e4, 2);
    $display("after default: size=%0d tag=%s seen=%0d echo=%0d flag=%b bits=%0d", q.size,
             q.tag, q.seen, e4, q.flag_seen, q.flag_bits);
  end
endmodule
