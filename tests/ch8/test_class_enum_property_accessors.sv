/*
:name: test_class_enum_property_accessors
:description: Methods of an object read and write its properties of enumerated types, a 64-bit vector and fixed-size arrays of bytes, and an enumeration with explicit values in any order keeps their signs through a cast to int (IEEE 1800-2023 Sections 8.4 to 8.6, 6.19)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.5 8.6 6.19 7.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_enum_property_accessors.expected
*/
// IEEE 1800-2023 §8.4 to §8.6: an object made by new has the properties its
// class declares, and the methods of the class read and write them through
// the object. Here they are an enum without a base type, whose names take
// the values 0, 1 and 2 in order, an enum with base type int whose names
// have explicit values given in any order, some of them negative (§6.19),
// a 64-bit vector and fixed-size arrays of bytes (§7.4). The constructor
// sets the defaults; each step writes properties through one method and
// checks them through others, and a case on the enum gives its text.
// Because int is signed, int'(result) < 0 holds for the negative values
// only. Each step prints PASS with the values it read.

module test_class_enum_property_accessors;

  typedef enum {
    OP_LOAD,
    OP_STORE,
    OP_NONE
  } op_kind_e;

  typedef enum int {
    RES_DONE = 3,
    RES_WAITING = 0,
    RES_FAULT = -1,
    RES_BAD_PLACE = -4,
    RES_BAD_OP = -2,
    RES_TOO_LONG = -6,
    RES_BAD_MASK = -9
  } result_e;

  class request;
    op_kind_e op;
    logic [63:0] place;
    byte unsigned bytes[16];
    int n_bytes;
    result_e result;
    bit cacheable;
    byte unsigned mask[16];
    int n_mask;
    int beat_width;

    function new();
      op = OP_LOAD;
      place = 0;
      n_bytes = 0;
      result = RES_WAITING;
      cacheable = 0;
      n_mask = 0;
      beat_width = 0;
    endfunction

    function void set_op(op_kind_e k);
      op = k;
    endfunction

    function op_kind_e get_op();
      return op;
    endfunction

    function bit is_load();
      return (op == OP_LOAD);
    endfunction

    function bit is_store();
      return (op == OP_STORE);
    endfunction

    function void set_place(logic [63:0] p);
      place = p;
    endfunction

    function logic [63:0] get_place();
      return place;
    endfunction

    function void put_byte(int idx, byte unsigned value);
      if (idx >= 0 && idx < 16) begin
        bytes[idx] = value;
      end
    endfunction

    function byte unsigned get_byte(int idx);
      if (idx >= 0 && idx < 16) begin
        return bytes[idx];
      end
      return 0;
    endfunction

    function void set_n_bytes(int n);
      n_bytes = n;
    endfunction

    function int get_n_bytes();
      return n_bytes;
    endfunction

    function void set_result(result_e r);
      result = r;
    endfunction

    function result_e get_result();
      return result;
    endfunction

    function bit succeeded();
      return (result == RES_DONE);
    endfunction

    function bit failed();
      return (int'(result) < 0);
    endfunction

    function string result_text();
      case (result)
        RES_DONE:      return "done";
        RES_WAITING:   return "waiting";
        RES_FAULT:     return "fault";
        RES_BAD_PLACE: return "bad place";
        RES_BAD_OP:    return "bad op";
        RES_TOO_LONG:  return "too long";
        RES_BAD_MASK:  return "bad mask";
        default:       return "unknown";
      endcase
    endfunction

    function void set_cacheable(bit c);
      cacheable = c;
    endfunction

    function bit is_cacheable();
      return cacheable;
    endfunction

    function void set_beat_width(int w);
      beat_width = w;
    endfunction

    function int get_beat_width();
      return beat_width;
    endfunction
  endclass

  request rq;
  int test_pass;

  initial begin
    byte unsigned b;
    test_pass = 1;

    $display("=== request object ===");

    rq = new();

    // Step 1: defaults set by the constructor
    $display("--- Step 1: defaults ---");
    if (rq.is_load() && rq.get_place() == 0 && rq.get_result() == RES_WAITING) begin
      $display("PASS: op %0d, place 0, result %s", rq.get_op(), rq.result_text());
    end else begin
      $display("FAIL: defaults");
      test_pass = 0;
    end

    // Step 2: the operation
    $display("--- Step 2: op ---");
    rq.set_op(OP_STORE);
    if (rq.is_store() && !rq.is_load()) begin
      $display("PASS: op %0d is a store", rq.get_op());
    end else begin
      $display("FAIL: op");
      test_pass = 0;
    end

    // Step 3: the 64-bit place
    $display("--- Step 3: place ---");
    rq.set_place(64'h0000_3000_0BAD_F00D);
    if (rq.get_place() == 64'h0000_3000_0BAD_F00D) begin
      $display("PASS: place = 0x%016h", rq.get_place());
    end else begin
      $display("FAIL: place");
      test_pass = 0;
    end

    // Step 4: bytes in the fixed-size array
    $display("--- Step 4: bytes ---");
    rq.put_byte(0, 8'h11);
    rq.put_byte(1, 8'h22);
    rq.put_byte(2, 8'h33);
    rq.put_byte(3, 8'h44);
    rq.put_byte(16, 8'h55);
    rq.set_n_bytes(4);
    b = rq.get_byte(2);
    if (b == 8'h33 && rq.get_n_bytes() == 4 && rq.get_byte(16) == 0) begin
      $display("PASS: byte 2 = 0x%02h, %0d bytes", b, rq.get_n_bytes());
    end else begin
      $display("FAIL: bytes");
      test_pass = 0;
    end

    // Step 5: a positive result
    $display("--- Step 5: result ---");
    rq.set_result(RES_DONE);
    if (rq.succeeded() && !rq.failed()) begin
      $display("PASS: result %0d = %s", rq.get_result(), rq.result_text());
    end else begin
      $display("FAIL: result");
      test_pass = 0;
    end

    // Step 6: negative results
    $display("--- Step 6: failed results ---");
    rq.set_result(RES_BAD_PLACE);
    if (!rq.succeeded() && rq.failed()) begin
      $display("PASS: result %0d = %s", rq.get_result(), rq.result_text());
    end else begin
      $display("FAIL: failed result");
      test_pass = 0;
    end
    rq.set_result(RES_BAD_MASK);
    if (rq.failed()) begin
      $display("PASS: result %0d = %s", rq.get_result(), rq.result_text());
    end else begin
      $display("FAIL: failed result");
      test_pass = 0;
    end

    // Step 7: a bit property
    $display("--- Step 7: cacheable ---");
    rq.set_cacheable(1);
    if (rq.is_cacheable()) begin
      $display("PASS: cacheable = %0d", rq.is_cacheable());
    end else begin
      $display("FAIL: cacheable");
      test_pass = 0;
    end

    // Step 8: an int property
    $display("--- Step 8: beat width ---");
    rq.set_beat_width(32);
    if (rq.get_beat_width() == 32) begin
      $display("PASS: beat width = %0d", rq.get_beat_width());
    end else begin
      $display("FAIL: beat width");
      test_pass = 0;
    end

    $display("=== done ===");
    if (test_pass) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED");
    end

    $finish;
  end
endmodule
