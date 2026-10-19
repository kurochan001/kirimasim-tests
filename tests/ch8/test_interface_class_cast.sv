/*
:name: test_interface_class_cast
:description: $cast between interface class handles and class handles succeeds only when the object implements the destination type (IEEE 1800-2023 Section 8.26.5)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.5 8.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_cast.expected
*/
// IEEE 1800-2023 §8.26.5: an object handle can be assigned to a variable of an
// interface class type that its class implements. $cast (8.16) from one
// interface class handle to another, or from an interface class handle to a
// class handle, succeeds when the object it holds is of a type that can be
// assigned to the destination, and fails otherwise, leaving the destination
// unchanged.
//
// The cast from one interface class handle to the other fails in version 5.052
// of Verilator, which then stops on the null handle; Icarus Verilog 13.0 does
// not compile interface classes.

interface class cast_reader;
  pure virtual function int read();
endclass

interface class cast_writer;
  pure virtual function void write(int v);
endclass

class cast_reg implements cast_reader, cast_writer;
  int v;
  virtual function int read();
    return v;
  endfunction
  virtual function void write(int x);
    v = x;
  endfunction
endclass

class cast_rom implements cast_reader;
  virtual function int read();
    return 5;
  endfunction
endclass

module test_interface_class_cast;
  cast_reg r;
  cast_rom m;
  cast_reader rd;
  cast_writer wr;
  cast_reg back;
  int ok;

  initial begin
    r = new;
    m = new;
    rd = r;
    ok = $cast(wr, rd);
    $display("reader of a cast_reg to writer: %0d", ok);
    wr.write(9);
    $display("written through the writer: %0d", rd.read());
    ok = $cast(back, rd);
    $display("reader to cast_reg: %0d, same object: %0d", ok, back == r);
    rd = m;
    wr = null;
    ok = $cast(wr, rd);
    $display("reader of a cast_rom to writer: %0d, writer is null: %0d", ok, wr == null);
  end
endmodule
