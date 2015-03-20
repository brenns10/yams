package mars.mips.instructions.syscalls;
import mars.util.*;
import mars.mips.hardware.*;
import mars.simulator.*;
import mars.*;

import java.net.Socket;
import java.net.ServerSocket;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.util.Arrays;


public class SyscallSocketOpen extends AbstractSyscall {
    public SyscallSocketOpen() {
        super(100, "SocketOpen");
    }

    public void simulate(ProgramStatement statement) throws ProcessingException {
        int hostAddr = RegisterFile.getValue(4);
        String host = new String(SocketUtils.readToNull(hostAddr, 1024));
        int port = RegisterFile.getValue(5);

        try {
            int fd = Sockets.newSocket(host, port);
            RegisterFile.updateRegister(3, fd); // $v0 is taken by system, so our returns go in $v1
        } catch(Exception e) {
            e.printStackTrace();
            System.out.println(e.toString());
            RegisterFile.updateRegister(3, -1);
        }
    }
}
