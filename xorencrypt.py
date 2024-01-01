import os
import sys
import random
import string


def generate_random_string(length):
    # 生成随机字符串的字符集
    characters = string.ascii_letters + string.digits

    # 使用时间戳作为随机种子
    random.seed()

    # 生成指定长度的随机字符串
    random_string = ''.join(random.choice(characters) for _ in range(length))
    return random_string


def xor_encrypt(plaintext, key):
    ciphertext = bytearray()
    key_length = len(key)
    for i, byte in enumerate(plaintext):
        key_byte = key[i % key_length]
        encrypted_byte = byte ^ key_byte
        ciphertext.append(encrypted_byte)
    return bytes(ciphertext)

def printCiphertext(ciphertext):
	print('{ 0x' + ', 0x'.join(hex(x)[2:] for x in ciphertext) + ' };')
    
def printtext(ciphertext):
     print('{ 0x' + ', 0x'.join(hex(ord(x))[2:] for x in ciphertext) + ' };')
        

# 读取二进制文件
try:
    filename = sys.argv[1]
except Exception as e:
    print("Usage: python .\\xorencrypt.py .\\calc.bin")
    exit()


with open(filename, "rb") as file:
    plaintext = file.read()

file_size = os.path.getsize(filename)
key = bytes(generate_random_string(6).encode("utf-8")) 
ciphertext = xor_encrypt(plaintext, key)

output_filename = f"{filename[:-4]}_encrypted.bin" 

with open(output_filename, "wb") as file:
    file.write(ciphertext)

print(f"[*] xor encrypted : {output_filename}")
print(f"[*] len = {len(key)}")

print("[*] payload len :", file_size)
printCiphertext(key)
printCiphertext(ciphertext)


"""
python ~/tools/xorencrypt.py calc.bin
[*] xor encrypted : calc_encrypted.bin
[*] len = 6
[*] payload len : 272
{ 0x4d, 0x46, 0x78, 0x61, 0x6b, 0x72 };
{ 0xc6, 0x14, 0x46 };
"""
