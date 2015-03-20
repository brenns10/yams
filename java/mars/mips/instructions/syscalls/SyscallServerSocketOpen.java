package mars.mips.instructions.syscalls;
import mars.util.*;
import mars.mips.hardware.*;
import mars.simulator.*;
import mars.*;

import java.net.Socket;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.util.Arrays;


public class SyscallServerSocketOpen extends AbstractSyscall {
    public SyscallServerSocketOpen() {
        super(110, "ServerSocketOpen");
    }

    public void simulate(ProgramStatement statement) throws ProcessingException {
        int port = RegisterFile.getValue(4);
        try {
            int fd = Sockets.newServerSocket(port);
            RegisterFile.updateRegister(3, fd); // $v0 is taken by system, so our returns go in $v1
        } catch(Exception e) {
            e.printStackTrace();
            System.out.println(e.toString());
            RegisterFile.updateRegister(3, -1);
        }
    }
}
