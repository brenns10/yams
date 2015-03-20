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


public class  SyscallServerSocketClose extends AbstractSyscall {
    public SyscallServerSocketClose() {
        super(113, "ServerSocketClose");
    }

    public void simulate(ProgramStatement statement) throws ProcessingException {
        int fd = RegisterFile.getValue(4);
        try {
            Sockets.getServerSocket(fd).close();
            RegisterFile.updateRegister(3, 1); // $v0 is taken by system, so our returns go in $v1
        } catch(Exception e) {
            e.printStackTrace();
            System.out.println(e.toString());
            RegisterFile.updateRegister(3, -1);
        }
    }
}
