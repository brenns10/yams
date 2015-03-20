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


public class SyscallSocketRead extends AbstractSyscall {
    public SyscallSocketRead() {
        super(102, "SocketRead");
    }
        
    public void simulate(ProgramStatement statement) throws ProcessingException {
        int fd =  RegisterFile.getValue(4);
        int buffAddr = RegisterFile.getValue(5);
        int maxLen = RegisterFile.getValue(6);

        byte[] buff = new byte[maxLen];

        try {
            int bytesRead = Sockets.getSocket(fd).getInputStream().read(buff);
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println(e.toString());
            throw new ProcessingException();
        }

        for (int i = 0; i < maxLen; i++) {
            // TODO: Make sure this actually writes as expected. May be limited to byte-aligned writing, which
            // will require some fancy bit-string flicking
            try { 
                Globals.memory.setByte(buffAddr++, buff[i]);
            } catch (Exception e) {
                System.out.println("Choked on address: " + buffAddr);
                e.printStackTrace();
                throw new ProcessingException();
            }
        }
    }
}
