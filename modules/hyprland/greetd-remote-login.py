"""Log in through greetd's IPC socket and start a session, without a
physical console. Speaks the same protocol tuigreet uses, so PAM
modules tied to the real password (e.g. gnome-keyring unlock) still
fire - unlike a greetd `initial_session` autologin.
"""
import argparse
import getpass
import glob
import json
import socket
import struct
import sys
import time


def find_socket(timeout=20):
    deadline = time.monotonic() + timeout
    while True:
        matches = glob.glob("/run/greetd-*.sock")
        if len(matches) == 1:
            return matches[0]
        if len(matches) > 1:
            sys.exit(f"multiple greetd sockets, won't guess: {matches!r}")
        if time.monotonic() > deadline:
            sys.exit("timed out waiting for a greetd socket")
        time.sleep(0.5)


def recv_exact(sock, n):
    buf = b""
    while len(buf) < n:
        chunk = sock.recv(n - len(buf))
        if not chunk:
            sys.exit("greetd closed the connection unexpectedly")
        buf += chunk
    return buf


def send(sock, request):
    payload = json.dumps(request).encode()
    sock.sendall(struct.pack("=I", len(payload)) + payload)


def recv(sock):
    (length,) = struct.unpack("=I", recv_exact(sock, 4))
    return json.loads(recv_exact(sock, length))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--user", required=True, help="username to log in as"
    )
    parser.add_argument("cmd", nargs="+", help="session command argv")
    args = parser.parse_args()

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(find_socket())

    send(sock, {"type": "create_session", "username": args.user})
    starting = False
    while True:
        resp = recv(sock)
        rtype = resp["type"]
        if rtype == "auth_message":
            message = resp["auth_message"]
            mtype = resp["auth_message_type"]
            if mtype == "secret":
                answer = getpass.getpass(f"{message} ")
            elif mtype == "visible":
                answer = input(f"{message} ")
            else:
                print(message)
                answer = None
            send(sock, {
                "type": "post_auth_message_response",
                "response": answer,
            })
        elif rtype == "success":
            if starting:
                print("Session started.")
                return
            starting = True
            send(sock, {
                "type": "start_session",
                "cmd": args.cmd,
                "env": [],
            })
        elif rtype == "error":
            send(sock, {"type": "cancel_session"})
            error_type = resp["error_type"]
            description = resp["description"]
            sys.exit(f"greetd error ({error_type}): {description}")
        else:
            sys.exit(f"unexpected response: {resp}")


if __name__ == "__main__":
    main()
