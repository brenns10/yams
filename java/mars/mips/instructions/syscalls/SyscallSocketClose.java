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


public class SyscallSocketClose extends AbstractSyscall {
    public SyscallSocketClose() {
        super(103, "SocketClose");
    }

    public void simulate(ProgramStatement statement) throws ProcessingException {
        int fd = RegisterFile.getValue(4);
        try {
            Sockets.getSocket(fd).close();
        } catch (Exception e) {
            // Not a whole lot we can do.
            e.printStackTrace();
        }
    }
}
