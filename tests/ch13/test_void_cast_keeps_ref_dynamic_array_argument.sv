/*
:name: test_void_cast_keeps_ref_dynamic_array_argument
:description: Discarding a return value preserves the incoming ref dynamic array (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2 13.4.1 7.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_void_cast_keeps_ref_dynamic_array_argument.expected
:expected_exit: 0
*/
// The first method allocates three bytes through ref. The next call forwards
// the same array through ref again. Both the discarded call and a call that
// stores its result must see all three elements.

module test_void_cast_keeps_ref_dynamic_array_argument;
  class sink;
    int seen;
    virtual function void make_bytes(ref byte unsigned data[]);
      data = new[3];
      data[0] = 11;
    endfunction
    virtual function void consume(ref byte unsigned data[]);
      seen = data.size();
    endfunction
  endclass
  class transfer;
    virtual function int write_bytes(ref byte unsigned data[], input sink target = null);
      target.make_bytes(data);
      return data.size();
    endfunction
    virtual function int read_bytes(ref byte unsigned data[], input sink target = null);
      target.consume(data);
      return target.seen;
    endfunction
  endclass

  initial begin
    automatic transfer obj = new;
    automatic sink dst = new;
    byte unsigned data[];
    int count;
    count = obj.write_bytes(data, dst);
    $display("CHECK size=%0d", count);
    void'(obj.read_bytes(data, dst));
    $display("CHECK discarded=%0d", dst.seen);
    count = obj.read_bytes(data, dst);
    $display("CHECK assigned=%0d", count);
    $finish;
  end
endmodule
