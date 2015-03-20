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


public class SyscallSocketWrite extends AbstractSyscall {
    public SyscallSocketWrite() {
        super(101, "SocketWrite");
    }

    public void simulate(ProgramStatement statement) throws ProcessingException {
        int fd = RegisterFile.getValue(4);
        int addr = RegisterFile.getValue(5);
        int maxLen = RegisterFile.getValue(6);
        InputStream is = null;
        OutputStream os = null;
        byte[] buff;

        if (maxLen < 0) {
            System.out.println("Reading to double CRLF");
            buff = SocketUtils.readToDoubleCRLF(addr, 16384); // increase this as necessary!
        } else {
            System.out.println("Reading to length");
            buff = SocketUtils.readToLength(addr, maxLen);
        }

        try {
            Sockets.getSocket(fd).getOutputStream().write(buff);
            RegisterFile.updateRegister(3, buff.length);
        } catch(Exception e) {
            RegisterFile.updateRegister(3, -1);
        }
    }
}
