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


public class SyscallSocketsCloseAll extends AbstractSyscall {
    public SyscallSocketsCloseAll() {
        super(120, "SocketsCloseAll");
    }

    public void simulate(ProgramStatement statement) throws ProcessingException {
        Sockets.closeAll();
    }
}
