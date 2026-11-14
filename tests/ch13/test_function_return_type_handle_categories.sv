/*
:name: test_function_return_type_handle_categories
:description: functions return a chandle, a virtual interface, a class handle and a covergroup handle, and the results refer to the interface instance, object and covergroup instance that the functions chose (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_return_type_handle_categories.expected
*/
// IEEE 1800-2023 13.4 (Syntax 13-2): the return type of a function may also
// be chandle, a virtual interface, a class type or a covergroup type.
//
// f_ch returns a chandle; without C code the only chandle value is null, so
// the result is compared with null, and $typename of the call gives the
// keyword chandle. f_vif returns a virtual interface that refers to u_if:
// sig reads 77 through the call result, and after a write of 5 through the
// handle u_if.sig reads 5. f_obj returns a handle to a new object of class
// holder with the given value: 42 and 7 for two calls, which stay apart.
// f_cg returns the handle of the covergroup instance cg_inst; sampling
// through the result with proto = 1 covers one of the two bins of cg_inst,
// whose coverage goes from 0.00 to 50.00 (19.11).
//
// Icarus Verilog 13.0 does not parse the covergroup declaration.

interface test_function_return_type_handle_categories_if;
  int sig = 77;
endinterface

module test_function_return_type_handle_categories;
  class holder;
    int val;
    function new(int v);
      val = v;
    endfunction
  endclass

  test_function_return_type_handle_categories_if u_if();
  int proto;

  covergroup cg_t;
    coverpoint proto {
      bins zero = {0};
      bins one = {1};
    }
  endgroup

  cg_t cg_inst = new;
  cg_t h_cg;
  chandle h_ch;
  virtual test_function_return_type_handle_categories_if h_vif;
  holder h1, h2;

  function chandle f_ch();
    return null;
  endfunction

  function virtual test_function_return_type_handle_categories_if f_vif();
    return u_if;
  endfunction

  function holder f_obj(int v);
    holder h;
    h = new(v);
    return h;
  endfunction

  function cg_t f_cg();
    return cg_inst;
  endfunction

  initial begin
    h_ch = f_ch();
    $display("chandle: is_null=%0d type=%s", h_ch == null, $typename(f_ch()));
    $display("virtual interface: sig=%0d", f_vif().sig);
    h_vif = f_vif();
    h_vif.sig = 5;
    $display("virtual interface: after write u_if.sig=%0d", u_if.sig);
    h1 = f_obj(42);
    h2 = f_obj(7);
    $display("class: %0d %0d", h1.val, h2.val);
    h_cg = f_cg();
    $display("covergroup: before=%0.2f", cg_inst.get_inst_coverage());
    proto = 1;
    h_cg.sample();
    $display("covergroup: after=%0.2f", cg_inst.get_inst_coverage());
  end
endmodule
