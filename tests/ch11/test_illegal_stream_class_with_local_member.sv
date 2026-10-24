/*
:name: test_illegal_stream_class_with_local_member
:description: a class handle whose object has local members cannot be streamed where those members are not accessible (IEEE 1800-2023 Section 11.4.14.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the handle q of sec_c, which has the local member s, is streamed in the module, where s is not accessible
:expected_stderr_regex: test_illegal_stream_class_with_local_member\.sv:46:
*/
// IEEE 1800-2023 §11.4.14.1: a non-null class handle in a streaming
// concatenation streams the data members of the object; it shall be illegal
// to stream a class handle with local or protected members if those members
// would not be accessible at the point of the streaming operator. Streaming
// a pub_c object, whose members are public, and streaming this in a method
// of sec_c, where its local member is accessible, are legal; streaming a
// sec_c handle in the module is not.
// Icarus Verilog 13.0 does not support streaming concatenations.
// The 5.052 release of Verilator reports streaming of class handles as
// unsupported.

class pub_c;
  int a = 1;
  byte b = 2;
endclass

class sec_c;
  int a = 3;
  local byte s = 4;
  function bit [39:0] pack();
    return {>>{this}};
  endfunction
endclass

module test_illegal_stream_class_with_local_member;
  pub_c p = new;
  sec_c q = new;
  bit [39:0] v, w, u;

  initial begin
    v = {>>{p}};
    w = q.pack();
    u = {>>{q}};   // illegal: the local member s is not accessible here
    $display("%h %h", v, w);
  end
endmodule
