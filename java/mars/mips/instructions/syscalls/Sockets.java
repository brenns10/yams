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
 * A static class responsible for holding all the sockets used across the various Socket Syscalls.
 * 
 * Common utilities for reading to/from buffers, registers, and memory can be found in SocketUtils.
 */
public final class Sockets {
    private static ArrayList<ServerSocket> serverSockets = new ArrayList<>();
    private static ArrayList<Socket> sockets = new ArrayList<>();

    private Sockets() {
        serverSockets = new ArrayList<>();
        sockets = new ArrayList<>();
    }

    // ServerSocket operations
    public static int newServerSocket(int port) {
        try {
            ServerSocket s = new ServerSocket(port);
            serverSockets.add(s);
            return serverSockets.size() - 1;
        } catch (Exception e) {
            System.out.println("Unable to open ServerSocket");
            e.printStackTrace();
            return -1;
        }
    }

    public static ServerSocket getServerSocket(int fd) {
        return serverSockets.get(fd);
    }

    public static void closeServerSocket(int fd) {
        try {
            serverSockets.get(fd).close();
        } catch (IOException e) {
            // Really, there's not much we can do.
        }
    }

    // Socket operations
    public static int newSocket(String host, int port) {
        try {
            return addSocket(new Socket(host, port));
        } catch (Exception e) {
            System.out.println("Unable to open Socket");
            e.printStackTrace();
            return -1;
        }
    }

    public static int addSocket(Socket s) {
        sockets.add(s);
        return sockets.size() - 1;
    }

    public static Socket getSocket(int fd) {
        return sockets.get(fd);
    }

    public static void closeSocket(int fd) {
        try {
            sockets.get(fd).close();
        } catch (IOException e) {
            // Really, there's not much we can do.
        }
    }

    public static void closeAll() {
        for (Socket s : sockets) {
            try {
                s.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        for (ServerSocket s : serverSockets) {
            try {
                s.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        sockets = new ArrayList<>();
        serverSockets = new ArrayList<>();
    }
}
