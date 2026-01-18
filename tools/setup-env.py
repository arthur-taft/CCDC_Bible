import sys
import subprocess


def get_os():
    if sys.platform.startswith("win"):
        windows_install()
    elif sys.platform.startswith("linux"):
        linux_install()
    elif sys.platform.startswith("darwin"):
        mac_install()
    else:
        print("Unknown operating system!")
        raise SystemExit(1)


def windows_install():
    pass


def linux_install():
    subprocess.run(["bash", "linux-install.sh"])


def mac_install():
    pass


get_os()
