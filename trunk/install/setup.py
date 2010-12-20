import getopt, sys
import pexpect


def pexpect_simple(cmd):
    child = pexpect.spawn(cmd)
    child.logfile = sys.stdout
    child.expect(pexpect.EOF, timeout=600)
    child.close()


def add_user_cloud(password):
    child = pexpect.spawn('/usr/sbin/adduser cloud')
    child.logfile = sys.stdout
    child.expect('Enter new UNIX password:')
    child.sendline(password)
    child.expect('Retype new UNIX password:')
    child.sendline(password)
    child.expect('Full Name \[\]:')
    child.sendline('')
    child.expect('Room Number \[\]:')
    child.sendline('')
    child.expect('Work Phone \[\]:')
    child.sendline('')
    child.expect('Home Phone \[\]:')
    child.sendline('')
    child.expect('Other \[\]:')
    child.sendline('')
    child.expect('Is the information correct\? \[Y\/n\] ')
    child.sendline('y')
    child.read()
    child.close()

def setup_x11vnc(password, hostname):
    pexpect_simple('rm -R /root/.vnc/certs')
    child = pexpect.spawn('x11vnc -sslGenCA')
    child.logfile = sys.stdout 
    child.expect('Enter PEM pass phrase:')
    child.sendline(password)
    child.expect('Verifying - Enter PEM pass phrase:')
    child.sendline(password)
    child.expect('Country Name \(2 letter code\) \[AU\]:')
    child.sendline('UK')
    child.expect('State or Province Name \(full name\) \[mystate\]:')
    child.sendline('')
    child.expect('Locality Name \(eg\, city\) \[\]:')
    child.sendline('')
    child.expect('Organization Name \(eg\, company\) \[x11vnc server CA\]')
    child.sendline('Cloud Desktop of ' + str(hostname))
    child.expect('Organizational Unit Name \(eg\, section\) \[\]')
    child.sendline('Cloud Desktop')
    child.expect('Common Name \(eg\, YOUR name\) \[root x11vnc server CA\]:')
    child.sendline('root ' + str(hostname) + ' CA')
    child.expect('Email Address \[x11vnc\@CA.nowhere\]:')
    child.sendline('cloud@example.com')
    child.expect('Press Enter to print the cacert\.pem certificate to the screen: ')
    child.sendline('')
    child.expect(pexpect.EOF, timeout=600)
    child.close()

    child = pexpect.spawn('x11vnc -sslGenCert server')
    child.logfile = sys.stdout 
    child.expect('Country Name \(2 letter code\) \[AU\]:')
    child.sendline('UK')
    child.expect('State or Province Name \(full name\) \[mystate\]:')
    child.sendline('')
    child.expect('Locality Name \(eg\, city\) \[\]:')
    child.sendline('')
    child.expect('Organization Name \(eg\, company\) \[x11vnc server\]')
    child.sendline('Cloud Desktop of ' + str(hostname))
    child.expect('Organizational Unit Name \(eg\, section\) \[\]')
    child.sendline('Cloud Desktop Unit')
    child.expect('Common Name \(eg\, YOUR name\) \[x11vnc server\]:')
    child.sendline(str(hostname))
    child.expect('Email Address \[x11vnc\@server\.nowhere\]:') 
    child.sendline('cloud@example.com')
    child.expect('A challenge password \[\]:')
    child.sendline('')
    child.expect('An optional company name \[\]:')
    child.sendline('')
    child.expect('Protect key with a passphrase\?  y/n ')
    child.sendline('n')
    child.expect('Enter pass phrase for \.\/CA\/private\/cakey\.pem:')
    child.sendline(password)
    child.expect('Sign the certificate\? \[y\/n\]:')
    child.sendline('y')
    child.expect('1 out of 1 certificate requests certified\, commit\? \[y\/n\]')
    child.sendline('y')
    child.expect('Press Enter to print the server\.crt certificate to the screen: ')
    child.sendline('')
    child.expect(pexpect.EOF, timeout=600)
    child.close()


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "p:h:", ["password=", "hostname="])
    except getopt.GetoptError, err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        print "Invalid option"
        sys.exit(2)
    output = None
    verbose = False
    password_user = False
    for o, a in opts:
        if o in ("-p", "--password"):
            password_user = a
        elif o in ("-h", "--hostname"):
            hostname = a
        else:
            assert False, "unhandled option"
    if password_user:
        # set up stuff
        add_user_cloud(password_user)
        setup_x11vnc(password_user, hostname)
        print "**** SETUP Ran with no errors ****"

if __name__ == "__main__":
    main()


