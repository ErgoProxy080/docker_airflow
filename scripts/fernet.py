from cryptography.fernet import Fernet

def fernet_key():
    key = Fernet.generate_key()
    print(key.decode())

fernet_key()
