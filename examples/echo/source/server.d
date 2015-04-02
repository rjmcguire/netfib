import netfib;

import std.stdio : writeln;

/// This example creates a listener on localhost:8081 which accepts connections, sends a reply,
/// and exits the process after the first client has disconnected
bool accepting = true;

void main() {
	auto ctx = new SSLServerContext("cert.pem", "");

	//import core.stdc.signal;
   //signal(SIGINT, &sigIntHandler);

	mainLoop({
		TCPListener listener = new SSLTCPListener(ctx, "localhost", 8081);
		while (accepting) {
			listener.accept(&handler);
		}
		writeln("exit as planned");
	});
}

// Note how the handler has no idea this is an ssl connection
void handler(TCPConnection conn) {
	try {
		ubyte[] buf = new ubyte[4096];
		ubyte[] data;
		do {
			data = conn.read(buf);
			//writeln("got data", cast(char[])data);
			if (!conn.write(data)) {
				writeln("failed writing echo");
			}
		} while (data != "quit\n" && !conn.closed);
		writeln("closing connection");
		conn.close(); // If you don't close this connection when finished a readable event will cause a lock up in onReadable
	} catch (Throwable e) {
			writeln(e);
	}
}
