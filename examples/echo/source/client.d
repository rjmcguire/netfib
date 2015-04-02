import libasync;
import std.stdio;

import netfib;

/// This example creates a connection localhost:8081, sends a message and waits for a reply before closing
void main() {
	mainLoop({
		new SSLTCPClient("localhost", 8081).connect(&handler);
	});
}

void handler(TCPClient conn) {
	import std.datetime : StopWatch;
	StopWatch sw;
	scope(exit) conn.close();
	try {
		writeln("connected");
		auto buf = new ubyte[](1024);
		sw.start();
		foreach (i; 1..100_000) {
			auto num = cast(ubyte[])to!string(i);
			conn.write(num);
			//writeln("sent: ", cast(string)num);
			auto data = conn.read(buf);
			//writeln("read: ", data);
		}
		sw.stop();
		writeln("time: ", sw.peek.msecs/1000.0F);
		conn.write(cast(ubyte[])"quit\n");
		writeln("sent: quit");
		auto data = conn.read(buf);
		writeln("read: ", data);
	} catch (Exception e) {
		writeln(e);
	}
	writeln("exit exit");
}
