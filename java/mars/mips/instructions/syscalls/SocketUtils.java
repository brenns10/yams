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
import java.util.ArrayList;

/**
 * A static class containing common utilities for reading to/from buffers, registers, and memory.
 */
public final class SocketUtils {
    private SocketUtils() {}

    public static byte[] readToNull(int addr, int maxLen) {
        byte[] buff = new byte[maxLen];
        int b = 0;
        try {
           b = Globals.memory.getByte(addr);
        } catch(AddressErrorException e){}
        int actualLen = 0;
        while (actualLen < maxLen && b != 0) {
            buff[actualLen] = (byte)b;
            addr += 1;
            try {
                b = Globals.memory.getByte(addr);
            } catch(AddressErrorException e) {
            }
            actualLen += 1;
        }
        
        return Arrays.copyOfRange(buff, 0, actualLen);
    }

    public static byte[] readToLength(int addr, int maxLen) {
        byte[] buff = new byte[maxLen];
        for (int i = 0; i < maxLen; i++) {
            try {
                buff[i] = (byte)Globals.memory.getByte(addr++);
            } catch (AddressErrorException e) {
                System.out.println("Choked on address: " + addr);
                break;
            }
        }
        return buff;
    }

    private static byte[] rotateFourBytes(byte[] bytes, byte newByte) {
        bytes[0] = bytes[1];
        bytes[1] = bytes[2];
        bytes[2] = bytes[3];
        bytes[3] = newByte;
        return bytes;
    }

    private static boolean isDoubleCRLF(byte[] bytes) {
        final byte CR = 13; //(byte)'\r';
        final byte LF = 10; //(byte)'\n';
        return (bytes[0] == CR && bytes[1] == LF && bytes[2] == CR && bytes[3] == LF);
    }

    public static byte[] readToDoubleCRLF(int addr, int maxLen) {
        byte[] buff = new byte[maxLen];
        byte[] lastFourBytes = new byte[]{0, 0, 0, 0};

        for (int i = 0; i < maxLen; i++) {
            try {
                byte b = (byte)Globals.memory.getByte(addr++);
                buff[i] = b;
                rotateFourBytes(lastFourBytes, b);
                if (isDoubleCRLF(lastFourBytes)) {
                    break;
                }
            } catch (AddressErrorException e) {
                System.out.println("Choked on address: " + addr);
                break;
            }
        }

        return buff;
    }
}

