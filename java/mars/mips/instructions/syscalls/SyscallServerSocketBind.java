package mars.mips.instructions.syscalls;
import mars.util.*;
import mars.mips.hardware.*;
import mars.simulator.*;
import mars.*;

import java.net.Socket;
import java.net.ServerSocket;
import java.net.InetSocketAddress;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.util.Arrays;


public class SyscallServerSocketBind extends AbstractSyscall {
    public SyscallServerSocketBind() {
        super(111, "ServerSocketBind");
    }

    public void simulate(ProgramStatement statement) throws ProcessingException {
        int fd = RegisterFile.getValue(4);
        int hostnameAddr = RegisterFile.getValue(5);
        String hostname = new String(SocketUtils.readToNull(hostnameAddr, 1024));
        try {
            ServerSocket s = Sockets.getServerSocket(fd);
            s.bind(new InetSocketAddress(hostname, s.getLocalPort()));
            RegisterFile.updateRegister(3, 1);
        } catch(Exception e) {
            e.printStackTrace();
            System.out.println(e.toString());
            RegisterFile.updateRegister(3, -1);
        }
    }
}
